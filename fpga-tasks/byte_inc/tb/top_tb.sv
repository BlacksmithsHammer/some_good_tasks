import amm_byte_inc_package::*;

module top_tb #(
  parameter test_case TEST_CASE = MVP,
  
  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);

  bit clk;
  bit srst;

  initial
    forever
      #5 clk = !clk;

  default clocking cb @( posedge clk );
  endclocking

  byte_inc_set_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) settings (
    .clk        ( clk        ),
    .srst       ( srst       )
  );

  amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) reader (
    .clk        ( clk        ),
    .srst       ( srst       )
  );

  amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) writer (
    .clk        ( clk        ),
    .srst       ( srst       )
  );

  byte_inc #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) dut (
    .clk_i                   ( clk  ),
    .srst_i                  ( srst ),
    // settings
    .base_addr_i             ( settings.base_addr   ),
    .length_i                ( settings.length      ),
    .run_i                   ( settings.run         ),
    .waitrequest_o           ( settings.waitrequest ),

    // reader
    .amm_rd_address_o        ( reader.address       ),
    .amm_rd_read_o           ( reader.read          ),
    .amm_rd_readdata_i       ( reader.data          ),
    .amm_rd_readdatavalid_i  ( reader.datavalid ),
    .amm_rd_waitrequest_i    ( reader.waitrequest   ),

    // writer
    .amm_wr_address_o        ( writer.address       ),
    .amm_wr_write_o          ( writer.write         ),
    .amm_wr_writedata_o      ( writer.data          ),
    .amm_wr_byteenable_o     ( writer.byteenable    ),
    .amm_wr_waitrequest_i    ( writer.waitrequest   )
  );


  task reset();
    srst <= 1'b1;
    @( settings.cb );
    srst <= 1'b0;
  endtask

  initial
    begin
      amm_byte_inc_enviroment #( byte_inc_transaction ) env;
      env = new();
      env.build(reader, writer);
      reset();
      
      case (TEST_CASE)
        MVP:
          begin
            env.run(MVP, "CHECK MVP");
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
