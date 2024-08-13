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

  

  
  task generate_test( test_case _test    = TEST_MVP, 
                      int       chance   = 50, 
                      int       test_len = 10);
    T tr;

    case( _test )
      TEST_MVP:
        begin
          for(int i = 16; i <= 16; i++)
            begin
              tr = new( $urandom_range(2**32 - 1, 0), 
                        i,
                        20,
                        100);
              $display(tr.get_channel(), tr.get_size_of_packet());
              this.gen2drv.put( tr );
            end
        end
      
      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end

    endcase

  endtask
  
endclass