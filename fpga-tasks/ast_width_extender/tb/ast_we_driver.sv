class ast_we_driver #(
  type T,

  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  local virtual ast_we_if  _if;
  local T                  trans;
  local mailbox #( T )     gen2drv;
  local mailbox #( T )     drv2scb;

  function new( virtual ast_we_if _if,
                mailbox #( T ) gen2drv,
                mailbox #( T ) drv2scb);
    this._if     = _if;
    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
  endfunction

  task get_next_packet();
    this.gen2drv.get(this.trans);
    this.drv2scb.put(this.trans);
  endtask

  task fill_word(int type_filling);
    // fill with wrong data
    if( type_filling == -1 )
      begin
        for(int i = 0; i < DATA_IN_W/8; i++)
          begin
            this._if.sink_data[i*8 +: 8] <= $urandom_range(255, 0);
          end
      end

    // do nothing, save old word
    if( type_filling == 0 )
      begin

      end
    
    // fill word correctly
    if( type_filling == 1 )
      begin
        for(int i = 0; i < DATA_IN_W/8; i++)
          begin
            if( this.trans.get_size_of_packet() > 0 )
              this._if.sink_data[i*8 +: 8] <= this.trans.get_next_byte();
            else
              this._if.sink_data[i*8 +: 8] <= $urandom_range(255, 0);
          end
      end
  endtask

  task send_packet();
    int need_send_sof = 1;
    while( this.trans.get_size_of_packet() > 0 )
      begin
        if( $urandom_range(99, 0) < this.trans.get_chance_receive() )
          begin
            this._if.source_ready <= 1'b1;
          end
        else
          begin
            this._if.source_ready <= 1'b0;
          end

        if( this._if.sink_ready == 1'b1 && $urandom_range(99, 0) < this.trans.get_chance_send() )
          begin
            if( trans.get_size_of_packet() >= DATA_IN_W/8 )
              begin
                this._if.sink_empty <= '0;
              end
            else
              begin
                this._if.sink_empty <= (DATA_IN_W/8 - trans.get_size_of_packet());
              end

            fill_word(1);

            if( need_send_sof == 1 )
              begin
                this._if.sink_startofpacket <= 1'b1;
                need_send_sof = 0;
              end
            else
              begin
                this._if.sink_startofpacket <= 1'b0;
              end

            if( trans.get_size_of_packet() == 0 )
              begin
                this._if.sink_endofpacket <= 1'b1;
              end
            else
              begin
                this._if.sink_endofpacket <= 1'b0;
              end

            this._if.sink_channel <= trans.get_channel();
            this._if.sink_valid   <= 1'b1;
          end
        else
          begin
            fill_word(-1);
            this._if.sink_startofpacket <= $urandom_range(1, 0);
            this._if.sink_endofpacket   <= $urandom_range(1, 0);
            this._if.sink_valid         <= 1'b0;
            this._if.sink_empty         <= $urandom_range(2**32 - 1, 0);
            this._if.sink_channel       <= $urandom_range(2**32 - 1, 0);
          end
        @( this._if.cb );
      end

    fill_word(-1);
    this._if.sink_startofpacket <= $urandom_range(1, 0);
    this._if.sink_endofpacket   <= $urandom_range(1, 0);
    this._if.sink_valid         <= 1'b0;
    this._if.sink_empty         <= $urandom_range(2**32 - 1, 0);
    this._if.sink_channel       <= $urandom_range(2**32 - 1, 0);

    // this._if.source_ready       <= 1'b0;
    // $display("end send at ", $time);
  endtask

  task run();
    while(this.gen2drv.num() > 0)
      begin
        get_next_packet();
        send_packet();
      end
  endtask 

endclass