module fifo_tb #(
  parameter DWIDTH             = 8,
  parameter AWIDTH             = 4,
  parameter SHOWAHEAD          = 1,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 2,
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
    .REGISTER_OUTPUT    ( REGISTER_OUTPUT    )
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
      ##1;
      //end reset

      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      ##5;
      rdreq = 1'b1;
      ##30;


      rdreq = 1'b0;
      for(int i = 0; i < 2**AWIDTH; i++)
        send_req($urandom_range(2**DWIDTH-1, 0));
      ##5;
      rdreq = 1'b1;
      ##100;

      
      $stop();
    end


endmodule