interface byte_inc_set_if #(
  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
) (
  input clk
);
  logic                  srst;

  logic [ADDR_WIDTH-1:0] base_addr;
  logic [ADDR_WIDTH-1:0] length;
  logic                  run;
  logic                  waitrequest;

  default clocking cb
    @( posedge clk );
  endclocking

endinterface
