class lifo_generator #(
  type T
  // ignored DWIDTH and AWIDTH
);
  local mailbox #( T ) gen2drv;

  function new( input mailbox #( T ) gen2drv );
    this.gen2drv = gen2drv;
  endfunction

  task generate_stimulus( int n  = 10,
                          int op = REQ_RW);
    T tr;
    for (int i = 0; i < n; i++) 
      begin
        tr = new( op, $urandom_range(2**32 - 1, 0) );
        $display(tr.get_word());
        this.gen2drv.put( tr );
      end
  endtask

  task generate_test(test_case _test);
    case( _test )
      SOME_RW:
        begin
          generate_stimulus(5, REQ_WRITE);
          generate_stimulus(5, REQ_READ );
        end
      WRITE_READ_FULL:
        begin

        end

      OVER_RW:
        begin

        end
      
      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end
    endcase
  endtask

endclass