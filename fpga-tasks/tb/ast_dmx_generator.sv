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
                            int pause_after,
                            T tr);
    for(int i = size_from; i <= size_to; i++)
      begin
        tr = new( $urandom_range(range_channel_to, range_channel_from), 
                  $urandom_range(range_dir_to, range_dir_from),
                  i,
                  $urandom_range(chance_to, chance_from),
                  $urandom_range(chance_to, chance_from),
                  pause_after);
        this.gen2drv.put( tr );
      end
  endtask

  task generate_test( test_case _test );
    T tr;

    case( _test )
      ONE_BYTE:
        begin
          for (int i = 0; i < TX_DIR; i++)
            range_size_gen_plain(
              100, 100,
              1, 1,
              0, 2**32-1,
              i, i,
              0,
              tr
            );
        end
    
      ONE_BYTE_RAND_READY:
        begin
          for (int i = 0; i < 50; i++)
            range_size_gen_plain(
              50, 50,
              1, 1,
              0, 2**32-1,
              0, TX_DIR-1,
              0,
              tr
            );
        end
      
      MANY_BYTES_RAND_READY:
        begin
          for (int i = 0; i < TX_DIR; i++)
            range_size_gen_plain(
              20, 20,
              2, 100,
              0, 2**32-1,
              i, i,
              0,
              tr
            );
        end

      SWAP_DIRS_RAND_READY:
        begin
          // i from 0 to 10 - this is the number of iterations sending packets from 2 to 100 bytes
          for (int i = 0; i < 10; i++)
            range_size_gen_plain(
              20, 20,
              1, 100,
              0, 2**32-1,
              0, TX_DIR-1,
              0,
              tr
            );
          
          for (int i = 0; i < 10; i++)
            range_size_gen_plain(
              100, 100,
              1, 100,
              0, 2**32-1,
              0, TX_DIR-1,
              0,
              tr
            );
        end

      MAIN_TEST:
        begin
          // many random iterations
          for (int i = 0; i < 10; i++)
            range_size_gen_plain(
              100, 100,
              1, 100,
              0, 2**32-1,
              0, TX_DIR-1,
              0,
              tr
            );
          
          for (int i = 0; i < 10; i++)
            range_size_gen_plain(
              100, 100,
              1, 100,
              0, 2**32-1,
              0, TX_DIR-1,
              $urandom_range(5, 0), // pause between packets to check unexpected problems
              tr
            );
          
          for (int i = 0; i < 10; i++)
            range_size_gen_plain(
              20, 20,
              1, 100,
              0, 2**32-1,
              0, TX_DIR-1,
              0,
              tr
            );
          
          for (int i = 0; i < 10; i++)
            range_size_gen_plain(
              20, 20,
              1, 100,
              0, 2**32-1,
              0, TX_DIR-1,
              $urandom_range(5, 0), // pause between packets to check unexpected problems
              tr
            );

          // check channels (little test)
          for (int ch = 0; ch < 10; ch++)
            for (int i = 0; i < 5; i++)
              range_size_gen_plain(
                100, 100,
                1, 100,
                ch, ch,
                0, TX_DIR-1,
                0,
                tr
              );
              
          for (int ch = 0; ch < 10; ch++)
            for (int i = 0; i < 5; i++)
              range_size_gen_plain(
                20, 20,
                1, 100,
                ch, ch,
                0, TX_DIR-1,
                0,
                tr
              );
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