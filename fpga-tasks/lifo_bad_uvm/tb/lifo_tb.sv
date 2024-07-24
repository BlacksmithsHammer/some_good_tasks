import lifo_package::*;

module lifo_tb #(
  parameter int DWIDTH        = 16,
  parameter int AWIDTH        = 8,
  parameter int ALMOST_FULL   = 2,
  parameter int ALMOST_EMPTY  = 2
);
  
  bit clk;
  bit srst;

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking
  
  lifo_if #(
    .DWIDTH ( DWIDTH ),
    .AWIDTH ( AWIDTH )
  ) _if (
    .clk    ( clk    )
  ); 

  //////////////////////////////////////////////////////////
  // DUT instance
  //////////////////////////////////////////////////////////
  lifo #(
    .DWIDTH         ( DWIDTH           ),
    .AWIDTH         ( AWIDTH           ),
    .ALMOST_FULL    ( ALMOST_FULL      ),
    .ALMOST_EMPTY   ( ALMOST_EMPTY     )
  ) lifo_ins (
    .clk_i          ( clk              ),
    .srst_i         ( srst             ),

    .wrreq_i        ( _if.wrreq        ),
    .data_i         ( _if.data         ),

    .rdreq_i        ( _if.rdreq        ),
    .q_o            ( _if.q            ),

    .almost_empty_o ( _if.almost_empty ),
    .empty_o        ( _if.empty        ),
    .almost_full_o  ( _if.almost_full  ),
    .full_o         ( _if.full         ),
    .usedw_o        ( _if.usedw        )
  );

  task reset();
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;
  endtask

  initial
    begin
      lifo_enviroment #(trans_from_generator, trans_from_monitor) env;
      env = new();
      env.build(_if);
      
      reset();
      
      env.run(SOME_RW);

      ##5;
      $stop();
    end

endmodule
