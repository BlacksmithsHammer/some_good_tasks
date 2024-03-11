module bit_population_counter_top #(
  parameter WIDTH         = 32,
  parameter SIZE_PIPELINE = 16
)(
  input  logic                      clk_i_top,
  input  logic                      srst_i_top,

  input  logic [WIDTH-1:0]          data_i_top,
  input  logic                      data_val_i_top,

  output logic [$clog2(WIDTH)+1:0]  data_o_top,
  output logic                      data_val_o_top
);

  logic                      srst;

  logic [WIDTH-1:0]          data;
  logic                      data_val;

  logic [$clog2(WIDTH)+1:0]  data_out;
  logic                      data_val_out;

  bit_population_counter #(
    .WIDTH         ( WIDTH         ),
    .SIZE_PIPELINE ( SIZE_PIPELINE )
  ) bit_population_counter_ins (
    .clk_i         ( clk_i_top     ),
    .srst_i        ( srst          ),

    .data_i        ( data          ),
    .data_val_i    ( data_val      ),

    .data_o        ( data_out      ),
    .data_val_o    ( data_val_out  )
  );

  always_ff @( posedge clk_i_top )
    srst <= srst_i_top;

  always_ff @( posedge clk_i_top )
    data <= data_i_top;

  always_ff @( posedge clk_i_top )
    data_val <= data_val_i_top;

  always_ff @( posedge clk_i_top )
    data_o_top <= data_out;

  always_ff @( posedge clk_i_top )
    data_val_o_top <= data_val_out;

endmodule