class ast_dmx_generator #(
  type T,
  
  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
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
                            int range_dir_from, // range for dir channel of transaction
                            int range_dir_to,
                            T tr);
    for(int i = size_from; i <= size_to; i++)
      begin
        tr = new( $urandom_range(range_channel_to, range_channel_from), 
                  $urandom_range(range_dir_to, range_dir_from),
                  i,
                  $urandom_range(chance_to, chance_from),
                  $urandom_range(chance_to, chance_from));
        this.gen2drv.put( tr );
      end
  endtask

  task generate_test( test_case _test = TEST_PLAIN);
    T tr;

    case( _test )
      MVP:
        begin
          range_size_gen_plain(
            100, 100,
            18, 20,
            0, 2**32-1,
            0, TX_DIR - 1,
            tr
          );
        end
    
      TEST_PLAIN:
        begin
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