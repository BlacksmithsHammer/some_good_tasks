class ast_we_monitor #(
  type T,

  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  local virtual ast_we_if  _if;
  local mailbox #( T )     mon2scb;

  function new( virtual ast_we_if _if, 
                mailbox #( T ) mon2scb);
    this._if     = _if;
    this.mon2scb = mon2scb;
  endfunction

  function int get_num_packets();
    return mon2scb.num();
  endfunction

  task run();
    int have_problems_sof     = 0;
    int have_problems_eof     = 0;
    int have_problems_channel = 0;

    T tr;
    int have_sof = 0;
    while(1)
      begin
        // start of packet
        if( this._if.source_valid === 1'b1 && this._if.source_startofpacket === 1'b1 )
          begin
            tr = new(this._if.source_channel, 0, -1, -1);

            while(1)
              begin
                // $display("in packet  ", $time);
                if( this._if.source_valid === 1'b1 )
                  begin
                    if( this._if.source_channel !== tr.get_channel() )
                      begin
                        `SHOW_WRONG_SIGNALS(tr.get_channel(), 
                                            this._if.source_channel, 
                                            "MONITOR: source channel wrong");
                      end

                    if( this._if.source_startofpacket === 1'b1 && have_sof == 1 )
                      begin
                        // if early get a sof in one packet
                        `SHOW_WRONG_SIGNALS(0, 1, "MONITOR: source start_of_packet wrong");
                        // (?) break;
                      end
  
                    if( this._if.source_startofpacket === 1'b1 && have_sof == 0 )
                      begin
                        // $display("got sof ", $time);
                        have_sof = 1;
                      end

                    if( this._if.source_endofpacket === 1'b1 && have_sof == 0 )
                      begin
                        `SHOW_WRONG_SIGNALS(0, 1, "MONITOR: source end_of_packet wrong");
                      end
                    
                    if( this._if.source_endofpacket === 1'b1 && have_sof == 1 )
                      begin
                        for (int i = 0; i < DATA_OUT_W/8 - this._if.source_empty; i++) 
                          begin
                            tr.push_next_byte(this._if.source_data[i*8 +: 8]);
                            have_sof = 0;
                          end

                        break;
                      end

                    if( this._if.source_endofpacket === 1'b0 && have_sof == 1 )
                      begin
                        for (int i = 0; i < DATA_OUT_W/8; i++) 
                          begin
                            tr.push_next_byte(this._if.source_data[i*8 +: 8]);
                          end
                      end
                  end
                @( this._if.cb );
              end
            
            $display("size of packet: ", tr.get_size_of_packet());
            mon2scb.put(tr);
            // while(tr.get_size_of_packet() > 0)
            //   $display("%x", tr.get_next_byte());
          end

        // $display("out of packet  ", $time);
        @( this._if.cb );
      end

  endtask

endclass 