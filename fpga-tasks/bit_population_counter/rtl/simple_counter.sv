module simple_counter#(
  parameter WIDTH    = 16,
  parameter DATA_O_D = 0
)(
  input  logic                   clk_i,

  input  logic [WIDTH-1:0      ] data_i,
  output logic [$clog2(WIDTH):0] data_o
);

  logic [$clog2(WIDTH):0] cnt_out;

  //1 or 0 for length of dff of data_o. something else - NONE
  //obviously, it is possible to generate a long dff for data larger than 256 bits (lazy solution)
  /*generate
  if( DATA_O_D == 1 )
    begin
      always_ff @( posedge clk_i ) 
        data_o <= cnt_out;
    end
  else if( DATA_O_D == 0 )
    begin
      assign data_o = cnt_out;
    end
  endgenerate*/

  always_ff @( posedge clk_i ) 
    data_o <= cnt_out;

  always_comb
    begin
      cnt_out = '0;

      for(int i = 0; i < WIDTH; i++) 
        cnt_out += data_i[i];
    end

endmodule
