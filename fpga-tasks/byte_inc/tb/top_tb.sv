import amm_byte_inc_package::*;

module top_tb #(
  parameter test_case TEST_CASE = RANDOM_WAITREQUEST,
  
  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);

  bit clk;

  initial
    forever
      #5 clk = !clk;

  default clocking cb @( posedge clk );
  endclocking

  byte_inc_set_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) settings_if (
    .clk        ( clk        )
  );

  amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) reader_if (
    .clk        ( clk        )
  );

  amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) writer_if (
    .clk        ( clk        )
  );

  byte_inc #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) dut (
    .clk_i                   ( clk                     ),
    .srst_i                  ( settings_if.srst        ),
    // settings
    .base_addr_i             ( settings_if.base_addr   ),
    .length_i                ( settings_if.length      ),
    .run_i                   ( settings_if.run         ),
    .waitrequest_o           ( settings_if.waitrequest ),

    // reader
    .amm_rd_address_o        ( reader_if.address       ),
    .amm_rd_read_o           ( reader_if.read          ),
    .amm_rd_readdata_i       ( reader_if.data          ),
    .amm_rd_readdatavalid_i  ( reader_if.datavalid ),
    .amm_rd_waitrequest_i    ( reader_if.waitrequest   ),

    // writer
    .amm_wr_address_o        ( writer_if.address       ),
    .amm_wr_write_o          ( writer_if.write         ),
    .amm_wr_writedata_o      ( writer_if.data          ),
    .amm_wr_byteenable_o     ( writer_if.byteenable    ),
    .amm_wr_waitrequest_i    ( writer_if.waitrequest   )
  );



  initial
    begin
      amm_byte_inc_enviroment #( amm_byte_inc_transaction ) env;
      env = new();
      env.build(settings_if, reader_if, writer_if);
      
      case (TEST_CASE)
        MVP:
          begin
            env.run(MVP, "CHECK MVP");
          end

        RANDOM_WAITREQUEST:
          begin
            env.run(RANDOM_WAITREQUEST, "CHECK RANDOM_WAITREQUEST");
          end

        STATIC_WAITREQUEST:
          begin
            env.run(STATIC_WAITREQUEST, "CHECK STATIC_WAITREQUEST");
          end

        OVERSIZE_LENGTH:
          begin
            env.run(OVERSIZE_LENGTH, "CHECK OVERSIZE_LENGTH");
          end

        MAX_LATENCY:
          begin
            env.run(MAX_LATENCY, "CHECK MAX_LATENCY");
          end

        BIG_TEST:
          begin
            env.run(BIG_TEST, "CHECK BIG_TEST");
          end

        default:
          begin
            $error("UNEXPECTED TEST");
            $stop();
          end
      endcase
      
      $display("END OF SIMULATION");
      $stop();
    end

endmodule
