module serializer (
  input  logic         clk_i,
  input  logic         srst_i,

  input  logic [15:0]  data_i,
  input  logic [3:0]   data_mod_i,
  input  logic         data_val_i,

  output logic         ser_data_o,
  output logic         ser_data_val_o,
  output logic         busy_o
);

  logic        busy;
  logic [3:0]  cnt;
  logic        ser_data_val;
  logic [15:0] data;
  logic        flag;

  assign flag = data_val_i && ~busy && ( data_mod_i > 2 || data_mod_i == 0 );

  always_ff @( posedge clk_i )
    if( srst_i )
      busy <= 1'b0;
    else
      if( flag )
        busy <= 1'b1;
      else
        if( cnt < 2 )
          busy <= 1'b0;
      
  always_ff @( posedge clk_i )
    if( srst_i )
      ser_data_val <= 1'b0;
    else
      if( flag )
        ser_data_val <= 1'b1;
      else
        if( ~busy )
          ser_data_val <= 1'b0;

  always_ff @( posedge clk_i )
    if( srst_i )
      cnt <= '0;
    else
      if( flag )
        cnt <= (data_mod_i - 4'b1);
      else
        if( cnt > 0 )
          cnt <= cnt - 1;

  always_ff @( posedge clk_i )
    if( srst_i )
      data <= '0;
    else
      if( flag )
        data <= data_i;
      else
        if( cnt > 0 )
          data <= data << 1;

  assign ser_data_o     = data[15];
  assign busy_o         = busy;
  assign ser_data_val_o = ser_data_val;

endmodule
