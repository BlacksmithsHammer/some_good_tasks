module ram_scfifo_top #(
  parameter DWIDTH          = 64,
  parameter AWIDTH          = 10,
  parameter REGISTER_OUTPUT = 0
)(
  input               clk_i_top,

  input  [DWIDTH-1:0] data_i_top,

  input  [AWIDTH-1:0] rd_addr_top,
  input  [AWIDTH-1:0] wr_addr_top,

  input               wr_en_top,
  input               rd_en_top,

  output [DWIDTH-1:0] data_o_top
);
  

  logic  [DWIDTH-1:0] data_i;
  logic  [DWIDTH-1:0] data_o;

  logic  [AWIDTH-1:0] rd_addr;
  logic  [AWIDTH-1:0] wr_addr;

  logic               wr_en;
  logic               rd_en;


  ram_scfifo #(
    .DWIDTH          ( DWIDTH          ),
    .AWIDTH          ( AWIDTH          ),
    .REGISTER_OUTPUT ( REGISTER_OUTPUT )
  ) ram_ins (
    .clk_i   ( clk_i_top ),

    .data_i  ( data_i    ),

    .rd_addr ( rd_addr   ),
    .wr_addr ( wr_addr   ),

    .wr_en   ( wr_en     ),
    .rd_en   ( rd_en     ),

    .data_o  ( data_o    )
  );
  
  always_ff @( posedge clk_i_top )
    data_i <= data_i_top;

  always_ff @( posedge clk_i_top )
    rd_addr <= rd_addr_top;

  always_ff @( posedge clk_i_top )
    wr_addr <= wr_addr_top;

  always_ff @( posedge clk_i_top )
    wr_en <= wr_en_top;

  always_ff @( posedge clk_i_top )
    rd_en <= rd_en_top;

  always_ff @( posedge clk_i_top )
    data_o_top <= data_o;


endmodule