module main_sort_top #(
    parameter DWIDTH      = 32,
    parameter MAX_PKT_LEN = 128
)(
  input                clk_i_top,
  input                srst_i_top,

  input   [DWIDTH-1:0] snk_data_i_top,
  input                snk_startofpacket_i_top,
  input                snk_endofpacket_i_top,
  input                snk_valid_i_top,
  output               snk_ready_o_top,

  output  [DWIDTH-1:0] src_data_o_top,
  output               src_startofpacket_o_top,
  output               src_endofpacket_o_top,
  output               src_valid_o_top,
  input                src_ready_i_top
);

  logic  [DWIDTH-1:0] snk_data;
  logic               snk_startofpacket;
  logic               snk_endofpacket;
  logic               snk_valid;
  logic               snk_ready;

  logic  [DWIDTH-1:0] src_data;
  logic               src_startofpacket;
  logic               src_endofpacket;
  logic               src_valid;
  logic               src_ready;

  main_sort #(
    .DWIDTH      ( DWIDTH      ),
    .MAX_PKT_LEN ( MAX_PKT_LEN )
  ) main_sort_ins (
    .clk_i               ( clk_i_top         ),
    .srst_i              ( srst_i_top        ),

    .snk_data_i          ( snk_data          ),
    .snk_startofpacket_i ( snk_startofpacket ),
    .snk_endofpacket_i   ( snk_endofpacket   ),
    .snk_valid_i         ( snk_valid         ),
    .snk_ready_o         ( snk_ready         ),

    .src_data_o          ( src_data          ),
    .src_startofpacket_o ( src_startofpacket ),
    .src_endofpacket_o   ( src_endofpacket   ),
    .src_valid_o         ( src_valid         ),
    .src_ready_i         ( src_ready         )
  );


  // top -> ins
  always_ff @( posedge clk_i_top )
    snk_data <= snk_data_i_top;

  always_ff @( posedge clk_i_top )
    snk_startofpacket <= snk_startofpacket_i_top;

  always_ff @( posedge clk_i_top )
    snk_endofpacket <= snk_endofpacket_i_top;

  always_ff @( posedge clk_i_top )
    snk_valid <= snk_valid_i_top;

  always_ff @( posedge clk_i_top )
    src_ready <= src_ready_i_top;

  // ins -> top
  always_ff @( posedge clk_i_top )
    snk_ready_o_top <= snk_ready;

  always_ff @( posedge clk_i_top )
    src_data_o_top <= src_data;

  always_ff @( posedge clk_i_top )
    src_startofpacket_o_top <= src_startofpacket;

  always_ff @( posedge clk_i_top )
    src_endofpacket_o_top <= src_endofpacket;

  always_ff @( posedge clk_i_top )
    src_valid_o_top <= src_valid;

endmodule