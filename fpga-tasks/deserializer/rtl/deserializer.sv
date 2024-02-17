module deserializer (
    input  logic         clk_i,
    input  logic         srst_i,

    input  logic         data_i,
    input  logic         data_val_i,

    output logic [15:0]  deser_data_o,
    output logic         deser_data_val_o
);
  
  logic [3:0]   cnt;
  logic         deser_data_val;
  logic [15:0]  deser_data;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      cnt <= 1'b0;
    else
      if( data_val_i )
        cnt <= cnt + 1;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      deser_data_val <= 1'b0;
    else
      if( data_val_i && cnt == 15 )
        deser_data_val <= 1'b1;
      else
        deser_data_val <= 1'b0;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      deser_data <= '0;
    else
      if( data_val_i )
        begin
          deser_data    <= deser_data << 1;
          deser_data[0] <= data_i;
        end
  
  assign deser_data_o     = deser_data;
  assign deser_data_val_o = deser_data_val;

endmodule