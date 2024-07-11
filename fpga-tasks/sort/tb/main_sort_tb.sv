`include "tx_driver.sv"
`include "rx_driver.sv"
`include "macro.sv"

module main_sort_tb #(
  parameter DWIDTH      = 8,
  parameter MAX_PKT_LEN = 32
);

  bit clk;
  bit srst;
  int step;

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

  TX_driver #(
    .DWIDTH      ( DWIDTH      ),
    .MAX_PKT_LEN ( MAX_PKT_LEN )
  ) tx_drv_ins;

  RX_driver #(
    .DWIDTH      ( DWIDTH      ),
    .MAX_PKT_LEN ( MAX_PKT_LEN )
  ) rx_drv_ins;

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

  // len_pkt - number of words in packet
  // chance_of_send_valid - chance between 1 and 100 of send VALID word every cycle
  task send_and_check(TX_driver #(
                                   .DWIDTH      (DWIDTH     ),
                                   .MAX_PKT_LEN (MAX_PKT_LEN)
                                 ) tx, 
                      RX_driver #(
                                   .DWIDTH      (DWIDTH     ),
                                   .MAX_PKT_LEN (MAX_PKT_LEN)
                                 ) rx, 
                      int len_pkt,
                      int chance_of_send_valid);
    logic unsigned [DWIDTH-1:0] sorted_data[];
    logic unsigned [DWIDTH-1:0] curr_val;
    sorted_data = new[len_pkt];

    
    for(int i = 0; i < len_pkt; i++)
      sorted_data[i][DWIDTH-1:0]  = $urandom_range(2**32-1, 0);
    fork
      tx.set_pkt(sorted_data);
      tx.send(chance_of_send_valid);
      rx.receive_packet();
    join
    sorted_data.sort(); 

    if( rx.get_sizeofpkt() == sorted_data.size() )
      begin
        for(int i = 0; i < rx.get_sizeofpkt(); i++)
        begin
          curr_val = rx.get_nextelement();
          if( curr_val != sorted_data[i] )
            `THROW_WITH_EXPLAIN(sorted_data[i], curr_val, "WRONG DATA IN RECEIVED PACKET");
        end
      end
    else
      `THROW_WITH_EXPLAIN(len_pkt, rx.get_sizeofpkt(), "DIFFERENCE BETWEEN SIZES OF PACKETS");
    ##1;
  endtask


  // in test cases "step" means difference between
  // lengths packets
  //
  // for step = 2:
  //  1st length packet = 2  ( 1 * 2 )
  //  2nd length packet = 4  ( 2 * 2 )
  //  3rd length packet = 6  ( 3 * 2 )
  //  ...
  //
  // for step = 5:
  //  1st length packet = 5  ( 1 * 5 )
  //  2nd length packet = 10 ( 2 * 5 )
  //  3rd length packet = 15 ( 3 * 5 )
  //  ...

  initial
    begin
      case (1)
        // not best solution (like a 2**n),
        // but i dont know how write it better
        ( MAX_PKT_LEN >= 2048 ) : step = 512;
        ( MAX_PKT_LEN >= 1024 ) : step = 256;
        ( MAX_PKT_LEN >= 512  ) : step = 64; // skip 128 to improve speed test
        ( MAX_PKT_LEN >= 256  ) : step = 16;
        ( MAX_PKT_LEN >= 128  ) : step = 8;
        ( MAX_PKT_LEN >= 64   ) : step = 4;
        ( MAX_PKT_LEN >= 32   ) : step = 2;
        default                 : step = 2;
      endcase

      tx_drv_ins = new(avst_if_i);
      rx_drv_ins = new(avst_if_o);
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;

      for( int i = 1; i*step <= MAX_PKT_LEN; i = i + 1)
        for( int chance = 20; chance <= 100; chance = chance + 40 )
          for( int iterations = 0; iterations < 10; iterations = iterations + 1)
            send_and_check(tx_drv_ins, rx_drv_ins, i*step, chance);

      ##10;
      $stop();
    end

endmodule
