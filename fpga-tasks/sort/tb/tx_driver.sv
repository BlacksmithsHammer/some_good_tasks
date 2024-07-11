class TX_driver #(
  parameter DWIDTH,
  parameter MAX_PKT_LEN
);
  /////////////////////////////////////////////////////////
  // local fields
  /////////////////////////////////////////////////////////
  local virtual avst_if if_ins;
  local logic [DWIDTH-1:0] pkt[];
  local bit have_pkt;

  local task throw_err(string msg);
    $error(msg, $time);
    $stop();
  endtask

  /////////////////////////////////////////////////////////
  // public fields
  /////////////////////////////////////////////////////////
  function new(
    virtual avst_if if_ins
  );
    this.have_pkt = 0;
    this.if_ins = if_ins;
    this.if_ins.data          <=   '0;
    this.if_ins.startofpacket <= 1'b0;
    this.if_ins.endofpacket   <= 1'b0;
    this.if_ins.valid         <= 1'b0;
  endfunction

  task set_pkt( logic [DWIDTH-1:0] pkt_i[] );
    if( pkt_i.size() > MAX_PKT_LEN || pkt_i.size() < 2)
      begin
        $error("WRONG PACKET LENGTH IN TX DRIVER ", $time);
        $stop();
      end
    this.pkt = pkt_i;
    this.have_pkt = 1;
  endtask

  task send( int chance_of_send_valid );
    int i = 0;
    if( !this.have_pkt )
      throw_err("HAVNT PACKETS IN TX BUFFER ");
    if( chance_of_send_valid < 1 || chance_of_send_valid > 100 )
      throw_err("WRONG CHANCE IN TASK CHANCE_OF_SEND_VALID IN TIME ");
    
    wait(this.if_ins.ready);

    while(i < this.pkt.size())
      if( $urandom_range(0, 99) < chance_of_send_valid)
        begin
          this.if_ins.data          <= this.pkt[i];
          this.if_ins.valid         <= 1'b1;
          this.if_ins.startofpacket <= ( i == 0                   );
          this.if_ins.endofpacket   <= ( i == this.pkt.size() - 1 );
          i = i + 1;
          @( this.if_ins.cb );
        end
      else
        begin
          this.if_ins.data          <= $urandom_range(2**32-1, 0);
          this.if_ins.valid         <= 1'b0;
          this.if_ins.startofpacket <= 1'b0;
          this.if_ins.endofpacket   <= 1'b0;
          @( this.if_ins.cb );
        end
    this.if_ins.valid         <= 1'b0;
    this.if_ins.startofpacket <= 1'b0;
    this.if_ins.endofpacket   <= 1'b0;
    this.have_pkt = 0;
  endtask

endclass
