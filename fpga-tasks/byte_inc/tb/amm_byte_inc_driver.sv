class amm_byte_inc_driver #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local virtual amm_if reader;
  local virtual amm_if writer;
  local T              trans;

  local mailbox #( T ) gen2drv;
  local mailbox #( T ) drv2scb;

  function new(
      virtual amm_if #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .BYTE_CNT   ( BYTE_CNT   )
      ) reader,

      virtual amm_if #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .BYTE_CNT   ( BYTE_CNT   )
      ) writer,

      mailbox #( T ) gen2drv,
      mailbox #( T ) drv2scb);

    this.reader = reader;
    this.writer = writer;

    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
  endfunction


  task run();
    while(this.gen2drv.num() > 0)
      begin

      end
    
    //waiting to check results after driver
    repeat(100)
      @( this._sink_if.cb );
  endtask 

endclass
