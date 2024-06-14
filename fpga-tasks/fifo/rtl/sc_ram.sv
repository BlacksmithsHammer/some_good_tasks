module sc_ram #(
  parameter DWIDTH          = 64,
  parameter AWIDTH          = 10,
  parameter REGISTER_OUTPUT = 0
)(
  input clk_i,

  input  [DWIDTH-1:0] data_i,

  input  [AWIDTH-1:0] rd_addr,
  input  [AWIDTH-1:0] wr_addr,

  input               wr_en,
  input               rd_en,

  output reg [DWIDTH-1:0] data_o
);
  
  reg [DWIDTH-1:0] mem [2**AWIDTH-1:0];

  generate
    if( REGISTER_OUTPUT )
      begin
        reg [DWIDTH-1:0] data_reg;

        always_ff @(posedge clk_i)
          if( wr_en )
            mem[wr_addr] <= data_i;
    
        always_ff @( posedge clk_i )
          data_reg <= mem[rd_addr];

        always_ff @( posedge clk_i )
		      if( rd_en )
		        data_o <= data_reg;
      end
    else
      begin
        always_ff @(posedge clk_i)
          if( wr_en )
            mem[wr_addr] <= data_i;

        always_ff @(posedge clk_i)
          if( rd_en )
            data_o <= mem[rd_addr];
      end
  endgenerate

endmodule