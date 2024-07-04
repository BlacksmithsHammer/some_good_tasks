interface sort_avst_if #(
  parameter DWIDTH = 8
)(
  input clk,
  input srst
);
  logic   [DWIDTH-1:0] snk_data;
  logic                snk_startofpacket;
  logic                snk_endofpacket;
  logic                snk_valid;
  logic                snk_ready;

  logic   [DWIDTH-1:0] src_data;
  logic                src_startofpacket;
  logic                src_endofpacket;
  logic                src_valid;
  logic                src_ready;

  modport sink (
    input  snk_data,
    input  snk_startofpacket,
    input  snk_endofpacket,
    input  snk_valid,
    output snk_ready
  );

  modport source (
    output  src_data,
    output  src_startofpacket,
    output  src_endofpacket,
    output  src_valid,
    input   src_ready
  );

endinterface 
