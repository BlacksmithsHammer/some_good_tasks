interface ast_dmx_if #(
  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),

  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
) (
  input clk
);

  default clocking cb
    @( posedge clk );
  endclocking
  

  logic [DIR_SEL_WIDTH - 1 : 0] dir;
  
  logic [DATA_WIDTH    - 1 : 0] data;
  logic                         startofpacket;
  logic                         endofpacket;
  logic                         valid;
  logic [EMPTY_WIDTH   - 1 : 0] empty;
  logic [CHANNEL_WIDTH - 1 : 0] channel;
  logic                         ready;
  
endinterface