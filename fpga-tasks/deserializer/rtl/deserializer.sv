module deserializer #(
  parameter DATA_WIDTH = 16
)(
  input  logic                   clk_i,
  input  logic                   srst_i,

  input  logic                   data_i,
  input  logic                   data_val_i,

  output logic [DATA_WIDTH-1:0]  deser_data_o,
  output logic                   deser_data_val_o
);
  
  logic [$clog2(DATA_WIDTH)-1:0]  cnt;
  logic                           deser_data_val;
  logic [DATA_WIDTH-1:0]          deser_data;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      cnt <= '0;
    else
      if( data_val_i)
        if( cnt != (DATA_WIDTH-1))
          cnt <= cnt + 1'b1;
        else
          cnt <= '0;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      deser_data_val <= 1'b0;
    else
      if( data_val_i && ( cnt == (DATA_WIDTH-1) ) )
        deser_data_val <= 1'b1;
      else
        deser_data_val <= 1'b0;

  always_ff @( posedge clk_i ) 
    if( data_val_i )
      deser_data <= { deser_data[(DATA_WIDTH-2):0], data_i };
        
  assign deser_data_o     = deser_data;
  assign deser_data_val_o = deser_data_val;

endmodule
