class lifo_enviroment #( 
  type T_from_generator, 
  type T_from_monitor
);
  local lifo_generator  #( T_from_generator                 ) gen;
  local lifo_driver     #( T_from_generator                 ) drv;
  local lifo_monitor    #(                   T_from_monitor ) mon;
  local lifo_scoreboard #( T_from_generator, T_from_monitor ) scb;
  
  mailbox #( T_from_generator   ) gen2drv;
  mailbox #( T_from_generator   ) drv2scb;
  mailbox #( T_from_monitor     ) mon2scb;
  
  
  task build(virtual lifo_if _if);
    gen2drv = new();
    drv2scb = new();
    mon2scb = new();

    gen = new(      gen2drv          );
    drv = new( _if, gen2drv, drv2scb );
    mon = new( _if,          mon2scb );
    scb = new(      drv2scb, mon2scb );
  endtask

  task run(test_case _test);
    gen.generate_test(_test);
    drv.run();
  endtask

endclass