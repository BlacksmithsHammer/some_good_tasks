class lifo_enviroment #( 
  type T
);
  local lifo_generator  #( T ) gen;
  local lifo_driver     #( T ) drv;
  // local lifo_monitor    #(                   T_from_monitor ) mon;
  // local lifo_scoreboard #( T_from_generator, T_from_monitor ) scb;
  
  mailbox #( T_from_generator   ) gen2drv;
  mailbox #( T_from_generator   ) drv2scb;
  // mailbox #( T_from_monitor     ) mon2scb;
  
  
  task build(virtual lifo_if _if);
    gen2drv = new();
    drv2scb = new();
    // mon2scb = new();

    gen = new(      gen2drv          );
    drv = new( _if, gen2drv, drv2scb );
    // mon = new( _if,          mon2scb );
    // scb = new( _if, drv2scb, mon2scb );
  endtask

  task run( test_case _test, 
            string    label );
    $display("Test <%s> is running:", label);
    gen.generate_test(_test);
    fork
      drv.run();
      // mon.run();
      // scb.run();
    join_any
    disable fork;
  endtask

endclass