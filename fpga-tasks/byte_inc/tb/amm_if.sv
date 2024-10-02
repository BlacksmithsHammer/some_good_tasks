interface amm_if #(
  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
) (
  input clk,
  input srst
);
  logic                  waitrequest;
  logic [ADDR_WIDTH-1:0] address;
  logic [DATA_WIDTH-1:0] data;

  // reader
  logic                  read;
  logic                  datavalid;

  // writer
  logic                  write;
  logic [BYTE_CNT-1:0]   byteenable;

  default clocking cb
    @( posedge clk );
  endclocking

endinterface
