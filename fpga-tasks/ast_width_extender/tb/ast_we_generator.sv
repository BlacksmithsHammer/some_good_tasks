class ast_we_generator #(
  type T,
  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  local mailbox #( T ) gen2drv;

  function new( input mailbox #( T ) gen2drv );
    this.gen2drv = gen2drv;
  endfunction

  // plain generate with pauses and not 100% filled stream
  task range_size_gen_plain(int chance_from, // chance of ready/valid
                            int chance_to,
                            int size_from,   // packet sizes from ... to
                            int size_to,
                            int range_channel_from, // range for random channel of transaction
                            int range_channel_to,
                            T tr);
    for(int i = size_from; i <= size_to; i++)
      begin
        tr = new( $urandom_range(range_channel_to, range_channel_from), 
                  i,
                  $urandom_range(chance_to, chance_from),
                  $urandom_range(chance_to, chance_from));
        this.gen2drv.put( tr );
      end
  endtask
  
  task generate_test( test_case _test = TEST_PLAIN);
    T tr;

    case( _test )
      FOUND_PROBLEM_CHANNEL:
        begin
          range_size_gen_plain(10, 10,   
                     9, 9,    
                     0, 2**32-1, 
                     tr);
        end
    
      TEST_PLAIN:
        begin
          range_size_gen_plain(100, 100,   
                               1, 128,    
                               0, 2**32-1, 
                               tr);
          
          range_size_gen_plain(100, 100,   
                               500, 600,    
                               0, 2**32-1, 
                               tr);
          range_size_gen_plain(100, 100,   
                               65530, 65536,  
                               0, 2**32-1,
                               tr);
        end

      TEST_PLAIN_RANDOMIZED:
        begin
          range_size_gen_plain(25, 50,   
                               1, 64,    
                               0, 2**32-1, 
                               tr);
          
          range_size_gen_plain(25, 50,  
                               500, 600,
                               0, 2**32-1,
                               tr);

          range_size_gen_plain(25, 50,
                               65530, 65536,
                               0, 2**32-1,
                               tr);
        end

      TEST_CHANNELS:
        begin
          range_size_gen_plain(25, 50,   
                               1, 64,   
                               25, 25, 
                               tr);
          
          range_size_gen_plain(25, 50,   
                               500, 600,   
                               500, 502, 
                               tr);

          range_size_gen_plain(25, 50,  
                               65530, 65536,   
                               100, 105, 
                               tr);

        end

      // this test includes all previous + randomized packets
      TEST_RANDOM_BIG:
        begin
          //--------------------------------------------
          range_size_gen_plain(100, 100,   
                               1, 64,  
                               0, 2**32-1, 
                               tr);
          
          range_size_gen_plain(100, 100,   
                               500, 600,    
                               0, 2**32-1, 
                               tr);

          range_size_gen_plain(100, 100,   
                               65530, 65536,    
                               0, 2**32-1,
                               tr);
          //--------------------------------------------
          range_size_gen_plain(25, 50,   
                               1, 64,    
                               0, 2**32-1, 
                               tr);
          
          range_size_gen_plain(25, 50,  
                               500, 600,
                               0, 2**32-1,
                               tr);

          range_size_gen_plain(25, 50,
                               65530, 65536,
                               0, 2**32-1,
                               tr);
          //--------------------------------------------
          range_size_gen_plain(25, 50,   
                               1, 64,   
                               25, 25, 
                               tr);
          
          range_size_gen_plain(25, 50,   
                               500, 600,   
                               500, 502, 
                               tr);

          range_size_gen_plain(25, 50,  
                               65530, 65536,   
                               100, 105, 
                               tr);
          //--------------------------------------------
          // very big randomized part of test
          // change in [test_iter < 10000] 10000 on number of rand tests
          for(int test_iter = 0; test_iter < 10000; test_iter++)
            begin
              int _tmp = $urandom_range(1, 65531);
              range_size_gen_plain(10, 100,  
                                   _tmp, _tmp + 5,
                                   0, $urandom_range(2**32 - 1), 
                                   tr);
            end

        end

      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end

    endcase
    
    // fix for work in fork-thread
    #1000000000;

  endtask
  
endclass