module fifo #(
  //////////////////////////////////////////////////////////
  // parameters
  //////////////////////////////////////////////////////////
  parameter DWIDTH             = 64,
  parameter AWIDTH             = 10,
  parameter SHOWAHEAD          = 1,
  parameter ALMOST_FULL_VALUE  = 12,
  parameter ALMOST_EMPTY_VALUE = 2,
  parameter REGISTER_OUTPUT    = 0
)(
  //////////////////////////////////////////////////////////
  // ports
  //////////////////////////////////////////////////////////
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
  
  //////////////////////////////////////////////////////////
  // fifo variables
  //////////////////////////////////////////////////////////
  logic have_words_in_mem;
  logic data_in_mem;
  logic data_showed;
  logic need_show;
  logic last_showed;
  logic read_next;
  logic data_in_reg;
  logic data_wait_reg;

  //////////////////////////////////////////////////////////
  // ram variables
  //////////////////////////////////////////////////////////
  logic  [AWIDTH-1:0] rd_addr;
  logic  [AWIDTH-1:0] wr_addr;

  logic  [AWIDTH-1:0] rd_addr_reg;
  logic  [AWIDTH-1:0] wr_addr_reg;

  logic               wr_en;
  logic               rd_en;

  logic  [AWIDTH:0]   usedw;

  //////////////////////////////////////////////////////////
  // ram common logic for every mode
  //////////////////////////////////////////////////////////
  assign wr_en   = wrreq_i && !full_o;
  assign wr_addr = wr_addr_reg;

  always_ff @( posedge clk_i )
    if( srst_i )
      wr_addr_reg <= '0;
    else 
      if( wr_en )
        wr_addr_reg <= wr_addr_reg + 1'b1;
  
  always_ff @( posedge clk_i )
    if( srst_i )
      rd_addr_reg <= '0;
    else
      if( rd_en )
        rd_addr_reg <= rd_addr_reg + 1'b1;


  //////////////////////////////////////////////////////////
  // fifo output common assignments for every mode
  //////////////////////////////////////////////////////////
  assign almost_full_o  = usedw_o >=  ALMOST_FULL_VALUE;
  assign almost_empty_o = usedw_o < ALMOST_EMPTY_VALUE;

  assign usedw_o = usedw;
  assign full_o  = usedw[AWIDTH];

  //////////////////////////////////////////////////////////
  // main FIFO logic
  //////////////////////////////////////////////////////////
  generate
    if( REGISTER_OUTPUT && SHOWAHEAD )
      begin
        assign read_next   = rdreq_i && data_showed && !last_showed;
        assign need_show   = !data_showed && data_in_reg;
        assign last_showed = ( data_showed && !data_in_reg );

        assign rd_en = ( read_next || need_show );

        always_ff @( posedge clk_i )
          if( srst_i )
            data_showed <= 1'b0;
          else
            if( need_show )
              data_showed <= 1'b1;
            else
              if( rdreq_i && last_showed )
                data_showed <= 1'b0;

        always_ff @( posedge clk_i )
          if( srst_i )
            usedw <= '0;
          else
            if( last_showed && rdreq_i )
              usedw <= usedw + wr_en - 1'b1;
            else
              if( data_showed )
                usedw <= usedw + wr_en - rd_en;
              else
                // without rd_en: need show new element
                // because last element showed and skipped
                usedw <= usedw + wr_en;

        // subtract data_showed to get real number of words in mem
        // [usedw - data_showed > 1] -> [usedw > 1 + data_showed]
        // 4 ALM's saved
        assign have_words_in_mem = ( usedw > 1 + data_showed );

        always @( posedge clk_i )
          if( srst_i )
            data_in_mem <= 1'b0;
          else
            if( wr_en )
              data_in_mem <= 1'b1;
            else
              if( rd_en )
                data_in_mem <= have_words_in_mem;

        always_ff @( posedge clk_i )
          if( srst_i )
            data_in_reg <= 1'b0;
          else
            if( rd_en && !have_words_in_mem )
              data_in_reg <= 1'b0;
            else
              data_in_reg <= data_in_mem;

        assign rd_addr = ( usedw != 0 && rd_en ) ? rd_addr_reg + 1'b1 : rd_addr_reg ;
        assign empty_o = !data_showed;
      end
    else if( !REGISTER_OUTPUT && SHOWAHEAD )
      begin
        assign last_showed = data_showed  && usedw == 1;

        assign need_show   = !data_showed && data_in_mem;
        assign read_next   = rdreq_i && data_showed && !last_showed;

        assign rd_en = ( read_next || need_show );

        always_ff @( posedge clk_i )
          if( srst_i )
            data_in_mem <= 1'b0;
          else
            if ( wr_en || usedw > 1 )
              data_in_mem <= 1'b1;
            else
              data_in_mem <= 1'b0;
        
        always_ff @( posedge clk_i )
          if( srst_i )
            data_showed <= 1'b0;
          else
            if( need_show )
              data_showed <= 1'b1;
            else
              if( rdreq_i && last_showed )
                data_showed <= 1'b0;

        always_ff @( posedge clk_i )
          if( srst_i )
            usedw <= '0;
          else
            if( last_showed && rdreq_i )
              usedw <= wr_en;
            else
              if( data_showed )
                usedw <= usedw + wr_en - rd_en;
              else
                // without rd_en: need show new element
                // because last element showed and skipped
                usedw <= usedw + wr_en;
              
        assign rd_addr = rd_addr_reg;
        assign empty_o = !data_showed;
      end
    else if( REGISTER_OUTPUT && !SHOWAHEAD )
      begin
        assign rd_en = ( rdreq_i && data_in_reg );

        always_ff @( posedge clk_i )
          if( srst_i )
            usedw <= '0;
          else
            usedw <= usedw_o + wr_en - rd_en;  

        assign have_words_in_mem = ( usedw > 1 );

        always @( posedge clk_i )
          if( srst_i )
            data_in_mem <= 1'b0;
          else
            if( wr_en )
              data_in_mem <= 1'b1;
            else
              if( rd_en )
                data_in_mem <= have_words_in_mem;

        always_ff @( posedge clk_i )
          if( srst_i )
            data_in_reg <= 1'b0;
          else
            if( rd_en && !have_words_in_mem )
              data_in_reg <= 1'b0;
            else
              data_in_reg <= data_in_mem;

        assign rd_addr = ( usedw != 0 && rd_en ) ? rd_addr_reg + 1'b1 : rd_addr_reg ;
        assign empty_o = !data_in_reg;
      end
    else if ( !REGISTER_OUTPUT && !SHOWAHEAD )
      begin
        assign rd_en = rdreq_i && data_in_mem;

        always_ff @( posedge clk_i )
          if( srst_i )
            usedw <= '0;
          else
            usedw <= usedw_o + wr_en - rd_en;

        assign have_words_in_mem = ( usedw > 1 );

        always @( posedge clk_i )
          if( srst_i )
            data_in_mem <= 1'b0;
          else
            if( wr_en )
              data_in_mem <= 1'b1;
            else
              if( rd_en )
                data_in_mem <= have_words_in_mem;

        assign rd_addr = rd_addr_reg;
        assign empty_o = !data_in_mem;
      end
  endgenerate

  //////////////////////////////////////////////////////////
  // ram instance
  //////////////////////////////////////////////////////////
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
