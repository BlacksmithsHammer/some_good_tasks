module priority_encoder#(
  parameter WIDTH = 16
)(
  input  logic              clk_i,
  input  logic              srst_i,

  input  logic [WIDTH-1:0]  data_i,
  input  logic              data_val_i,

  output logic [WIDTH-1:0]  data_left_o,
  output logic [WIDTH-1:0]  data_right_o,
  output logic              data_val_o
);

  logic [WIDTH-1:0]  data;
  logic              data_val;

  always_ff @( posedge clk_i )
    if( srst_i )
      data <= '0;
    else
      if( data_val_i )
        data <= data_i;
  
  always_ff @( posedge clk_i )
    if( srst_i )
      data_val <= 1'b0;
    else
      if( data_val_i )
        data_val <= 1'b1;
      else
        data_val <= 1'b0;

  always_comb 
    begin
      data_right_o = '0;
      for(int i = 0; i < WIDTH; i = i + 1) 
      begin
        if(data[i] == 1'b1) 
          begin
            data_right_o = 1'b1 << i;
            break;
          end
      end

      data_left_o = '0;
      for(int i = WIDTH - 1; i >= 0; i = i - 1) 
      begin
        if(data[i] == 1'b1) 
          begin
            data_left_o = 1'b1 << i;
            break;
          end
      end
    end

  assign data_val_o = data_val;

endmodule