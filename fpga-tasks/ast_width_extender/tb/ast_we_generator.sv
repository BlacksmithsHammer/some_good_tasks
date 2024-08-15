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
  task range_size_gen_plain(int chance_from,
                            int chance_to,
                            int size_from,
                            int size_to,
                            int range_channel_from,
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
  
  task generate_test( test_case _test = TEST_MVP);
    T tr;

    case( _test )
      TEST_MVP:
        begin
          range_size_gen_plain(100, 100,   // chance of ready/valid
                               1, 10000,     // packet sizes from ... to
                               0, 2**32-1, // range for random channel of transaction
                               tr);
          // for(int i = 12; i <= 128; i++)
          //   begin
          //     tr = new( $urandom_range(2**32 - 1, 0), 
          //               i,
          //               100,
          //               100);
          //     this.gen2drv.put( tr );
          //   end
          
          // for(int i = 1; i <= 128; i++)
          //   begin
          //     tr = new( $urandom_range(2**32 - 1, 0), 
          //               i,
          //               10,
          //               10);
          //     this.gen2drv.put( tr );
          //   end

        end
      
      TEST_EVERY_SIZE:
        begin
          // plain generate without pauses and 100% filled stream
          //range_size_gen_plain(100, 1, 65536, 0, 2**32-1, tr);
 
          // plain generate with pauses and not 100% filled stream
          // every_size_gen_plain(100, 20, 0);

        end

      TEST_RANDOM_BIG:
        begin

        end

      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end

    endcase
    
    #1000000000;

  endtask
  
endclass