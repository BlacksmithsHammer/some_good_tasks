class ast_we_scoreboard #(
  type T,

  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  local mailbox #( T )     drv2scb;
  local mailbox #( T )     mon2scb;
  local virtual ast_we_if  _if;
  local T tr_drv;
  local T tr_mon;

  function new( virtual ast_we_if _if,
                mailbox #( T ) drv2scb,
                mailbox #( T ) mon2scb);
    this._if     = _if;
    this.drv2scb = drv2scb;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    logic [7:0] last_byte_mon;
    logic [7:0] last_byte_drv;

    while(1)
      begin
        this.drv2scb.get(tr_drv);
        this.mon2scb.get(tr_mon);
        if( tr_drv.get_channel() != tr_mon.get_channel() )
          begin
            `SHOW_WRONG_SIGNALS(tr_drv.get_channel(),
                                tr_mon.get_channel(),
                                "SCOREBOARD: DIFFERENT CHANNEL");
          end

        if( tr_drv.get_size_of_packet() != tr_mon.get_size_of_packet() )
          begin
            `SHOW_WRONG_SIGNALS(tr_drv.get_size_of_packet(),
                                tr_mon.get_size_of_packet(),
                                "SCOREBOARD: DIFFERENT BETWEEN PACKET SIZE");
          end
        else
          begin
            while(tr_drv.get_size_of_packet() > 0)
              begin
                last_byte_mon = tr_mon.get_next_byte();
                last_byte_drv = tr_drv.get_next_byte();

                if(last_byte_mon != last_byte_drv)
                  `SHOW_WRONG_SIGNALS(last_byte_drv,
                                      last_byte_mon,
                                      "SCOREBOARD: DIFFERENT BETWEEN DATA VALUE");
              end
          end
        @( this._if.cb );
      end
  endtask

endclass