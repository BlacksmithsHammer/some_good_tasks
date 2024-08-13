class ast_we_transaction #(
  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  local logic [CHANNEL_W-1:0] channel;
  // in bytes, not optimized but looks good
  local logic [7:0] packet [$];
  // chance of send for driver: [driver -> dut]
  local int         chance_send;
  // chance of ready (signal) for driver: [dut -> monitor]
  local int         chance_receive;

  // packet size in bytes from 1 to 65536
  function new(logic [CHANNEL_W-1:0] channel,
               int                   packet_size,
               int                   chance_send,
               int                   chance_receive);
    this.channel = channel;
    for(int i = 0; i < packet_size; i++)
      this.packet.push_back($urandom_range(255, 0));

    this.chance_send    = chance_send;
    this.chance_receive = chance_receive;
  endfunction

  function logic [7:0] get_next_byte();
    return this.packet.pop_front();
  endfunction
  
  // easy way to make custom packets too
  // and compatibility with monitor
  task push_next_byte(logic [7:0] new_byte);
    this.packet.push_back(new_byte);
  endtask

  function int get_size_of_packet();
    return this.packet.size();
  endfunction

  function logic [CHANNEL_W-1:0] get_channel();
    return this.channel;
  endfunction

  function int get_chance_send();
    return this.chance_send;
  endfunction

  function int get_chance_receive();
    return this.chance_receive;
  endfunction

endclass 