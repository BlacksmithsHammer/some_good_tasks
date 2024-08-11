class ast_we_driver #(
  type T                = ast_we_transaction,

  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  local virtual ast_we_if _if
  lcoal T                 trans;
  local mailbox #( T )    gen2drv;
  local mailbox #( T )    drv2scb;

  function new( virtual ast_we_if _if;
                mailbox #( T ) gen2drv,
                mailbox #( T ) drv2scb);
    this._if     = _if;
    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
  endfunction

  task send_packet();
    this.drv2scb.put(trans);
  endtask

  task run();
    
  endtask

endclass