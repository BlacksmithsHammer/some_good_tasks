module bit_population_counter#(
  parameter WIDTH         = 26,
  parameter SIZE_PIPELINE = 16
)(
  input  logic                      clk_i,
  input  logic                      srst_i,

  input  logic [WIDTH-1:0]          data_i,
  input  logic                      data_val_i,

  output logic [$clog2(WIDTH)+1:0]  data_o,
  output logic                      data_val_o
);
  
  logic [WIDTH-1:0]          data;
  logic                      data_val;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      data_val <= 1'b0;
    else
      data_val <= data_val_i;

  always_ff @( posedge clk_i )
    data <= data_i;
  

	 
	 
  generate
    if ( WIDTH <= 32 )
      begin
        logic [$clog2(WIDTH)+1:0]  cnt_no_pipe;
        always_comb
          begin
            cnt_no_pipe = '0;
            for(int i = 0; i < WIDTH; i++)
              begin
                if( data[i] == 1'b1)
                  cnt_no_pipe += 1'b1;
              end
          end

        assign data_val_o = data_val;
        assign data_o     = cnt_no_pipe;
      end
  endgenerate

  
endmodule