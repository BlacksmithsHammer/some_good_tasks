`timescale 1 ps / 1 ps
  //////////////////////////////////////////////////////////
  // TESTBENCH CHECKS FIFO IN SAFE-MODE: 
  // FIFO contains overflow protection and read from empty
  //////////////////////////////////////////////////////////

module fifo_tb #(
  parameter DWIDTH             = 8,
  parameter AWIDTH             = 4,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 4,

  //for DUT, change test parameters there!
  parameter REGISTER_OUTPUT    = 1,
  parameter SHOWAHEAD          = 1,

  //for golden sample
  parameter GOLDEN_REG         = REGISTER_OUTPUT ? "ON" : "OFF",
  parameter GOLDEN_SHOW        = SHOWAHEAD       ? "ON" : "OFF"
);

  //input signal for both models
  bit clk;
  bit srst;

  logic [DWIDTH-1:0]  data;
  logic               wrreq;
  logic               rdreq;

  //DUT output signals
  logic               dut_empty_o;
  logic               dut_full_o;
  logic [AWIDTH:0]    dut_usedw_o;

  logic               dut_almost_full_o;
  logic               dut_almost_empty_o;

  logic [DWIDTH-1:0]  dut_q_o;
  
  //golden model output signals
  logic               golden_empty_o;
  logic               golden_full_o;
  logic [AWIDTH-1:0]  golden_usedw_o;

  logic               golden_almost_full_o;
  logic               golden_almost_empty_o;

  logic [DWIDTH-1:0]  golden_q_o;


  initial
    forever
      #5 clk = !clk;

  default clocking cb
    @( posedge clk );
  endclocking

  //////////////////////////////////////////////////////////
  // DUT instance
  //////////////////////////////////////////////////////////
  fifo #(
    .DWIDTH             ( DWIDTH             ),
    .AWIDTH             ( AWIDTH             ),
    .SHOWAHEAD          ( SHOWAHEAD          ),
    .ALMOST_FULL_VALUE  ( ALMOST_FULL_VALUE  ),
    .ALMOST_EMPTY_VALUE ( ALMOST_EMPTY_VALUE ),
    .REGISTER_OUTPUT    ( REGISTER_OUTPUT    )
  ) DUT (
    .clk_i          ( clk                ),
    .srst_i         ( srst               ),

    .data_i         ( data               ),
    .wrreq_i        ( wrreq              ),
    .rdreq_i        ( rdreq              ),

    .empty_o        ( dut_empty_o        ),
    .full_o         ( dut_full_o         ),
    .usedw_o        ( dut_usedw_o        ),

    .almost_full_o  ( dut_almost_full_o  ),
    .almost_empty_o ( dut_almost_empty_o ),

    .q_o            ( dut_q_o            )
  );

  //////////////////////////////////////////////////////////
  // GOLDEN model instance
  //////////////////////////////////////////////////////////
  scfifo #(
    .lpm_width               ( DWIDTH                ),
    .lpm_widthu              ( AWIDTH                ),
    .lpm_numwords            ( 2 ** AWIDTH           ),
    .lpm_type                ( "scfifo"              ),
    .lpm_hint                ( "RAM_BLOCK_TYPE=M10K" ),
    .intended_device_family  ( "Cyclone V"           ),
    .underflow_checking      ( "ON"                  ),
    .overflow_checking       ( "ON"                  ),
    .allow_rwcycle_when_full ( "OFF"                 ),
    .use_eab                 ( "ON"                  ),
    .almost_full_value       ( ALMOST_FULL_VALUE     ),
    .almost_empty_value      ( ALMOST_EMPTY_VALUE    ),
    .maximum_depth           ( 0                     ),
    .enable_ecc              ( "FALSE"               ),


    .lpm_showahead           ( GOLDEN_SHOW           ),
    .add_ram_output_register ( GOLDEN_REG            )
  ) GOLDEN (
    .clock        ( clk                   ),
    .sclr         ( srst                  ),

    .data         ( data                  ),
    .wrreq        ( wrreq                 ),
    .rdreq        ( rdreq                 ),

    .empty        ( golden_empty_o        ),
    .full         ( golden_full_o         ),
    .usedw        ( golden_usedw_o        ),

    .almost_full  ( golden_almost_full_o  ),
    .almost_empty ( golden_almost_empty_o ),

    .q            ( golden_q_o            )
  );


  int errors = 0;
  task throw_err(string msg);
    $error(msg, $time);
    ##5;
    $stop();
  endtask


  //////////////////////////////////////////////////////////
  // task for DUT validation
  // works until the end_compare_check variable changes the state to 0
  //--------------------------------------------------------
  // the end_compare_check variable is changed either manually or inside 
  // tasks with test data
  //////////////////////////////////////////////////////////
  int end_compare_check = 0;

  task compare_signals(string test_name);
    //$display(test_name, " started at:", $time);
    end_compare_check = 1;
    while ( end_compare_check != 0 ) 
      begin
        if( dut_empty_o        !== golden_empty_o        ) 
          throw_err("Wrong empty_o");
        if( dut_full_o         !== golden_full_o         ) 
          throw_err("Wrong full_o");
        if( dut_usedw_o        !== {golden_full_o, golden_usedw_o}) 
          throw_err("Wrong usedw_o");
        if( dut_almost_full_o  !== golden_almost_full_o  ) 
          throw_err("Wrong almost_full_o");
        if( dut_almost_empty_o !== golden_almost_empty_o ) 
          throw_err("Wrong almost_empty_o");
         // don't check, when golden and dut output is x
        if( $isunknown(dut_q_o) == 0 && $isunknown(golden_q_o) )
          if( dut_q_o          !== golden_q_o            ) 
            throw_err("Wrong q_o");  
        ##1;
      end
    //$display(test_name, " end at:", $time);
  endtask

  // test data up to 32 bits
  task long_stress_test(int iterations,
                        // chance beetween 0 and 100 (%):
                        // if chance_of_write = 100, every cycle
                        // new random data will be writed
                        int chance_of_write = 0,
                        int chance_of_read  = 0);
    //$display("chance of write: %d, chance of read: %d", chance_of_write, chance_of_read);

    while( iterations > 0 )
      begin
        if($urandom_range(99, 0) < chance_of_write)
          begin
            data  = $urandom_range(2**DWIDTH-1, 0);
            wrreq = 1'b1;
          end
        else
          wrreq = 1'b0;

        if($urandom_range(99, 0) < chance_of_read)
          rdreq = 1'b1;
        else
          rdreq = 1'b0;

        iterations = iterations - 1;
        ##1;
      end

    end_compare_check = 0;
  endtask

  // task to send once data
  task send_req(logic [DWIDTH-1:0]  req_data);
    data  = req_data;
    wrreq = 1'b1;
    ##1;
    wrreq = 1'b0;
  endtask

  initial
    begin
      $display("---------------------------------------------------------------\n");
      $display("TESTS FOR SHOWAHEAD=%0d and REGISTER_OUTPUT=%0d STARTED\n", SHOWAHEAD, REGISTER_OUTPUT);
      $display("---------------------------------------------------------------\n");

      //reset
      srst = 1'b1;
      wrreq = 1'b0;
      rdreq = 1'b0;
      ##1;
      srst = 1'b0;
      ##1;
      //end reset

      // specific tests
      $display("Specific test cases started");
      fork
        compare_signals("Old big test...");
        old_big_test();
      join
      $display("Specific test cases end");

      // stress tests with difference chances of wrrite req and read req
      $display("Stress tests started");
      for(int wr_chance = 0; wr_chance <= 100; wr_chance = wr_chance + 10)
        for(int rd_chance = 0; rd_chance <= 100; rd_chance = rd_chance + 10)
          fork
            compare_signals("Stress test...");
            long_stress_test(2**AWIDTH * 100, wr_chance, rd_chance);
          join
      $display("Stress tests end");
      

      $display("-------------------------------\nALL TESTS PASSED SUCCESSFULLY!\n-------------------------------");
      $stop();
    end

  // this is old big combined test... :)
  // in general, it can be deleted, as stress test covers everything
  task old_big_test();
      // test case with read and write data at the same time
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        begin
          rdreq = 1;
          send_req($urandom_range(2**DWIDTH-1, 0));
        end
      // waiting for check unexpected output
      ##(2**AWIDTH);

      // write new data and also read it at the same time again
      rdreq = 1'b1;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      // small pause
      ##10;


      // write new data without reading
      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      // small pause
      ##5;
      // read filled fifo without writing new data
      rdreq = 1'b1;
      ##(2**AWIDTH * 2);


      // write new data without reading
      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH-1; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      // read filled fifo without writing new data
      // immediately after write all data
      rdreq = 1'b1;
      ##(2**AWIDTH * 2);


      // write new data without reading
      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      // read filled fifo without writing new data
      // immediately after write all data
      rdreq = 1'b1;
      ##(2**AWIDTH * 2);


      // write new data without reading
      wrreq = 1'b0;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      ##4;
      // and reading with 50% chance in every cycle
      for(int i = 0; i < 2**AWIDTH * 10; i++)
        begin
          rdreq = $urandom_range(1, 0);
          ##1;
        end

      end_compare_check = 0;
  endtask

endmodule
