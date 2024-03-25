module simple_counter#(
  parameter WIDTH = 16
)(
  input  logic                   clk_i,

  input  logic [WIDTH-1:0      ] data_i,
  output logic [$clog2(WIDTH):0] data_o
);

  logic [$clog2(WIDTH):0] cnt_out;


  always_ff @( posedge clk_i ) 
    data_o <= cnt_out;

  always_comb
    begin
      cnt_out = '0;

      for(int i = 0; i < WIDTH; i++) 
        cnt_out += data_i[i];
    end

endmodule
