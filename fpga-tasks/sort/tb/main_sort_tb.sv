class TX_driver #(
  parameter DWIDTH      = 8,
  parameter MAX_PKT_LEN = 16
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
    if( pkt_i.size() > MAX_PKT_LEN)
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
          @( posedge this.if_ins.clk );
        end
      else
        begin
          this.if_ins.data          <= $urandom_range(2**32-1, 0);
          this.if_ins.valid         <= 1'b0;
          this.if_ins.startofpacket <= 1'b0;
          this.if_ins.endofpacket   <= 1'b0;
          @( posedge this.if_ins.clk );
        end
    this.if_ins.valid         <= 1'b0;
    this.if_ins.startofpacket <= 1'b0;
    this.if_ins.endofpacket   <= 1'b0;
    this.have_pkt = 0;
  endtask

endclass


class RX_driver #(
  parameter DWIDTH      = 8,
  parameter MAX_PKT_LEN = 16
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
        @( posedge this.if_ins.clk );

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


module main_sort_tb #(
  parameter DWIDTH      = 8,
  parameter MAX_PKT_LEN = 16
);

  bit clk;
  bit srst;

  initial
    forever
      #5 clk = !clk;

  default clocking cb
    @( posedge clk );
  endclocking

  avst_if #(
    .DWIDTH ( DWIDTH )
  ) avst_if_i (
    .clk  ( clk  ),
    .srst ( srst )
  );

  avst_if #(
    .DWIDTH ( DWIDTH )
  ) avst_if_o (
    .clk  ( clk  ),
    .srst ( srst )
  );

  TX_driver tx_drv_ins;
  RX_driver rx_drv_ins;

  main_sort #(
    .DWIDTH      ( DWIDTH      ),
    .MAX_PKT_LEN ( MAX_PKT_LEN )
  ) dut (
    .clk_i               ( clk                     ),
    .srst_i              ( srst                    ),
  
    .snk_data_i          ( avst_if_i.data          ),
    .snk_startofpacket_i ( avst_if_i.startofpacket ),
    .snk_endofpacket_i   ( avst_if_i.endofpacket   ),
    .snk_valid_i         ( avst_if_i.valid         ),
    .snk_ready_o         ( avst_if_i.ready         ),
  
    .src_data_o          ( avst_if_o.data          ),
    .src_startofpacket_o ( avst_if_o.startofpacket ),
    .src_endofpacket_o   ( avst_if_o.endofpacket   ),
    .src_valid_o         ( avst_if_o.valid         ),
    .src_ready_i         ( avst_if_o.ready         )
  );
  
  task throw_err(string msg);
    $error(msg, $time);
    ##5;
    $stop();
  endtask


  // len_pkt - number of words in packet
  // chance_of_send_valid - chance between 1 and 100 of send VALID word every cycle
  task send_and_check(TX_driver tx, 
                      RX_driver rx, 
                      int len_pkt,
                      int chance_of_send_valid);
    logic unsigned [DWIDTH-1:0] sorted_data[];
    logic unsigned [DWIDTH-1:0] curr_val;
    sorted_data = new[len_pkt];

    
    for(int i = 0; i < len_pkt; i++)
      sorted_data[i][DWIDTH-1:0]  = $urandom_range(2**32-1, 0);
        $display("new task STARTED");
    fork
      $display("forked at", $time);
      tx.set_pkt(sorted_data);
      tx.send(chance_of_send_valid);
      rx.receive_packet();
    join
    $display("fork join at", $time);
    sorted_data.sort(); 

    if( rx.get_sizeofpkt() == sorted_data.size() )
      begin
        for(int i = 0; i < rx.get_sizeofpkt(); i++)
        begin
          curr_val = rx.get_nextelement();
          if( curr_val != sorted_data[i] )
            begin
              $display("EXPECTED %5u, got %5u", sorted_data[i], curr_val);
              throw_err("WRONG DATA IN RECEIVED PACKET");
            end

        end
      end
    else
      begin
        $display("EXPECTED %d, GOT %d", len_pkt, rx.get_sizeofpkt());
        throw_err("DIFFERENCE BETWEEN SIZES OF PACKETS");
      end
    ##1;
  endtask
  

  initial
    begin
      tx_drv_ins = new(avst_if_i);
      rx_drv_ins = new(avst_if_o);
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;

      for( int len_pkt = 2; len_pkt <= MAX_PKT_LEN; len_pkt = len_pkt + 1)
        for( int chance = 10; chance <= 100; chance = chance + 10 )
          for( int iterations = 0; iterations < 10; iterations = iterations + 1)
            begin
              send_and_check(tx_drv_ins, rx_drv_ins, len_pkt, chance);
            end

      ##10;
      $stop();
    end

endmodule
