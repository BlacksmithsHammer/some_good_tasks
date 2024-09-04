class ast_dmx_driver #(
  type T,

  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);
  local virtual ast_dmx_if _sink_if;
  local virtual ast_dmx_if _source_if [TX_DIR-1:0];
  local T                  trans;

  local mailbox #( T )     gen2drv;
  local mailbox #( T )     drv2scb;

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

      mailbox #( T ) gen2drv,
      mailbox #( T ) drv2scb);

    this._sink_if     = _sink_if;
    this._source_if   = _source_if;

    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
  endfunction


  task fill_word(int type_filling);
    // fill with wrong data
    // may be need change to 'x
    if( type_filling == -1 )
      begin
        for(int i = 0; i < DATA_WIDTH/8; i++)
          begin
            this._sink_if.data[i*8 +: 8] <= $urandom_range(255, 0);
          end
      end

    // do nothing, save old word
    if( type_filling == 0 )
      begin

      end
    
    // fill word correctly
    if( type_filling == 1 )
      begin
        for(int i = 0; i < DATA_WIDTH/8; i++)
          begin
            if( this.trans.get_size_of_packet() > 0 )
              this._sink_if.data[i*8 +: 8] <= this.trans.get_next_byte();
            else
              this._sink_if.data[i*8 +: 8] <= $urandom_range(255, 0);
          end
      end
  endtask

  task send_packet();
    int need_send_sof = 1;
    while( this.trans.get_size_of_packet() > 0 )
      begin
        if( $urandom_range(99, 0) < this.trans.get_chance_receive() )
          begin
            for( int i = 0; i < TX_DIR; i++ )
              this._source_if[i].ready <= 1'b1;
          end
        else
          begin
            for( int i = 0; i < TX_DIR; i++ )
              this._source_if[i].ready <= 1'b0;
          end

        if( this._sink_if.ready === 1'b1 && $urandom_range(99, 0) < this.trans.get_chance_send() )
          begin
            if( trans.get_size_of_packet() > DATA_WIDTH/8 )
              begin
                this._sink_if.empty <= $urandom_range(2**32 - 1, 0);
              end
            else
              if( trans.get_size_of_packet() == DATA_WIDTH/8 )
                begin
                  this._sink_if.empty <= '0;
                end
              else
                begin
                  this._sink_if.empty <= (DATA_WIDTH/8 - trans.get_size_of_packet());
                end

            fill_word(1);

            if( need_send_sof == 1 )
              begin
                this._sink_if.startofpacket <= 1'b1;
                this._sink_if.dir           <= trans.get_dir();
                need_send_sof = 0;
              end
            else
              begin
                this._sink_if.startofpacket <= 1'b0;
                this._sink_if.dir           <= $urandom_range(2**32 - 1, 0);
              end

            if( trans.get_size_of_packet() == 0 )
              begin
                this._sink_if.endofpacket <= 1'b1;
              end
            else
              begin
                this._sink_if.endofpacket <= 1'b0;
              end

            this._sink_if.channel <= trans.get_channel();
            this._sink_if.valid   <= 1'b1;
          end
        else
          begin
            fill_word(-1);
            this._sink_if.dir           <= $urandom_range(2**32 - 1, 0);
            this._sink_if.startofpacket <= $urandom_range(1, 0);
            this._sink_if.endofpacket   <= $urandom_range(1, 0);
            this._sink_if.valid         <= 1'b0;
            this._sink_if.empty         <= $urandom_range(2**32 - 1, 0);
            this._sink_if.channel       <= $urandom_range(2**32 - 1, 0);
          end
        @( this._sink_if.cb );
      end

    fill_word(-1);
    this._sink_if.dir           <= $urandom_range(2**32 - 1, 0);
    this._sink_if.startofpacket <= $urandom_range(1, 0);
    this._sink_if.endofpacket   <= $urandom_range(1, 0);
    this._sink_if.valid         <= 1'b0;
    this._sink_if.empty         <= $urandom_range(2**32 - 1, 0);
    this._sink_if.channel       <= $urandom_range(2**32 - 1, 0);
    
    // wait to check after-driver work


    // this._if.source_ready       <= 1'b0;
    // $display("end send at ", $time);
  endtask

  task run();
    while(this.gen2drv.num() > 0)
      begin
        this.gen2drv.get(this.trans);
        // save copy to scoreboard
        // necessary if earlier than send because order 
        // of packets in error situation destructed
        this.drv2scb.put(this.trans.copy());
        send_packet();
      end
    
    //waiting to check results after driver
    repeat(100)
      @( this._sink_if.cb );

    ///////////////////////////////////////////////////
    // demonstrate problems
    ///////////////////////////////////////////////////
    repeat(100)
      begin
      end
    
    repeat(100)
      begin
      end
    ///////////////////////////////////////////////////
  endtask 

endclass