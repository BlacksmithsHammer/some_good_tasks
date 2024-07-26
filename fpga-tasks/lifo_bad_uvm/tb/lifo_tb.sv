import lifo_package::*;

module lifo_tb #(
  parameter test_case TEST_CASE       = SOME_RW,
  parameter int       DWIDTH          = 16,
  parameter int       AWIDTH          = 8,
  parameter int       ALMOST_FULL     = 2,
  parameter int       ALMOST_EMPTY    = 2
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

      case (TEST_CASE)
        SOME_RW:
          begin
            env.run(SOME_RW, 100, 10, "SMALL TEST");
          end

        FULL_RW:
          begin
            // third parameter ignored
            env.run(FULL_RW, 100, 0, "WRITE FULL AND READ FULL");
          end
        
        OVER_RW:
          begin
            // third parameter ignored
            env.run(OVER_RW, 100, 0, "WRITE MORE THAN MAX SIZE AND READ TOO");
          end
        
        BIG_TEST:
          begin
            //?
          end

        default:
          begin
            $error("UNEXPECTED TEST");
          end
      endcase

      


      $stop();
    end

endmodule
