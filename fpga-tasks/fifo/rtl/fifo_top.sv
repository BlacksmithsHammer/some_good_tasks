module fifo_top #(
  parameter DWIDTH             = 64,
  parameter AWIDTH             = 10,
  parameter SHOWAHEAD          = 1,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 2,
  parameter REGISTER_OUTPUT    = 1
)(
  input  logic clk_i_top,
  input  logic srst_i_top,

  input  logic [DWIDTH-1:0]  data_i_top,
  input  logic               wrreq_i_top,
  input  logic               rdreq_i_top,
  
  output logic [DWIDTH-1:0]  q_o_top,

  output logic               empty_o_top,
  output logic               full_o_top,
  output logic [AWIDTH:0]    usedw_o_top,

  output logic               almost_full_o_top,
  output logic               almost_empty_o_top
);

  logic [DWIDTH-1:0]  data;
  logic               wrreq;
  logic               rdreq;

  logic [DWIDTH-1:0]  q;

  logic               empty;
  logic               full;
  logic [AWIDTH:0]    usedw;

  logic               almost_empty;
  logic               almost_full;
  

  fifo #(
    .DWIDTH             ( DWIDTH             ),
    .AWIDTH             ( AWIDTH             ),
    .SHOWAHEAD          ( SHOWAHEAD          ),
    .ALMOST_FULL_VALUE  ( ALMOST_FULL_VALUE  ),
    .ALMOST_EMPTY_VALUE ( ALMOST_EMPTY_VALUE ),
    .REGISTER_OUTPUT    ( REGISTER_OUTPUT    )
  ) ins (
    .clk_i   ( clk_i_top  ),
    .srst_i  ( srst_i_top ),
  
    .data_i  ( data  ),
    .wrreq_i ( wrreq ),
    .rdreq_i ( rdreq ),
    
    .q_o ( q ),
  
    .empty_o ( empty ),
    .full_o  ( full  ),
    .usedw_o ( usedw ),
  
    .almost_full_o  ( almost_full  ),
    .almost_empty_o ( almost_empty )
  );

// top -> ins
  always_ff @( posedge clk_i_top ) 
    data <= data_i_top;

  always_ff @( posedge clk_i_top ) 
    wrreq <= wrreq_i_top;

  always_ff @( posedge clk_i_top ) 
    rdreq <= rdreq_i_top;

// ins -> top
  always_ff @( posedge clk_i_top )
    q_o_top <= q;

  always_ff @( posedge clk_i_top )
    empty_o_top <= empty;

  always_ff @( posedge clk_i_top )
    full_o_top <= full;

  always_ff @( posedge clk_i_top )
    usedw_o_top <= usedw;

  always_ff @( posedge clk_i_top )
    almost_empty_o_top <= almost_empty;

  always_ff @( posedge clk_i_top )
    almost_full_o_top <= almost_full;

endmodule