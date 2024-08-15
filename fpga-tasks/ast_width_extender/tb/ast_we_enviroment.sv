class ast_we_enviroment #( 
  type T
);

  local ast_we_generator  #( T ) gen;
  local ast_we_driver     #( T ) drv;
  local ast_we_monitor    #( T ) mon;
  local ast_we_scoreboard #( T ) scb;
  
  mailbox #( T ) gen2drv;
  mailbox #( T ) drv2scb;
  mailbox #( T ) mon2scb;

  local virtual ast_we_if _if;
  
  
  task build(virtual ast_we_if _if);
    this._if = _if;

    this.gen2drv = new(1);
    this.drv2scb = new();
    this.mon2scb = new();

    gen = new(      this.gen2drv               );
    drv = new( _if, this.gen2drv, this.drv2scb );
    mon = new( _if,               this.mon2scb );
    scb = new( _if, this.drv2scb, this.mon2scb );
  endtask

  task run( test_case _test, 
            string    label );
    $display("Test <%s> is running:", label);
    // gen.generate_test(_test);

    fork
      
    join_none

    $display("NEXT", $time);
    
    fork
      gen.generate_test(_test);
      drv.run();
      mon.run();
      scb.run();
    join_any
    $display("NEXT 2 ", $time);
    // check for unexpected situations after end of driver stimulus
    scb.check_remaining_packets();
    // disable fork;
  endtask

endclass