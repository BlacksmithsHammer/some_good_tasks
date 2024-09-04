class ast_dmx_enviroment #( 
  type T,

  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);

  local ast_dmx_generator  #( T ) gen;
  local ast_dmx_driver     #( T ) drv;
  local ast_dmx_monitor    #( T ) mon;
//   local ast_dmx_scoreboard #( T ) scb;
  
  mailbox #( T ) gen2drv;
  mailbox #( T ) drv2scb;
  mailbox #( T ) mon2scb;

  local virtual ast_dmx_if #(
    .DATA_WIDTH    ( DATA_WIDTH    ),
    .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
    .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
    .TX_DIR        ( TX_DIR        ),
    .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
  ) _sink_if;

  local virtual ast_dmx_if #(
    .DATA_WIDTH    ( DATA_WIDTH    ),
    .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
    .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
    .TX_DIR        ( TX_DIR        ),
    .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
  ) _source_if [TX_DIR-1:0];
  
  task build(
    virtual ast_dmx_if #(
      .DATA_WIDTH    ( DATA_WIDTH    ),
      .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
      .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
      .TX_DIR        ( TX_DIR        ),
      .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
    ) _sink_if,

    virtual ast_dmx_if #(
      .DATA_WIDTH    ( DATA_WIDTH    ),
      .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
      .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
      .TX_DIR        ( TX_DIR        ),
      .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
    ) _source_if [TX_DIR-1:0]
  );

    this._sink_if   = _sink_if;
    this._source_if = _source_if;

    this.gen2drv = new(1);
    this.drv2scb = new();
    this.mon2scb = new();

    gen = new(                          this.gen2drv                             );
    drv = new( _sink_if, _source_if,    this.gen2drv, this.drv2scb               );
    mon = new( _sink_if, _source_if,                                this.mon2scb );
    // scb = new( _sink_if, _source_if, this.drv2scb, this.mon2scb );
  endtask

  task run( test_case _test, 
            string    label );
    $display("Test <%s> is running:", label);
    
    fork
      gen.generate_test(_test);
      drv.run();
      mon.run();
      //scb.run();
    join_any
    
    // check for unexpected situations after end of driver stimulus
    // scb.check_remaining_packets();
    // disable fork;
  endtask

endclass