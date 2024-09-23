class ast_dmx_transaction #(
  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH   = $clog2( DATA_WIDTH / 8 ),
  
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);

  logic [CHANNEL_WIDTH-1:0] channel;
  int                       dir;
  // in bytes, not optimized but looks good
  logic [7:0] packet [$];
  // chance of send for driver: [driver -> dut]
  int         chance_send;
  // chance of ready (signal) for driver: [dut -> monitor]
  int         chance_receive;
  // len of pause after send in clocks
  int         pause_after = 0;


  // packet size in bytes from 1 to 65536
  function new(logic [CHANNEL_WIDTH-1:0] channel,
               int                       dir,
               int                       packet_size,
               int                       chance_send,
               int                       chance_receive,
               int                       pause_after);
    this.dir     = dir;
    this.channel = channel;
    for(int i = 0; i < packet_size; i++)
      this.packet.push_back($urandom_range(255, 0));

    this.pause_after    = pause_after;
    this.chance_send    = chance_send;
    this.chance_receive = chance_receive;
  endfunction

  function ast_dmx_transaction #(
    .DATA_WIDTH    ( DATA_WIDTH    ),
    .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
    .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
    .TX_DIR        ( TX_DIR        ),
    .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
  ) copy();
    copy = new(-1, -1, -1, -1, -1, -1);
    copy.dir            = this.dir;
    copy.channel        = this.channel;
    copy.packet         = this.packet;
    copy.chance_send    = this.chance_send;
    copy.chance_receive = this.chance_receive;
  endfunction

  function logic [7:0] get_next_byte();
    return this.packet.pop_front();
  endfunction
  
  // easy way to make custom packets too
  // and compatibility with monitor
  task push_next_byte(logic [7:0] new_byte);
    this.packet.push_back(new_byte);
  endtask

  function int get_pause();
    return this.pause_after;
  endfunction

  function int get_size_of_packet();
    return this.packet.size();
  endfunction

  function int get_dir();
    return this.dir;
  endfunction

  function logic [CHANNEL_WIDTH-1:0] get_channel();
    return this.channel;
  endfunction

  function int get_chance_send();
    return this.chance_send;
  endfunction

  function int get_chance_receive();
    return this.chance_receive;
  endfunction

endclass 