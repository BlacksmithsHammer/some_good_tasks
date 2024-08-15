import ast_we_package::*;

module top_tb #(
  parameter test_case TEST_CASE   = TEST_MVP,
  parameter           DATA_IN_W   = 64,
  parameter           EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter           CHANNEL_W   = 10,
  parameter           DATA_OUT_W  = 256,
  parameter           EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
);
  
  bit clk;
  bit srst;

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking
  
  ast_we_if #(    
    .DATA_IN_W   ( DATA_IN_W   ),
    .EMPTY_IN_W  ( EMPTY_IN_W  ),
    .CHANNEL_W   ( CHANNEL_W   ),
    .DATA_OUT_W  ( DATA_OUT_W  ),
    .EMPTY_OUT_W ( EMPTY_OUT_W )
  ) _if (
    .clk         ( clk         )
  );

  //////////////////////////////////////////////////////////
  // DUT instance
  //////////////////////////////////////////////////////////
  ast_width_extender #(
    .DATA_IN_W   ( DATA_IN_W   ),
    .EMPTY_IN_W  ( EMPTY_IN_W  ),
    .CHANNEL_W   ( CHANNEL_W   ),
    .DATA_OUT_W  ( DATA_OUT_W  ),
    .EMPTY_OUT_W ( EMPTY_OUT_W )
  ) ast_we_ins (
    .clk_i               ( clk                      ),
    .srst_i              ( srst                     ),

    .ast_data_i          ( _if.sink_data            ),
    .ast_startofpacket_i ( _if.sink_startofpacket   ),
    .ast_endofpacket_i   ( _if.sink_endofpacket     ),
    .ast_valid_i         ( _if.sink_valid           ),
    .ast_empty_i         ( _if.sink_empty           ),
    .ast_channel_i       ( _if.sink_channel         ),
    .ast_ready_o         ( _if.sink_ready           ),

    .ast_data_o          ( _if.source_data          ),
    .ast_startofpacket_o ( _if.source_startofpacket ),
    .ast_endofpacket_o   ( _if.source_endofpacket   ),
    .ast_valid_o         ( _if.source_valid         ),
    .ast_empty_o         ( _if.source_empty         ),
    .ast_channel_o       ( _if.source_channel       ),
    .ast_ready_i         ( _if.source_ready         )
  );

  task reset();
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;
  endtask

  initial
    begin
      ast_we_enviroment #( ast_we_transaction ) env;
      env = new();
      env.build(_if);
      reset();

      case (TEST_CASE)
        TEST_MVP:
          begin
            env.run(TEST_MVP, "MVP CHECK");
          end
        // TEST_EVERY_SIZE:
        //   begin
        //     env.run(TEST_EVERY_SIZE, "TEST EVERY SIZE OF PACKETS");
        //   end

        // TEST_RANDOM_BIG:
        //   begin
        //     env.run(TEST_RANDOM_BIG, "BIG RANDOMIZED TEST TO MAX COVERAGE");
        //   end

        default:
          begin
            $error("UNEXPECTED TEST");
          end
      endcase

      $stop();
    end

endmodule
