module fifo #(
  parameter DWIDTH             = 64,
  parameter AWIDTH             = 10,
  parameter SHOWAHEAD          = 1,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 2,
  parameter REGISTER_OUTPUT    = 1
)(
  input  logic clk_i,
  input  logic srst_i,

  input  logic [DWIDTH-1:0]  data_i,
  input  logic               wrreq_i,
  input  logic               rdreq_i,

  output logic               empty_o,
  output logic               full_o,
  output logic [AWIDTH:0]    usedw_o,

  output logic               almost_full_o,
  output logic               almost_empty_o,

  output logic [DWIDTH-1:0]  q_o
);

  logic  [AWIDTH-1:0] rd_addr;
  logic  [AWIDTH-1:0] wr_addr;

  logic  [AWIDTH-1:0] rd_addr_reg = 0;
  logic  [AWIDTH-1:0] wr_addr_reg = 0;

  logic               wr_en;
  logic               rd_en;

  logic  [AWIDTH:0]   usedw  = 0;

  generate
    if( !REGISTER_OUTPUT && SHOWAHEAD )
      begin
        logic showed = 1'b0;
        logic need_show;
        logic last_showed;

        assign last_showed = !wr_en && usedw == 1 && showed;
        assign need_show = !showed && usedw == 1;
        assign wr_en = (wrreq_i && usedw != 2**AWIDTH) ? 1'b1 : 1'b0;
        assign rd_en = (rdreq_i && usedw != '0 && showed || need_show) && !last_showed ? 1'b1 : 1'b0;

        
        always_ff @( posedge clk_i )
          if( wr_en )
            wr_addr_reg <= wr_addr_reg + 1'b1;
  
        always_ff @( posedge clk_i )
          if( rd_en )
            rd_addr_reg <= rd_addr_reg + 1'b1;
  
        always_ff @( posedge clk_i )
          if( rdreq_i && last_showed )
            usedw <= '0;
          else if( need_show )
            usedw <= usedw + wr_en;
          else
            usedw <= usedw + wr_en - rd_en;

        
        always_ff @( posedge clk_i )
          if( usedw == 0 )
            showed <= 1'b0;
          else
            showed <= 1'b1;
        
        assign wr_addr = wr_addr_reg;
        assign rd_addr = rd_addr_reg;
        assign full_o  = ( usedw == 2**AWIDTH );
        assign usedw_o = ( usedw );
        assign empty_o = ( usedw == 0 || need_show);
      end
    else if( REGISTER_OUTPUT && !SHOWAHEAD)
      begin
        logic data_d = 0;

        assign wr_en = (wrreq_i && (usedw + data_d) != 2**AWIDTH) ? 1'b1 : 1'b0;
        assign rd_en = (rdreq_i && usedw != 0 ) ? 1'b1 : 1'b0;

        always_ff @( posedge clk_i )
          if( wr_en )
            wr_addr_reg <= wr_addr_reg + 1'b1;
        
        always_ff @( posedge clk_i )
          if( rd_en )
            rd_addr_reg <= rd_addr_reg + 1'b1;

        always_ff @( posedge clk_i )
          if( wr_en )
            data_d <= 1'b1;
          else
            data_d <= 1'b0;

        always_ff @( posedge clk_i )
          usedw <= usedw + data_d - rd_en;

        
        assign wr_addr = wr_addr_reg;
        assign rd_addr = ( usedw != 0 && rd_en ) ? rd_addr_reg + 1'b1 : rd_addr_reg ;
        assign full_o  = ( ( usedw + data_d ) == 2**AWIDTH );
        assign usedw_o = ( usedw + data_d );
        assign empty_o = ( usedw == 0 );
      end
    else if (!REGISTER_OUTPUT && !SHOWAHEAD)
      begin
        assign wr_en = (wrreq_i && usedw != 2**AWIDTH) ? 1'b1 : 1'b0;
        assign rd_en = (rdreq_i && usedw != '0) ? 1'b1 : 1'b0;

        always_ff @( posedge clk_i )
          if( wr_en )
            wr_addr_reg <= wr_addr_reg + 1'b1;
  
        always_ff @( posedge clk_i )
          if( rd_en )
            rd_addr_reg <= rd_addr_reg + 1'b1;
  
        always_ff @( posedge clk_i )
          usedw <= usedw + wr_en - rd_en;
        
        assign wr_addr = wr_addr_reg;
        assign rd_addr = rd_addr_reg;
        assign full_o  = ( usedw == 2**AWIDTH );
        assign usedw_o = usedw;
        assign empty_o = ( usedw == 0 );
      end
  endgenerate


  sc_ram #(
    .DWIDTH          ( DWIDTH          ),
    .AWIDTH          ( AWIDTH          ),
    .REGISTER_OUTPUT ( REGISTER_OUTPUT )
  ) ram_ins (
    .clk_i   ( clk_i   ),

    .data_i  ( data_i  ),

    .rd_addr ( rd_addr ),
    .wr_addr ( wr_addr ),

    .wr_en   ( wr_en   ),
    .rd_en   ( rd_en   ),

    .data_o  ( q_o     )
  );


    
endmodule