module fifo #(
  parameter DWIDTH             = 16,
  parameter AWIDTH             = 4,
  parameter SHOWAHEAD          = 1,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 2,
  parameter REGISTER_OUTPUT    = 0
)(
  input  logic clk_i,
  input  logic srst_i,

  input  logic [DWIDTH-1:0]  data_i,
  input  logic               wrreq_i,
  input  logic               rdreq_i,
  
  output logic [DWIDTH-1:0]  q_o,

  output logic               empty_o,
  output logic               full_o,
  output logic [AWIDTH:0]    usedw_o,

  output logic               almost_full_o,
  output logic               almost_empty_o
);

//===============================================
// variables block
//===============================================
// main memory array
  logic [DWIDTH-1:0]  mem [2**AWIDTH-1:0];

  logic [AWIDTH-1:0]  addr_rd;
  logic [AWIDTH-1:0]  addr_wr;

  logic [AWIDTH:0]    usedw;

// wires for check a limits of usedw
  logic allow_read;
  logic allow_write;

// wires for check a new valid requests
  logic valid_rdreq;
  logic valid_wrreq;

//===============================================
// combinational block
//===============================================

  assign allow_write = ( usedw < 2**AWIDTH ) ? 1'b1 : 1'b0;
  assign allow_read  = ( usedw > 0         ) ? 1'b1 : 1'b0;

  assign valid_wrreq = ( allow_write && wrreq_i ) ? 1'b1 : 1'b0;
  assign valid_rdreq = ( allow_read  && rdreq_i ) ? 1'b1 : 1'b0;

//===============================================
// registers block
//===============================================

  always @( posedge clk_i )
    if( srst_i )
      addr_rd <= '0;
    else
      if( valid_rdreq )
        addr_rd <= addr_rd + 1'b1;

  always @( posedge clk_i )
    if( srst_i )
      addr_wr <= '0;
    else
      if( valid_wrreq )
        addr_wr <= addr_wr + 1'b1;

  always @( posedge clk_i )
    if( srst_i )
      usedw <= '0;
    else
      if( valid_wrreq && ~valid_rdreq )
        usedw <= usedw + 1'b1;
      else
        if( ~valid_wrreq && valid_rdreq )
          usedw <= usedw - 1'b1;
  
  always @( posedge clk_i )
    if( valid_wrreq )
      mem[addr_wr] <= data_i;

//===============================================
// output assignments block
//===============================================

  assign q_o     = mem[addr_rd];
  assign usedw_o = usedw;

  assign almost_full_o  = ( usedw >= ALMOST_FULL_VALUE  ) ? 1'b1 : 1'b0;
  assign almost_empty_o = ( usedw  < ALMOST_EMPTY_VALUE ) ? 1'b1 : 1'b0;

  assign empty_o = ( usedw == 0         ) ? 1'b1 : 1'b0;
  assign full_o  = ( usedw == 2**AWIDTH ) ? 1'b1 : 1'b0;
    
endmodule