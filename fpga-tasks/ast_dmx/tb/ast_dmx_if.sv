interface ast_dmx_if #(
  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),

  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
) (
  input clk
);

  logic [DIR_SEL_WIDTH - 1 : 0] dir;
  
  logic [DATA_WIDTH    - 1 : 0] data;
  logic                         startofpacket;
  logic                         endofpacket;
  logic                         valid;
  logic [EMPTY_WIDTH   - 1 : 0] empty;
  logic [CHANNEL_WIDTH - 1 : 0] channel;
  logic                         ready;

  default clocking cb
    @( posedge clk );
    output  dir;
    output  data;
    output  startofpacket;
    output  endofpacket;
    output  valid;
    output  empty;
    output  channel;
    input   ready;
  endclocking

  clocking cbo
    @( posedge clk );
    input  dir;
    input  data;
    input  startofpacket;
    input  endofpacket;
    input  valid;
    input  empty;
    input  channel;
    output ready;
  endclocking

endinterface
