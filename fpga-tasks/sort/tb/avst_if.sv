interface avst_if #(
  parameter DWIDTH = 8
)(
  input clk,
  input srst
);

  clocking cb
    @(posedge clk);
  endclocking

  logic   [DWIDTH-1:0] data;
  logic                startofpacket;
  logic                endofpacket;
  logic                valid;
  logic                ready;

  modport sink (
    input  data,
    input  startofpacket,
    input  endofpacket,
    input  valid,
    output ready
  );

  modport source (
    output  data,
    output  startofpacket,
    output  endofpacket,
    output  valid,
    input   ready
  );

endinterface 
