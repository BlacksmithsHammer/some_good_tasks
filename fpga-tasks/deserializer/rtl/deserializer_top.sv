module deserializer_top #(
  parameter DATA_WIDTH = 16
)(
  input  logic                   clk_i_top,
  input  logic                   srst_i_top,

  input  logic                   data_i_top,
  input  logic                   data_val_i_top,

  output logic [DATA_WIDTH-1:0]  deser_data_o_top,
  output logic                   deser_data_val_o_top
);

logic                   srst;

logic                   data;
logic                   data_val;

logic [DATA_WIDTH-1:0]  deser_data;
logic                   deser_data_val;

deserializer #(
    .DATA_WIDTH      ( DATA_WIDTH     )
) deserializer_ins (
  .clk_i             ( clk_i_top      ),
  .srst_i            ( srst           ),

  .data_i            ( data           ),
  .data_val_i        ( data_val       ),

  .deser_data_o      ( deser_data     ),
  .deser_data_val_o  ( deser_data_val )
);

always_ff @( posedge clk_i_top )
  srst <= srst_i_top;

always_ff @( posedge clk_i_top )
  data <= data_i_top;

always_ff @( posedge clk_i_top )
  data_val <= data_val_i_top;

always_ff @( posedge clk_i_top )
  deser_data_o_top <= deser_data;

always_ff @( posedge clk_i_top )
  deser_data_val_o_top <= deser_data_val;

endmodule