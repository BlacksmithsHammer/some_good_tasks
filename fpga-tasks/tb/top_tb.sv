import ast_dmx_package::*;

module top_tb #(
  parameter test_case TEST_CASE   = MANY_BYTES_RAND_READY,

  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);

  bit clk;
  bit srst;

  initial
    forever
      #5 clk = !clk;

  default clocking cb
    @( posedge clk );
  endclocking

  ast_dmx_if #(
    .DATA_WIDTH    ( DATA_WIDTH    ),
    .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
    .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
    .TX_DIR        ( TX_DIR        ),
    .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
  ) _sink_if (
    .clk           ( clk           )
  );

  ast_dmx_if #(
    .DATA_WIDTH    ( DATA_WIDTH    ),
    .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
    .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
    .TX_DIR        ( TX_DIR        ),
    .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
  ) _source_if [TX_DIR-1:0] (
    .clk           ( clk           )
  );

  logic [DATA_WIDTH    - 1 : 0] dut_ast_data_o          [TX_DIR-1:0];
  logic                         dut_ast_startofpacket_o [TX_DIR-1:0];
  logic                         dut_ast_endofpacket_o   [TX_DIR-1:0];
  logic                         dut_ast_valid_o         [TX_DIR-1:0];
  logic [EMPTY_WIDTH   - 1 : 0] dut_ast_empty_o         [TX_DIR-1:0];
  logic [CHANNEL_WIDTH - 1 : 0] dut_ast_channel_o       [TX_DIR-1:0];
  logic                         dut_ast_ready_i         [TX_DIR-1:0];

  genvar i;
  generate
    for (i = 0; i < TX_DIR; i++) 
      begin
        assign _source_if[i].data          = dut_ast_data_o[i];
        assign _source_if[i].startofpacket = dut_ast_startofpacket_o[i];
        assign _source_if[i].endofpacket   = dut_ast_endofpacket_o[i];
        assign _source_if[i].valid         = dut_ast_valid_o[i];
        assign _source_if[i].empty         = dut_ast_empty_o[i];
        assign _source_if[i].channel       = dut_ast_channel_o[i];
        assign dut_ast_ready_i[i]          = _source_if[i].ready;
      end
  endgenerate

  ast_dmx #(
    .DATA_WIDTH    ( DATA_WIDTH    ),
    .CHANNEL_WIDTH ( CHANNEL_WIDTH ),
    .EMPTY_WIDTH   ( EMPTY_WIDTH   ),
    .TX_DIR        ( TX_DIR        ),
    .DIR_SEL_WIDTH ( DIR_SEL_WIDTH )
  ) dut (
    .clk_i               ( clk                      ),
    .srst_i              ( srst                     ),

    .dir_i               ( _sink_if.dir           ),

    .ast_data_i          ( _sink_if.data          ),
    .ast_startofpacket_i ( _sink_if.startofpacket ),
    .ast_endofpacket_i   ( _sink_if.endofpacket   ),
    .ast_valid_i         ( _sink_if.valid         ),
    .ast_empty_i         ( _sink_if.empty         ),
    .ast_channel_i       ( _sink_if.channel       ),
    .ast_ready_o         ( _sink_if.ready         ),

    .ast_data_o          ( dut_ast_data_o          ),
    .ast_startofpacket_o ( dut_ast_startofpacket_o ),
    .ast_endofpacket_o   ( dut_ast_endofpacket_o   ),
    .ast_valid_o         ( dut_ast_valid_o         ),
    .ast_empty_o         ( dut_ast_empty_o         ),
    .ast_channel_o       ( dut_ast_channel_o       ),
    .ast_ready_i         ( dut_ast_ready_i         )
  );


  task reset();
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;
  endtask

  initial
    begin
      ast_dmx_enviroment #( ast_dmx_transaction ) env;
      env = new();
      env.build( _sink_if, _source_if );
      reset();

      case (TEST_CASE)
        ONE_BYTE:
          begin
            env.run(ONE_BYTE, "CHECK ONE BYTE");
          end

        ONE_BYTE_RAND_READY:
          begin
            env.run(ONE_BYTE_RAND_READY, "CHECK ONE BYTE RANDOM READY");
          end

        MANY_BYTES_RAND_READY:
          begin
            env.run(MANY_BYTES_RAND_READY, "CHECK MANY BYTES RANDOM READY");
          end

        SWAP_DIRS_RAND_READY:
          begin
            env.run(SWAP_DIRS_RAND_READY, "CHECK SWAP DIRS RANDOM READY");
          end

        MAIN_TEST:
          begin
            env.run(ONE_BYTE, "CHECK ONE BYTE");
            env.run(ONE_BYTE_RAND_READY, "CHECK ONE BYTE RANDOM READY");
            env.run(MANY_BYTES_RAND_READY, "CHECK MANY BYTES RANDOM READY");
            env.run(SWAP_DIRS_RAND_READY, "CHECK SWAP DIRS RANDOM READY");
            env.run(MAIN_TEST, "CHECK MAIN TEST");
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


    

// event clk_pos_event;
// initial
//   begin
//     forever
//     @( posedge clk )
//     ->clk_pos_event;
//   end
endmodule
