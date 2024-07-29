class lifo_generator #(
  type T,
  parameter int DWIDTH = 16,
  parameter int AWIDTH = 8
);
  local mailbox #( T ) gen2drv;

  function new( input mailbox #( T ) gen2drv );
    this.gen2drv = gen2drv;
  endfunction

  task generate_stimulus( int     n  = 10,
                          rq_code op = REQ_RW);
    T tr;
    for (int i = 0; i < n; i++) 
      begin
        tr = new( op, $urandom_range(2**32 - 1, 0) );
        this.gen2drv.put( tr );
      end
  endtask

  task plain_write(int chance, int test_len);
    int i = 0;
    while( i < test_len )
      if( $urandom_range(99, 0) < chance ) 
        begin
          generate_stimulus(1, REQ_WRITE);
          i = i + 1;
        end
      else
        generate_stimulus(1, REQ_EMPTY);
  endtask

  task plain_read(int chance, int test_len);
    int  i = 0;
    while( i < test_len )
      if( $urandom_range(99, 0) < chance )
        begin
          generate_stimulus(1, REQ_READ);
          i = i + 1;
        end
      else
        generate_stimulus(1, REQ_EMPTY);
  endtask

  task plain_rw(int chance, int test_len);
    int  i = 0;
    while( i < test_len )
      if( $urandom_range(99, 0) < chance )
        begin
          generate_stimulus(1, REQ_RW);
          i = i + 1;
        end
      else
        generate_stimulus(1, REQ_EMPTY);
  endtask

  // test_len - very abstract parameter
  task generate_test( test_case _test    = SOME_RW, 
                      int       chance   = 50, 
                      int       test_len = 10);
    case( _test )
      SOME_RW:
        begin
          plain_write(chance, test_len);
          plain_read(chance, test_len);
          generate_stimulus(5, REQ_EMPTY);
          plain_write(chance, test_len);
          plain_rw(chance, test_len);
        end

      FULL_RW:
        begin
          // 2**AWIDTH - change it on 4 or 5 to see a problem with q_o
          for(int len_of_op = 1; len_of_op <= 2**AWIDTH; len_of_op++ )
            begin
              plain_write(100, len_of_op);
              plain_read(100, len_of_op);
            end
        end

      OVER_RW:
        begin
          plain_write(chance, 2**AWIDTH + 2);
          plain_read(chance, 2**AWIDTH + 4);
        end

      BIG_TEST:
        begin
          // fill and read with different ranges, chance of r/w = 100% 
          // without overflow
          for(int len_of_op = 1; len_of_op <= 2**AWIDTH; len_of_op++ )
            begin
              plain_write(100, len_of_op);
              plain_read(100, len_of_op);
            end

          // fill and read with different ranges, chance of r/w = 100% 
          // with overflow
          for(int len_of_op = 1; len_of_op <= 2**AWIDTH + 5; len_of_op++ )
            begin
              plain_write(100, len_of_op);
              plain_read(100, len_of_op + 10);
            end

          // fill and read with different ranges, chance of r/w = 100% 
          // without overflow and different chance
          for(int len_of_op = 1; len_of_op <= 2**AWIDTH; len_of_op++ )
            begin
              plain_write(25, len_of_op);
              plain_read(25, len_of_op);
            end

          // fill and read with different ranges, chance of r/w = 100% 
          // with overflow and different chance
          for(int len_of_op = 1; len_of_op <= 2**AWIDTH + 5; len_of_op++ )
            begin 
              plain_write(25, len_of_op);
              plain_read(25, len_of_op + 10);
            end
          // and with WAR operations
          for(int len_of_op = 1; len_of_op <= 2**AWIDTH + 5; len_of_op++ )
            begin 
              plain_write(25, len_of_op);
              plain_rw(25, len_of_op);
              plain_read(25, len_of_op + 10);
            end

          
          // absolutely randomized test :)

          for(int iter = 0; iter <= test_len; iter++)
            begin
              int rand_op = $urandom_range(2**32 - 1, 0) % 4;

              case (rand_op)
                0:
                  plain_write($urandom_range(100, 25), $urandom_range(2**AWIDTH, 1));
                1:
                  plain_read($urandom_range(100, 25), $urandom_range(2**AWIDTH, 1));
                2:
                  plain_rw($urandom_range(100, 25), $urandom_range(2**AWIDTH, 1));
                3:
                  generate_stimulus($urandom_range(2**AWIDTH, 1), REQ_EMPTY);

                //default:  `THROW_CRITICAL_ERROR("PROBLEM IN RANDOM TEST");
              endcase
            end

          
        end
      
      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end


    endcase
    
    // fill time with "void" after main test-stimulus
    generate_stimulus(5, REQ_EMPTY);
  endtask

endclass