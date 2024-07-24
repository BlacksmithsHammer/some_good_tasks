interface lifo_if #(
  parameter int DWIDTH = 16,
  parameter int AWIDTH = 8
)(
    input  clk
);

  default clocking cb
    @( posedge clk );
  endclocking;
  
  logic              wrreq;
  logic [DWIDTH-1:0] data;
  logic              rdreq;

  logic [DWIDTH-1:0] q;
  logic              almost_empty;
  logic              empty;
  logic              almost_full;
  logic              full;
  logic [AWIDTH:0]   usedw;
      
endinterface 