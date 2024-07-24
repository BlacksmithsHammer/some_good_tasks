class lifo_monitor #(type T);
  local mailbox #( T ) mon2scb;
  local virtual lifo_if _if;

  function new(virtual lifo_if _if, mailbox #( T ) mon2scb);
    this.mon2scb   = mon2scb;
    this._if       = _if;
  endfunction

  task run(int time_cycles);
    T tr;
    while(time_cycles)
      begin
        time_cycles = time_cycles - 1;
        @( this._if.cb );
        tr = new(_if);
        mon2scb.put(tr);
      end
  endtask
endclass