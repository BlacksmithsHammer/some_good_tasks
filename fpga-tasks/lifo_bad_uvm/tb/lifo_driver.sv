class lifo_driver #(
  type T
);
  local mailbox #( T ) gen2drv;
  local mailbox #( T ) drv2scb;
  
  local T trans;
  local virtual lifo_if _if;

  function new(virtual lifo_if _if, mailbox #( T ) gen2drv, mailbox #( T ) drv2scb);
    this.gen2drv   = gen2drv;
    this.drv2scb   = drv2scb;
    this._if       = _if;
    this._if.rdreq = 0;
    this._if.wrreq = 0;
    this._if.data  = $urandom_range(2**32-1, 0);
  endfunction

  task update(T trans);
    this.trans = trans;
  endtask

  task send();
    this.drv2scb.put( this.trans );

    case( this.trans.get_req_type() )
      REQ_EMPTY:
        begin
          this._if.data <= $urandom_range(2**32-1, 0);
        end
      REQ_READ:
        begin
          this._if.rdreq <= 1'b1;
          this._if.data  <= $urandom_range(2**32-1, 0);
        end
      REQ_WRITE:
        begin
          this._if.wrreq <= 1'b1;
          this._if.data  <= this.trans.get_word();
        end
      REQ_RW:
        begin
          this._if.rdreq <= 1'b1;
          this._if.wrreq <= 1'b1;
          this._if.data  <= this.trans.get_word();
        end
      default:
        begin
          `THROW_CRITICAL_ERROR("UNEXPECTED CODE IN DRIVER TRANSACTION");
        end
    endcase

    @( this._if.cb );
    this._if.wrreq <= 1'b0;
    this._if.rdreq <= 1'b0;
    this._if.data  <= $urandom_range(2**32-1, 0);
  endtask

  task run();
    T _trans;

    while (this.gen2drv.num())
      begin
        this.gen2drv.get(_trans);
        this.update(_trans);
        this.send();
      end
  endtask
endclass