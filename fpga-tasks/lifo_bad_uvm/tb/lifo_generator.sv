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
          //generate_stimulus(5, REQ_EMPTY);
          plain_write(chance, test_len);
          plain_read(chance, test_len);
          generate_stimulus(5, REQ_EMPTY);
          plain_rw(chance, test_len);
        end
      FULL_RW:
        begin
          plain_write(chance, 2**AWIDTH);
          plain_read(chance, 2**AWIDTH);
        end
      OVER_RW:
        begin
          plain_write(chance, 2**AWIDTH + 2);
          plain_read(chance, 2**AWIDTH + 4);
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