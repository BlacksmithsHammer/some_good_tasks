class ast_dmx_monitor #(
  type T,

  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);
  local int end_of_run = 0;
  local virtual ast_dmx_if _sink_if;
  local virtual ast_dmx_if _source_if [TX_DIR-1:0];
  local mailbox #( T )     mon2scb;

  function new(       
      virtual ast_dmx_if #(
        .DATA_WIDTH    ( DATA_WIDTH    ),
        .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
        .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
        .TX_DIR        ( TX_DIR        ),
        .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
      ) _sink_if ,

      virtual ast_dmx_if #(
        .DATA_WIDTH    ( DATA_WIDTH    ),
        .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
        .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
        .TX_DIR        ( TX_DIR        ),
        .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
      ) _source_if [TX_DIR-1:0],
      
      mailbox #( T ) mon2scb);

    this._sink_if   = _sink_if;
    this._source_if = _source_if;

    this.mon2scb = mon2scb;
  endfunction

  function int get_num_packets();
    return mon2scb.num();
  endfunction

  task run_daemon_mon_if( 
    virtual ast_dmx_if #(
        .DATA_WIDTH    ( DATA_WIDTH    ),
        .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
        .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
        .TX_DIR        ( TX_DIR        ),
        .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
    ) _source_if,
    int ind_dir );

    T tr;
    int have_sof = 0;

    $display("start monitoring DIR: %0d", ind_dir);
    while(1)
      begin
        @(_source_if.cbo);

        if( _source_if.cbo.valid === 1'b1 )
          begin
            tr = new(_source_if.cbo.channel, ind_dir, 0, -1, -1, -1);
            while(1)
              begin
                if( _source_if.cbo.valid === 1'b1 )
                  begin
                    if( _source_if.cbo.channel !== tr.get_channel() )
                      begin
                        `SHOW_WRONG_SIGNALS(tr.get_channel(), 
                                            _source_if.cbo.channel, 
                                            "MONITOR: source channel wrong");
                      end

                    if( _source_if.cbo.startofpacket === 1'b1 && have_sof == 1 )
                      begin
                        // if early get a sof in one packet
                        `SHOW_WRONG_SIGNALS(0, 1, "MONITOR: source start_of_packet wrong");
                        // (?) break;
                      end
  
                    if( _source_if.cbo.startofpacket === 1'b1 && have_sof == 0 )
                      begin
                        have_sof = 1;
                      end

                    if( _source_if.cbo.endofpacket === 1'b1 && have_sof == 0 )
                        `SHOW_WRONG_SIGNALS(0, 1, "MONITOR: source end_of_packet wrong");

                    
                    if( _source_if.cbo.endofpacket === 1'b1 && have_sof == 1 )
                      begin
                        for (int i = 0; i < DATA_WIDTH/8 - _source_if.cbo.empty; i++) 
                          begin
                            tr.push_next_byte(_source_if.cbo.data[i*8 +: 8]);
                            have_sof = 0;
                          end
                        break;
                      end

                    if( _source_if.cbo.endofpacket === 1'b0 && have_sof == 1 )
                      for (int i = 0; i < DATA_WIDTH/8; i++) 
                          tr.push_next_byte(_source_if.cbo.data[i*8 +: 8]);
                  end

                @(_source_if.cbo);
              end
            //$display("Dir %0d got packet at %d", ind_dir, $time);
            $display("Got packet with size=%d", tr.get_size_of_packet());
            this.mon2scb.put(tr);
          end
      end
  endtask

  task run();
    for(int ind_dir = 0; ind_dir < TX_DIR; ind_dir++)
     begin
       automatic int _ind_dir = ind_dir;
       fork
          run_daemon_mon_if(this._source_if[_ind_dir], _ind_dir);
       join_none
     end
    
    wait(end_of_run);
  endtask

endclass 
      
