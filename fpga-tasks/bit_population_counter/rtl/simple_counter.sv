module simple_counter#(
  parameter WIDTH = 16
)(
  input  logic                   clk_i,

  input  logic [WIDTH-1:0      ] data_i,
  output logic [$clog2(WIDTH):0] data_o
);
  
  //logic [WIDTH-1:0 ]      data;
  logic [$clog2(WIDTH):0] cnt_out;

  //always_ff @( posedge clk_i ) 
  //  data <= data_i;

  always_ff @( posedge clk_i ) 
    data_o <= cnt_out;

  always_comb
    begin
      logic [$clog2(WIDTH):0] cnt;
      cnt = '0;

      for(int i = 0; i < WIDTH; i++) 
        if( data_i[i] == 1'b1 )
          cnt += 1'b1;
      cnt_out = cnt;
    end

  
endmodule

/*
module simple_counter#(
  parameter WIDTH = 16
)(
  input  logic [WIDTH-1:0      ] data_i,
  output logic [$clog2(WIDTH):0] data_o
);

  always_comb
    begin
      logic [$clog2(WIDTH):0] cnt;
      cnt = '0;

      for(int i = 0; i < WIDTH; i++) 
        if( data_i[i] == 1'b1 )
          cnt += 1'b1;
      data_o = cnt;
    end
endmodule*/