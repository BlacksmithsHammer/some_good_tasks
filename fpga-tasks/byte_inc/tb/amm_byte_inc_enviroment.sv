class amm_byte_inc_enviroment #( 
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);

  local amm_byte_inc_generator  #( T ) gen;
  local amm_byte_inc_driver     #( T ) drv;
  local amm_byte_inc_monitor    #( T ) mon;
  local amm_byte_inc_scoreboard #( T ) scb;
  
  mailbox #( T ) gen2drv;
  mailbox #( T ) drv2scb;
  mailbox #( T ) drv2mon;
  mailbox #( T ) mon2scb;

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

  task build(
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
    ) writer_if
  );

    this.settings_if = settings_if;
    this.reader_if   = reader_if;
    this.writer_if   = writer_if;

    this.gen2drv = new(1);
    this.drv2mon = new();
    this.drv2scb = new();
    this.mon2scb = new();

    gen = new(                                                   this.gen2drv                                           );
    drv = new( this.settings_if, this.reader_if, this.writer_if, this.gen2drv, this.drv2mon, this.drv2scb               );
    mon = new( this.settings_if, this.reader_if, this.writer_if,               this.drv2mon,               this.mon2scb );
    scb = new(                                                                               this.drv2scb, this.mon2scb );
  endtask

  task run( test_case _test, 
            string    label);
    $display("Test <%s> is running:", label);
    
    fork
      gen.generate_test(_test);
      drv.run();
      mon.run();
      scb.run();
    join_any


    #1000;
    disable fork;
    #100;
    scb.check_results();
    // scb.reset();

  endtask

endclass