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
  // dut interface
  logic   [DWIDTH-1:0] dut_snk_data;
  logic                dut_snk_startofpacket;
  logic                dut_snk_endofpacket;
  logic                dut_snk_valid;
  logic                dut_snk_ready;

  logic   [DWIDTH-1:0] dut_src_data;
  logic                dut_src_startofpacket;
  logic                dut_src_endofpacket;
  logic                dut_src_valid;
  logic                dut_src_ready;

  main_sort #(
    .DWIDTH      ( DWIDTH      ),
    .MAX_PKT_LEN ( MAX_PKT_LEN )
  ) dut (
    .clk_i               ( clk                   ),
    .srst_i              ( srst                  ),
  
    .snk_data_i          ( dut_snk_data          ),
    .snk_startofpacket_i ( dut_snk_startofpacket ),
    .snk_endofpacket_i   ( dut_snk_endofpacket   ),
    .snk_valid_i         ( dut_snk_valid         ),
    .snk_ready_o         ( dut_snk_ready         ),
  
    .src_data_o          ( dut_src_data          ),
    .src_startofpacket_o ( dut_src_startofpacket ),
    .src_endofpacket_o   ( dut_src_endofpacket   ),
    .src_valid_o         ( dut_src_valid         ),
    .src_ready_i         ( dut_src_ready         )
  );
  

  task throw_err(string msg);
    $error(msg, $time);
    ##5;
    $stop();
  endtask

  //sorted_data 

  // len_pkt - number of words in packet
  task send_packet(int len_pkt = MAX_PKT_LEN,
                   int chance_of_send_valid = 100);
    int i;
    i = 0;
    if( len_pkt > MAX_PKT_LEN || len_pkt < 2 )
      throw_err("WRONG LENGTH OF PACKET IN TASK SEND_PACKET IN TIME");
    if( chance_of_send_valid < 1 || chance_of_send_valid > 100 )
      throw_err("WRONG CHANCE IN TASK CHANCE_OF_SEND_VALID IN TIME");

    while( i < len_pkt )
      begin
        dut_snk_data <= $urandom_range(2**32-1, 0);
        if( $urandom_range(99, 0) < chance_of_send_valid )
          begin
            i = i + 1;
            dut_snk_valid         <= 1'b1;
            dut_snk_startofpacket <= ( i == 1       );
            dut_snk_endofpacket   <= ( i == len_pkt );
          end
        else
          dut_snk_valid <= 1'b0;
        ##1;
        dut_snk_startofpacket <= 1'b0;
        dut_snk_endofpacket   <= 1'b0;
      end

    // clean signals
    dut_snk_startofpacket <= 1'b0;
    dut_snk_endofpacket   <= 1'b0;
    dut_snk_valid         <= 1'b0;
  endtask 


  initial
    begin
      dut_snk_startofpacket <= 1'b0;
      dut_snk_endofpacket   <= 1'b0;
      dut_snk_valid         <= 1'b0;
      dut_src_ready = 1'b1;
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;
      
      send_packet(2, 100);
      ##20
      
      send_packet(10, 50);
      ##150;

      send_packet(10, 50);
      ##150;

      $stop();
    end

endmodule