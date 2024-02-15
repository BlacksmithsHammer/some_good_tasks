module serializer(
  input  logic        clk_150_mhz_i_top,
  input  logic        srst_i_top,
    
  input  logic [15:0] data_i_top,
  input  logic [3:0]  data_mod_i_top,
  input  logic        data_val_i_top,

  output logic        ser_data_o_top,
  output logic        ser_data_val_o_top,
  output logic        busy_o_top
);
  
  logic        srst;

  logic [15:0] data;
  logic [3:0]  data_mod;
  logic        data_val;

  logic        ser_data;
  logic        ser_data_val;
  logic        busy;

  logic        ser_data_o;
  logic        ser_data_val_o;
  logic        busy_o;

  serializer_worker ser_worker_ins(
    .clk_i          ( clk_150_mhz_i_top ),
    .srst_i         ( srst ),

    .data_i         ( data ),
    .data_mod_i     ( data_mod ),
    .data_val_i     ( data_val ),

    .ser_data_o     ( ser_data ),
    .ser_data_val_o ( ser_data_val ),
    .busy_o         ( busy )
  );


  always_ff @( posedge clk_150_mhz_i_top )
    //if( srst_i_top )
      srst <= srst_i_top;
    //else
    //  srst <= 1'b0;

  always_ff @( posedge clk_150_mhz_i_top )
    /*if( srst_i_top )
      data <= '0;
    else*/
      data <= data_i_top;

  always_ff @( posedge clk_150_mhz_i_top )
    /*if( srst_i_top )
      data_mod <= 1'b0;
    else*/
      data_mod <= data_mod_i_top;

  always_ff @( posedge clk_150_mhz_i_top )
    /*if( srst_i_top )
      data_val <= 1'b0;
    else*/
      data_val <= data_val_i_top;

  always_ff @( posedge clk_150_mhz_i_top )
    ser_data_o <= ser_data;

  always_ff @( posedge clk_150_mhz_i_top )
    ser_data_val_o <= ser_data_val;

  always_ff @( posedge clk_150_mhz_i_top )
    busy_o <= busy;

  assign ser_data_o_top     = ser_data_o;
  assign ser_data_val_o_top = ser_data_val_o;
  assign busy_o_top         = busy_o;

endmodule