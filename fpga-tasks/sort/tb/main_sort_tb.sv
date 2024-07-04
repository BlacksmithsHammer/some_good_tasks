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
  
  sort_avst_if #(
    .DWIDTH ( DWIDTH )
  ) avst_if_ins (
    .clk  ( clk  ),
    .srst ( srst )
  );

  main_sort #(
    .DWIDTH      ( DWIDTH      ),
    .MAX_PKT_LEN ( MAX_PKT_LEN )
  ) dut (
    .clk_i               ( clk                   ),
    .srst_i              ( srst                  ),
  
    .snk_data_i          ( avst_if_ins.snk_data          ),
    .snk_startofpacket_i ( avst_if_ins.snk_startofpacket ),
    .snk_endofpacket_i   ( avst_if_ins.snk_endofpacket   ),
    .snk_valid_i         ( avst_if_ins.snk_valid         ),
    .snk_ready_o         ( avst_if_ins.snk_ready         ),
  
    .src_data_o          ( avst_if_ins.src_data          ),
    .src_startofpacket_o ( avst_if_ins.src_startofpacket ),
    .src_endofpacket_o   ( avst_if_ins.src_endofpacket   ),
    .src_valid_o         ( avst_if_ins.src_valid         ),
    .src_ready_i         ( avst_if_ins.src_ready         )
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
        avst_if_ins.snk_data   <= sorted_data[i];
        if( $urandom_range(99, 0) < chance_of_send_valid )
          begin
            i = i + 1;
            avst_if_ins.snk_valid         <= 1'b1;
            avst_if_ins.snk_startofpacket <= ( i == 1       );
            avst_if_ins.snk_endofpacket   <= ( i == len_pkt );
          end
        else
          avst_if_ins.snk_valid <= 1'b0;
        ##1;
        avst_if_ins.snk_startofpacket <= 1'b0;
        avst_if_ins.snk_endofpacket   <= 1'b0;
      end
    
    sorted_data.sort(); 
    // $display("=====================================================");
    // for (int j = 0; j < sorted_data.size(); j++)
    //   $write("%d[%0d] ", sorted_data[j], j);
    // $write("\n");

    // clean signals
    avst_if_ins.snk_startofpacket <= 1'b0;
    avst_if_ins.snk_endofpacket   <= 1'b0;
    avst_if_ins.snk_valid         <= 1'b0;
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
        if( avst_if_ins.src_valid === 1'b1 )
          begin
            
            //$display("%5d, %5d, %8d", dut_src_data, sorted_data[i], $time);
            if( ( i == 0 ) && 
                ( avst_if_ins.src_endofpacket === 1'b1 || avst_if_ins.src_startofpacket === 1'b0 ) )
              throw_err("PROBLEMS WITH AVALON-ST SIGNALS IN THE START OF SENDING PACKET");

            if( ( i == sorted_data.size() - 1 ) && 
                ( avst_if_ins.src_endofpacket === 1'b0 || avst_if_ins.src_startofpacket === 1'b1 ) )
              throw_err("PROBLEMS WITH AVALON-ST SIGNALS IN THE END OF SENDING PACKET");

            if( ( i > 0 && i < i == sorted_data.size() - 1 ) &&
                ( avst_if_ins.src_endofpacket === 1'b1 || avst_if_ins.src_startofpacket === 1'b1 ) )
              throw_err("PROBLEMS WITH AVALON-ST SIGNALS IN THE MIDDLE OF SENDING PACKET");
            if( avst_if_ins.src_data != sorted_data[i] )
              throw_err("WRONG DATA");
            
            i = i + 1;
          end
        ##1;
        if( time_waiting < 0 )
          throw_err("TEST TOO LONG");
      end
    wait(avst_if_ins.snk_ready);
  endtask


  initial
    begin
      avst_if_ins.snk_startofpacket <= 1'b0;
      avst_if_ins.snk_endofpacket   <= 1'b0;
      avst_if_ins.snk_valid         <= 1'b0;
      avst_if_ins.src_ready         <= 1'b1;
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
      for(int num_test = 0; num_test < 100; num_test++)
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
      $stop();
    end

endmodule
