`timescale 1 ps / 1 ps

module fifo_tb #(
  parameter DWIDTH             = 8,
  parameter AWIDTH             = 4,
  parameter SHOWAHEAD          = 1,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 4,
  parameter REGISTER_OUTPUT    = 0
);


  bit clk;
  bit srst;

  logic [DWIDTH-1:0]  data;
  logic               wrreq;
  logic               rdreq;

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
    .REGISTER_OUTPUT    ( 0                  )
  ) DUT (
    .clk_i  ( clk  ),
    .srst_i ( srst ),

    .data_i  ( data ),
    .wrreq_i ( wrreq ),
    .rdreq_i ( rdreq ),
  
    .q_o (),

    .empty_o (),
    .full_o  (),
    .usedw_o (),

    .almost_full_o  (),
    .almost_empty_o ()
  );

  fifo #(
    .DWIDTH             ( DWIDTH             ),
    .AWIDTH             ( AWIDTH             ),
    .SHOWAHEAD          ( SHOWAHEAD          ),
    .ALMOST_FULL_VALUE  ( ALMOST_FULL_VALUE  ),
    .ALMOST_EMPTY_VALUE ( ALMOST_EMPTY_VALUE ),
    .REGISTER_OUTPUT    ( 1                  )
  ) DUT_reg (
    .clk_i  ( clk  ),
    .srst_i ( srst ),

    .data_i  ( data ),
    .wrreq_i ( wrreq ),
    .rdreq_i ( rdreq ),
  
    .q_o (),

    .empty_o (),
    .full_o  (),
    .usedw_o (),

    .almost_full_o  (),
    .almost_empty_o ()
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


    .lpm_showahead           ( "OFF"                 ),
    .add_ram_output_register ( "OFF"                 )
  ) golden (
    .clock  ( clk  ),
    .sclr ( srst ),

    .data  ( data ),
    .wrreq ( wrreq ),
    .rdreq ( rdreq ),
  
    .q (),

    .empty (),
    .full  (),
    .usedw (),

    .almost_full  (),
    .almost_empty ()
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


    .lpm_showahead           ( "ON"                  ),
    .add_ram_output_register ( "OFF"                 )
  ) golden_show (
    .clock  ( clk  ),
    .sclr ( srst ),

    .data  ( data ),
    .wrreq ( wrreq ),
    .rdreq ( rdreq ),
  
    .q (),

    .empty (),
    .full  (),
    .usedw (),

    .almost_full  (),
    .almost_empty ()
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


    .lpm_showahead           ( "OFF"                 ),
    .add_ram_output_register ( "ON"                  )
  ) golden_reg (
    .clock  ( clk  ),
    .sclr ( srst ),

    .data  ( data ),
    .wrreq ( wrreq ),
    .rdreq ( rdreq ),
  
    .q (),

    .empty (),
    .full  (),
    .usedw (),

    .almost_full  (),
    .almost_empty ()
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


    .lpm_showahead           ( "ON"                  ),
    .add_ram_output_register ( "ON"                  )
  ) golden_show_reg (
    .clock  ( clk  ),
    .sclr ( srst ),

    .data  ( data ),
    .wrreq ( wrreq ),
    .rdreq ( rdreq ),
  
    .q (),

    .empty (),
    .full  (),
    .usedw (),

    .almost_full  (),
    .almost_empty ()
  );



  task send_req(logic [DWIDTH-1:0]  req_data);
    data  = req_data;
    wrreq = 1'b1;
    ##1;
    wrreq = 1'b0;
  endtask
  

  initial
    begin
      //reset
      srst = 1'b1;
      ##1;
      srst = 1'b0;
      ##5;
      //end reset

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
      ##4;
      wrreq = 1'b1;
      ##20;

      
      $stop();
    end


endmodule