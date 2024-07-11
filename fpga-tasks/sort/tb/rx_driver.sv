class RX_driver #(
  int DWIDTH      = 8,
  int MAX_PKT_LEN = 32
);
  /////////////////////////////////////////////////////////
  // local fields
  /////////////////////////////////////////////////////////
  local virtual avst_if if_ins;
  local int size_pkt;
  local logic [DWIDTH-1:0] pkt [$:MAX_PKT_LEN-1];

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
    this.if_ins = if_ins;
    this.if_ins.ready = 1'b1;
  endfunction
  
  task receive_packet();
    while( !( this.if_ins.endofpacket && this.if_ins.valid ) )
      begin
        if( this.if_ins.valid )
          begin
            this.pkt.push_back(this.if_ins.data);
        
            if( !this.if_ins.startofpacket && pkt.size() == 1 )
                throw_err("WRONG AVALON-ST SIGNALS");
        
            if( this.if_ins.startofpacket && pkt.size() != 1 )
              throw_err("WRONG AVALON-ST SIGNALS");
            
            if( this.pkt.size() > MAX_PKT_LEN)
              throw_err("PACKET MORE THAN MAX_PKT_LEN");
          end
        @( this.if_ins.cb );

      end

    // get last element skipped in while
    pkt.push_back(this.if_ins.data);
    this.size_pkt = pkt.size();

    if( this.if_ins.startofpacket )
      throw_err("WRONG AVALON-ST SIGNALS");

  endtask

  function int get_sizeofpkt();
    get_sizeofpkt = size_pkt;
  endfunction

  function logic [DWIDTH-1:0] get_nextelement();
    get_nextelement = pkt.pop_front();
  endfunction
endclass