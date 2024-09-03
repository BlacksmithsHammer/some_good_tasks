class ast_dmx_monitor #(
  type T,

  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);
  local virtual ast_dmx_if _sink_if;
  local virtual ast_dmx_if _source_if [TX_DIR-1:0];
  local mailbox #( T )     mon2scb;
  //local T                  trans;
  T   tr       [TX_DIR-1:0];
  int have_sof [TX_DIR-1:0];
  
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

  task start_daemon( int ind_dir );
    $display("start monitoring DIR: %0d", ind_dir);
    while(1)
          begin
            
            // start of packet
            if( this._source_if[ind_dir].valid === 1'b1 && this._source_if[ind_dir].startofpacket === 1'b1 )
              begin
                tr[ind_dir] = new(this._source_if[ind_dir].channel, ind_dir, 0, -1, -1);

                while(1)
                  begin
                    // $display("in packet  ", $time);
                    if( this._source_if[ind_dir].valid === 1'b1 )
                      begin
                        //$display("DIR ", ind_dir, " got valid at: ", $time);
                        if( this._source_if[ind_dir].channel !== tr[ind_dir].get_channel() )
                          begin
                            `SHOW_WRONG_SIGNALS(tr[ind_dir].get_channel(), 
                                                this._source_if[ind_dir].channel, 
                                                $sformatf("MONITOR DIR %0d: source channel wrong", ind_dir));
                          end

                        if( this._source_if[ind_dir].startofpacket === 1'b1 && have_sof[ind_dir] == 1 )
                          begin
                            // if early get a sof in one packet
                            `SHOW_WRONG_SIGNALS(0, 1, $sformatf("MONITOR DIR %0d: source start_of_packet wrong", ind_dir));
                            // (?) break;
                          end
      
                        if( this._source_if[ind_dir].startofpacket === 1'b1 && have_sof[ind_dir] == 0 )
                          begin
                            // $display("got sof ", $time);
                            have_sof[ind_dir] = 1;
                          end

                        if( this._source_if[ind_dir].endofpacket === 1'b1 && have_sof[ind_dir] == 0 )
                          begin
                            `SHOW_WRONG_SIGNALS(0, 1, $sformatf("MONITOR DIR %0d: source end_of_packet wrong", ind_dir));
                          end
                        
                        if( this._source_if[ind_dir].endofpacket === 1'b1 && have_sof[ind_dir] == 1 )
                          begin
                            //$display("DIR ", ind_dir, " got EOP packet");
                            for (int i = 0; i < DATA_WIDTH/8 - this._source_if[ind_dir].empty; i++) 
                              begin
                                tr[ind_dir].push_next_byte(this._source_if[ind_dir].data[i*8 +: 8]);
                                have_sof[ind_dir] = 0;
                              end

                            break;
                          end

                        if( this._source_if[ind_dir].endofpacket === 1'b0 && have_sof[ind_dir] == 1 )
                          begin
                            for (int i = 0; i < DATA_WIDTH/8; i++) 
                              begin
                                tr[ind_dir].push_next_byte(this._source_if[ind_dir].data[i*8 +: 8]);
                              end
                          end
                      end

                      //$display("DIR ", ind_dir, " valid at: ", $time, "  ", this._source_if[ind_dir].valid);

                    @( this._sink_if.cb );
                  end

                //$display("DIR ", ind_dir, " received packet");
                mon2scb.put(tr[ind_dir]);
                // while(tr[ind_dir].get_size_of_packet() > 0)
                //   $display("%x", tr[ind_dir].get_next_byte());
              end

            // $display("out of packet  ", $time);
            @( this._sink_if.cb );
          end
  endtask

  task run();
      for(int ind_dir = 0; ind_dir < 3; ind_dir++)
        begin
          automatic int _ind_dir = ind_dir;
          fork
            start_daemon(_ind_dir);
          join_none
        end
  endtask

endclass 














      