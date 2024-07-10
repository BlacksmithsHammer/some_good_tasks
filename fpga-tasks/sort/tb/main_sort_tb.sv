`include "tx_driver.sv"
`include "rx_driver.sv"

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
