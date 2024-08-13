interface ast_we_if #(
  parameter DATA_IN_W   = 64,
  parameter EMPTY_IN_W  = $clog2(DATA_IN_W/8) ?  $clog2(DATA_IN_W/8) : 1,
  parameter CHANNEL_W   = 10,
  parameter DATA_OUT_W  = 256,
  parameter EMPTY_OUT_W = $clog2(DATA_OUT_W/8) ?  $clog2(DATA_OUT_W/8) : 1
)(
  input clk
);

  default clocking cb
    @( posedge clk );
  endclocking

  logic [DATA_IN_W-1:0]   sink_data;
  logic                   sink_startofpacket;
  logic                   sink_endofpacket;
  logic                   sink_valid;
  logic [EMPTY_IN_W-1:0]  sink_empty;
  logic [CHANNEL_W-1:0]   sink_channel;
  logic                   sink_ready;

  logic [DATA_OUT_W-1:0]  source_data;
  logic                   source_startofpacket;
  logic                   source_endofpacket;
  logic                   source_valid;
  logic [EMPTY_OUT_W-1:0] source_empty;
  logic [CHANNEL_W-1:0]   source_channel;
  logic                   source_ready;

endinterface