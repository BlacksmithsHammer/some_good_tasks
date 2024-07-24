class lifo_scoreboard #(
  type T_from_generator,
  type T_from_monitor
);
  local mailbox #( T_from_generator ) gen2scb;
  local mailbox #( T_from_monitor   ) mon2scb;

  function new( mailbox #( T_from_generator ) gen2scb,
                mailbox #( T_from_monitor   ) mon2scb);
    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;
  endfunction
endclass