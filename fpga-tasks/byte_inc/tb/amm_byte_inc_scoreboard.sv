class amm_byte_inc_scoreboard #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local mailbox #( T ) drv2scb;
  local mailbox #( T ) mon2scb;

  local T tr_drv;
  local T tr_mon;

  function new( mailbox #( T ) drv2scb,
                mailbox #( T ) mon2scb);

    this.drv2scb = drv2scb;
    this.mon2scb = mon2scb;
  endfunction



  task reset();
    while (this.drv2scb.try_get(tr_drv)) begin end
    while (this.mon2scb.try_get(tr_mon)) begin end
  endtask

  task run();

  endtask

endclass