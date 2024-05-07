module sc_ram #(
  parameter DWIDTH          = 16,
  parameter AWIDTH          = 4,
  parameter REGISTER_OUTPUT = 1
)(
  input               clk_i,

  input  [AWIDTH-1:0] wrreq_i, 
  input  [AWIDTH-1:0] rdreq_i, 
  
  input  [DWIDTH-1:0] data_i,

  output [DWIDTH-1:0] data_o

);

  reg   [DWIDTH-1:0] mem [2**AWIDTH-1:0];


  generate
    logic [DWIDTH-1:0] q;

    if( REGISTER_OUTPUT == 1 )
      begin
        always_ff @( posedge clk_i )
          begin
            mem[wrreq_i] <= data_i;
            q <= mem[rdreq_i];
          end
      end
    else
      begin
        always_ff @( posedge clk_i )
            mem[wrreq_i] <= data_i;
        assign q = mem[rdreq_i];
      end
  endgenerate

  assign data_o = q;

endmodule
