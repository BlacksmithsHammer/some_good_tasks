module priority_encoder_top#(
  parameter WIDTH = 16
)(
  input  logic              clk_i_top,
  input  logic              srst_i_top,

  input  logic [WIDTH-1:0]  data_i_top,
  input  logic              data_val_i_top,

  output logic [WIDTH-1:0]  data_left_o_top,
  output logic [WIDTH-1:0]  data_right_o_top,
  output logic              data_val_o_top
);

  logic              srst;

  logic [WIDTH-1:0]  data;
  logic              data_val_in;

  logic [WIDTH-1:0]  data_left;
  logic [WIDTH-1:0]  data_right;
  logic              data_val_out;

  priority_encoder #(
    .WIDTH         ( WIDTH        )
  ) priority_encoder_ins (
    .clk_i         ( clk_i_top    ),
    .srst_i        ( srst         ),

    .data_i        ( data         ),
    .data_val_i    ( data_val_in  ),

    .data_left_o   ( data_left    ),
    .data_right_o  ( data_right   ),
    .data_val_o    ( data_val_out )
  );


  always_ff @( posedge clk_i_top )
    srst             <= srst_i_top;

  always_ff @( posedge clk_i_top )
    data             <= data_i_top;

  always_ff @( posedge clk_i_top )
    data_val_in      <= data_val_i_top;

  always_ff @( posedge clk_i_top )
    data_left_o_top  <= data_left;

  always_ff @( posedge clk_i_top )
    data_right_o_top <= data_right;

  always_ff @( posedge clk_i_top )
    data_val_o_top   <= data_val_out;

endmodule