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
  
  
  task build(virtual ast_we_if _if);
    gen2drv = new();
    drv2scb = new();
    mon2scb = new();

    gen = new(      gen2drv          );
    drv = new( _if, gen2drv, drv2scb );
    mon = new( _if,          mon2scb );
    scb = new( _if, drv2scb, mon2scb );
  endtask

  task run( test_case _test, 
            string    label );
    $display("Test <%s> is running:", label);
    gen.generate_test(_test);
    fork
      drv.run();
      mon.run();
      scb.run();
    join_any

    // need to work monitor
    // disable fork;
  endtask

endclass