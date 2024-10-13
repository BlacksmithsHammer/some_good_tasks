class amm_byte_inc_monitor #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local mailbox #( T ) drv2mon;
  local mailbox #( T ) mon2scb;

  local virtual byte_inc_set_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) settings_if;

  local virtual amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) reader_if;

  local virtual amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) writer_if;

  function new(    
    virtual byte_inc_set_if #(
      .DATA_WIDTH ( DATA_WIDTH ),
      .ADDR_WIDTH ( ADDR_WIDTH ),
      .BYTE_CNT   ( BYTE_CNT   )
    ) settings_if,

    virtual amm_if #(
      .DATA_WIDTH ( DATA_WIDTH ),
      .ADDR_WIDTH ( ADDR_WIDTH ),
      .BYTE_CNT   ( BYTE_CNT   )
    ) reader_if,

    virtual amm_if #(
      .DATA_WIDTH ( DATA_WIDTH ),
      .ADDR_WIDTH ( ADDR_WIDTH ),
      .BYTE_CNT   ( BYTE_CNT   )
    ) writer_if,

    mailbox #( T ) drv2mon,  
    mailbox #( T ) mon2scb);

    this.settings_if = settings_if;
    this.reader_if   = reader_if;
    this.writer_if   = writer_if;

    this.drv2mon     = drv2mon;
    this.mon2scb     = mon2scb;
  endfunction

  task run();
    while( 1 )
      begin
        
        @( this.settings_if.cb );
      end
  endtask

endclass 
      
