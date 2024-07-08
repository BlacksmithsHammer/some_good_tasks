class TX_driver #(
  parameter DWIDTH      = 8,
  parameter MAX_PKT_LEN = 16
);
  logic [DWIDTH-1:0] pkt[];
  virtual avst_if if_ins;
  bit have_pkt;

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

  task throw_err(string msg);
    $error(msg, $time);
    $stop();
  endtask

  task set_pkt( logic [DWIDTH-1:0] pkt_i[] );
    if( pkt_i.size() > MAX_PKT_LEN)
      begin
        $error("WRONG PACKET LENGTH IN TX DRIVER ", $time);
        $stop();
      end
    
    this.pkt = pkt_i;
    have_pkt = 1;
  endtask

  task send( int chance_of_send_valid );
    int i = 0;


    if( !have_pkt )
      $throw_err("HAVNT PACKETS IN RX BUFFER ");
    if( chance_of_send_valid < 1 || chance_of_send_valid > 100 )
      throw_err("WRONG CHANCE IN TASK CHANCE_OF_SEND_VALID IN TIME ");

    while(i < this.pkt.size())
      if( $urandom_range(0, 99) < chance_of_send_valid)
        begin
          this.if_ins.data          <= this.pkt[i];
          this.if_ins.valid         <= 1'b1;
          this.if_ins.startofpacket <= ( i == 0                   );
          this.if_ins.endofpacket   <= ( i == this.pkt.size() - 1 );

          i = i + 1;
          @(posedge this.if_ins.clk);
        end
      else
        begin
          this.if_ins.data          <= $urandom_range(2**32-1, 0);
          this.if_ins.valid         <= 1'b0;
          this.if_ins.startofpacket <= 1'b0;
          this.if_ins.endofpacket   <= 1'b0;
        end

    

  endtask

endclass

// class RX_driver;
//     function new(); 
//     endfunction
// endclass

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



  // global data and states for checker
  // DWIDTH without (-1) to skip sign bit in sort
  logic unsigned [DWIDTH-1:0] sorted_data[]; 
  int data_in_process;

  // len_pkt - number of words in packet
  task send_packet(int len_pkt = MAX_PKT_LEN,
                   int chance_of_send_valid = 100);
    int i;
    i = 0;
    sorted_data = new[len_pkt];
    data_in_process = 1;

    if( len_pkt > MAX_PKT_LEN || len_pkt < 2 )
      throw_err("WRONG LENGTH OF PACKET IN TASK SEND_PACKET IN TIME");
    if( chance_of_send_valid < 1 || chance_of_send_valid > 100 )
      throw_err("WRONG CHANCE IN TASK CHANCE_OF_SEND_VALID IN TIME");

    while( i < len_pkt )
      begin
        sorted_data[i][DWIDTH-1:0]  = $urandom_range(2**32-1, 0);
        avst_if_i.data   <= sorted_data[i];
        if( $urandom_range(99, 0) < chance_of_send_valid )
          begin
            i = i + 1;
            avst_if_i.valid         <= 1'b1;
            avst_if_i.startofpacket <= ( i == 1       );
            avst_if_i.endofpacket   <= ( i == len_pkt );
          end
        else
          avst_if_i.valid <= 1'b0;
        ##1;
        avst_if_i.startofpacket <= 1'b0;
        avst_if_i.endofpacket   <= 1'b0;
      end
    
    sorted_data.sort(); 
    // $display("=====================================================");
    // for (int j = 0; j < sorted_data.size(); j++)
    //   $write("%d[%0d] ", sorted_data[j], j);
    // $write("\n");

    // clean signals
    avst_if_i.startofpacket <= 1'b0;
    avst_if_i.endofpacket   <= 1'b0;
    avst_if_i.valid         <= 1'b0;
  endtask
  
  // time of waiting answer in clocks/cycles
  task check_task(longint time_waiting = 10000);
    int i;
    i = 0;
    // check of x (isunknown) skipped, because uses
    // timer-like counter time_waiting to check infinite
    // sorting and some other situations
    while( i < sorted_data.size() )
      begin
        time_waiting = time_waiting - 1;
        if( avst_if_o.valid === 1'b1 )
          begin
            
            //$display("%5d, %5d, %8d", dut_src_data, sorted_data[i], $time);
            if( ( i == 0 ) && 
                ( avst_if_o.endofpacket === 1'b1 || avst_if_o.startofpacket === 1'b0 ) )
              throw_err("PROBLEMS WITH AVALON-ST SIGNALS IN THE START OF SENDING PACKET");

            if( ( i == sorted_data.size() - 1 ) && 
                ( avst_if_o.endofpacket === 1'b0 || avst_if_o.startofpacket === 1'b1 ) )
              throw_err("PROBLEMS WITH AVALON-ST SIGNALS IN THE END OF SENDING PACKET");

            if( ( i > 0 && i < i == sorted_data.size() - 1 ) &&
                ( avst_if_o.endofpacket === 1'b1 || avst_if_o.startofpacket === 1'b1 ) )
              throw_err("PROBLEMS WITH AVALON-ST SIGNALS IN THE MIDDLE OF SENDING PACKET");
            if( avst_if_o.data != sorted_data[i] )
              throw_err("WRONG DATA");
            
            i = i + 1;
          end
        ##1;
        if( time_waiting < 0 )
          throw_err("TEST TOO LONG");
      end
    wait(avst_if_i.ready);
  endtask



  initial
    begin
      avst_if_i.startofpacket <= 1'b0;
      avst_if_i.endofpacket   <= 1'b0;
      avst_if_i.valid         <= 1'b0;
      avst_if_o.ready         <= 1'b1;
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;

      ///////////////////////////////////////////////////////////////////////////
      // UNCOMMENT THIS BLOCK TO DEEP TESTING
      // stress-test
      //
      // for(int curr_len_pkt = 2; curr_len_pkt <= MAX_PKT_LEN; curr_len_pkt++)
      //   for(int curr_chance = 5; curr_chance <= 100; curr_chance += 5)
      //     for(int num_test = 0; num_test < 100; num_test++)
      //       begin
      //         fork
      //           send_packet(curr_len_pkt, curr_chance);
      //           check_task();
      //         join
      //         // not necessary move, only for checking problems
      //         // in idle
      //         ##($urandom_range(10, 0));
      //       end
      ///////////////////////////////////////////////////////////////////////////

      // tests with randomized length of packets
      // and randomized time of sending packets into sort
      for(int num_test = 0; num_test < 5; num_test++)
        begin
          fork
            send_packet($urandom_range(MAX_PKT_LEN, 2), $urandom_range(100, 1));
            check_task();
          join
          // not necessary move, only for checking problems
          // in idle/effect of pause
          ##($urandom_range(10, 0));
        end
      //$display("TESTS PASSED SUCCESSFULLY FOR DWIDTH=%0d and MAX_PKT_LEN=%0d", DWIDTH, MAX_PKT_LEN);
      

      ##100;

      sorted_data = new[5];
      sorted_data[0] = 100;
      sorted_data[1] = 104;
      sorted_data[2] = 103;
      sorted_data[3] = 101;
      sorted_data[4] = 102;

      tx_drv_ins = new (avst_if_i);
      tx_drv_ins.set_pkt(sorted_data);
      tx_drv_ins.send(100);
      ##100;
      $stop();
    end

endmodule
