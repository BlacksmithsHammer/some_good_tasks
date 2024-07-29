class lifo_scoreboard #(
  type T_from_generator,
  type T_from_monitor,
  parameter int DWIDTH       = 16,
  parameter int AWIDTH       = 8,
  parameter int ALMOST_FULL  = 2,
  parameter int ALMOST_EMPTY = 2
);
  local virtual lifo_if _if;
  local mailbox #( T_from_generator ) gen2scb;
  local mailbox #( T_from_monitor   ) mon2scb;
  local T_from_generator t_gen;
  local T_from_monitor   t_mon;

  function new( virtual lifo_if _if,
                mailbox #( T_from_generator ) gen2scb,
                mailbox #( T_from_monitor   ) mon2scb);
    this._if     = _if;
    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    int count_err = 0;
    logic [DWIDTH-1:0] lifo_queue [$:2**AWIDTH];
    logic [DWIDTH-1:0] last_word = 'x;

    // check after-initial values
    mon2scb.get(t_mon);
    // write with operands to better style
    // ( t_mon.get_empty() ) - not good to read
    if( t_mon.get_empty()        !== 1 ) 
      `SHOW_WRONG_SIGNALS(1, 0, "wrong empty_o");
    // if( t_mon.get_word() ) - not necessary
    // skip conditions for almost_...
    if( t_mon.get_almost_empty() !== 1 ) 
      `SHOW_WRONG_SIGNALS(1'b1, t_mon.get_almost_empty(), "wrong almost_empty_o");

    if( t_mon.get_almost_full()  !== 0 ) 
      `SHOW_WRONG_SIGNALS(1'b0, t_mon.get_almost_full(),  "wrong almost_full_o");

    if( t_mon.get_full()         !== 0 ) 
      `SHOW_WRONG_SIGNALS(1'b0, t_mon.get_full(),         "wrong full_o");

    if( t_mon.get_usedw()        !== 0 ) 
      `SHOW_WRONG_SIGNALS(1'b0, t_mon.get_usedw(),        "wrong usedw_o");
    
    // main comparing
    while(1)
      begin
        gen2scb.get(t_gen);
        mon2scb.get(t_mon);

        if( t_gen.get_req_type() == REQ_EMPTY)
          begin
            // empty
          end

        if( t_gen.get_req_type() == REQ_READ )
          begin
            if( lifo_queue.size() != 0 )
              last_word = lifo_queue.pop_back(); 
          end

        if( t_gen.get_req_type() == REQ_WRITE )
          begin
            if( lifo_queue.size() < 2**AWIDTH )
              lifo_queue.push_back(t_gen.get_word());
          end

        if( t_gen.get_req_type() == REQ_RW)
          begin
            // read part
            if( lifo_queue.size() != 0 )
              last_word = lifo_queue.pop_back();

            // write part
            // 2**AWIDTH __-1__ - to DONT write after read in ONE cycle
            // if before read LIFO full
            if( lifo_queue.size() < 2**AWIDTH - 1 )
              lifo_queue.push_back(t_gen.get_word());
          end

        if( last_word !== t_mon.get_word() )
          `SHOW_WRONG_SIGNALS(last_word, t_mon.get_word(), 
                               "wrong q_o");
        
        if( (lifo_queue.size() >  ALMOST_EMPTY ) === ( t_mon.get_almost_empty() ) )
          `SHOW_WRONG_SIGNALS(!t_mon.get_almost_empty(), 
                               t_mon.get_almost_empty(), 
                               "wrong almost_empty_o");

        if( (lifo_queue.size() < ALMOST_FULL  ) === ( t_mon.get_almost_full() ) )
          `SHOW_WRONG_SIGNALS(!t_mon.get_almost_full(), 
                               t_mon.get_almost_full(), 
                               "wrong almost_full_o");

        if( lifo_queue.size() !== t_mon.get_usedw() )
          `SHOW_WRONG_SIGNALS( lifo_queue.size(), 
                               t_mon.get_usedw(), 
                               "wrong usedw_o");

        if( lifo_queue.size() == 0 && !t_mon.get_empty() )
           `SHOW_WRONG_SIGNALS( t_mon.get_empty(), 
                               !t_mon.get_empty(), 
                               "wrong empty_o");
        
        if( lifo_queue.size() == 2**AWIDTH && !t_mon.get_full() )
          `SHOW_WRONG_SIGNALS(  t_mon.get_full(), 
                               !t_mon.get_full(), 
                               "wrong full_o");

        @( this._if.cb );
      end
  endtask
endclass