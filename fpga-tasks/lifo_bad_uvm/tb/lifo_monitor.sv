class lifo_monitor #(type T);
  local mailbox #( T ) mon2scb;
  local virtual lifo_if _if;

  function new(virtual lifo_if _if, mailbox #( T ) mon2scb);
    this.mon2scb   = mon2scb;
    this._if       = _if;
  endfunction

  task run();
    T tr;
    while(1)
      begin
        tr = new(_if);
        mon2scb.put(tr);
        @( this._if.cb );
      end
  endtask
endclass