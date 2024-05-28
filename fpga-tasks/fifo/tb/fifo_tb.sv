`timescale 1 ps / 1 ps

module fifo_tb #(
  parameter DWIDTH             = 8,
  parameter AWIDTH             = 4,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 4,

  //for DUT
  parameter REGISTER_OUTPUT    = 1,
  parameter SHOWAHEAD          = 0,

  //for golden sample
  parameter GOLDEN_REG         = "ON",
  parameter GOLDEN_SHOW        = "OFF"
);

  //input signal for both models
  bit clk;
  bit srst;

  logic [DWIDTH-1:0]  data;
  logic               wrreq;
  logic               rdreq;

  //DUT output signals
  logic               DUT_empty_o;
  logic               DUT_full_o;
  logic [AWIDTH:0]    DUT_usedw_o;

  logic               DUT_almost_full_o;
  logic               DUT_almost_empty_o;

  logic [DWIDTH-1:0]  DUT_q_o;
  
  //golden model output signals
  logic               GOLDEN_empty_o;
  logic               GOLDEN_full_o;
  logic [AWIDTH-1:0]    GOLDEN_usedw_o;

  logic               GOLDEN_almost_full_o;
  logic               GOLDEN_almost_empty_o;

  logic [DWIDTH-1:0]  GOLDEN_q_o;


  initial
    forever
      #5 clk = !clk;

  default clocking cb
    @( posedge clk );
  endclocking


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

    .empty_o        ( DUT_empty_o        ),
    .full_o         ( DUT_full_o         ),
    .usedw_o        ( DUT_usedw_o        ),

    .almost_full_o  ( DUT_almost_full_o  ),
    .almost_empty_o ( DUT_almost_empty_o ),

    .q_o            ( DUT_q_o            )
  );

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

    .empty        ( GOLDEN_empty_o        ),
    .full         ( GOLDEN_full_o         ),
    .usedw        ( GOLDEN_usedw_o        ),

    .almost_full  ( GOLDEN_almost_full_o  ),
    .almost_empty ( GOLDEN_almost_empty_o ),

    .q            ( GOLDEN_q_o            )
  );



  task throw_err(string msg);
    $display(msg, $time);
    ##5;
    $stop();
  endtask

  int end_compare_check = 0;

  task compare_signals(string test_name);
    $display(test_name, " started at:", $time);
    end_compare_check = 1;
    while ( end_compare_check != 0 ) 
      begin
        if( DUT_empty_o        !== GOLDEN_empty_o        ) 
          throw_err("Wrong empty_o");
        if( DUT_full_o         !== GOLDEN_full_o         ) 
          throw_err("Wrong full_o");
        if( DUT_usedw_o        !== {GOLDEN_full_o, GOLDEN_usedw_o}) 
          throw_err("Wrong usedw_o");
        if( DUT_almost_full_o  !== GOLDEN_almost_full_o  ) 
          throw_err("Wrong almost_full_o");
        if( DUT_almost_empty_o !== GOLDEN_almost_empty_o ) 
          throw_err("Wrong almost_empty_o");
        if( DUT_q_o            !=  GOLDEN_q_o            ) 
          throw_err("Wrong q_o");
        ##1;
      end
    $display(test_name, " end at:", $time);
  endtask

  task send_req(logic [DWIDTH-1:0]  req_data);
    data  = req_data;
    wrreq = 1'b1;
    ##1;
    wrreq = 1'b0;
  endtask

  task long_stress_test(int iterations);
    while( iterations > 0 )
      begin
        if($urandom_range(2**DWIDTH-1, 0) % 2 == 0)
          send_req($urandom_range(2**DWIDTH-1, 0));

        if($urandom_range(2**DWIDTH-1, 0) % 2 == 0)
          rdreq = !rdreq;

        iterations = iterations - 1;
        ##1;
      end

    end_compare_check = 0;
  endtask

  initial
    begin
      //reset
      srst = 1'b1;
      wrreq = 1'b0;
      rdreq = 1'b0;
      ##1;
      srst = 1'b0;
      ##1;
      //end reset

      
      fork
        compare_signals("Old big test...");
        old_big_test();
      join

      fork
        compare_signals("Stress test...");
        long_stress_test(100000);
      join
      

      $display("ALL TESTS PASSED SUCCESSFULLY!");
      $stop();
    end

  // this is old big combined test... :)
  task old_big_test();
      rdreq = 1'b0;
      for(int i = 0; i < 16; i++)
        begin
          rdreq = $urandom_range(1, 1);
          send_req($urandom_range(2**DWIDTH-1, 0));
        end

      rdreq = 1'b1;
      ##16;


      rdreq = 1'b1;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      ##5;
      rdreq = 1'b1;
      ##10;

      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      ##5;
      rdreq = 1'b1;
      ##10;

      

      rdreq = 1'b1;
      ##20;


      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH-1; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      rdreq = 1'b1;
      ##20;

      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      rdreq = 1'b1;
      ##20;

      wrreq = 1'b1;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      rdreq = 1'b1;
      ##20;


      wrreq = 1'b0;
      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));

      ##4;

      for(int i = 0; i < 100; i++)
        begin
          rdreq = $urandom_range(1, 0);
          ##1;
        end
      
      rdreq = 1'b0;
      wrreq = 1'b0;
      ##4;
      send_req($urandom_range(2**DWIDTH-1, 0));
      rdreq = 1'b1;
      ##2;
      rdreq = 1'b0;
      ##5;
      end_compare_check = 0;
  endtask

endmodule