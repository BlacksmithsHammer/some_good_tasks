module main_sort #(
    parameter DWIDTH      = 8,
    parameter MAX_PKT_LEN = 16
)(
  input   clk_i,
  input   srst_i,

  input   [DWIDTH-1:0] snk_data_i,
  input                snk_startofpacket_i,
  input                snk_endofpacket_i,
  input                snk_valid_i,
  output               snk_ready_o,

  output  [DWIDTH-1:0] src_data_o,
  output               src_startofpacket_o,
  output               src_endofpacket_o,
  output               src_valid_o,
  input                src_ready_i
);
  ///////////////////////////////////////////////
  // FSM VARIABLES
  ///////////////////////////////////////////////
  enum logic [2:0] { 
    WAIT_STARTPACKET_S,
    WAIT_ENDPACKET_S,
    SORT_S,
    SEND_STARTPACKET_S,
    SEND_ENDPACKET_S
  } state, next_state;

  // logic for avalon-st interface
  logic                           stream_we_a;
  logic [$clog2(MAX_PKT_LEN)-1:0] stream_addr_a_reg;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      stream_addr_a_reg <= '0;
    else
      if( next_state == WAIT_ENDPACKET_S && snk_valid_i )
        stream_addr_a_reg <= stream_addr_a_reg + 1'b1;
      else
        if( next_state > SORT_S )
          if( stream_addr_a_reg != 0 )
            stream_addr_a_reg <= stream_addr_a_reg - 1'b1;
        
  assign stream_we_a =   snk_valid_i && 
                       ( next_state == WAIT_ENDPACKET_S || next_state == SORT_S);

  ///////////////////////////////////////////////
  // WIRES FOR SORT ALGORITHM
  ///////////////////////////////////////////////
  logic end_sorting;

  logic [(DWIDTH-1):0]            sort_data_a;
  logic [$clog2(MAX_PKT_LEN)-1:0] sort_addr_a;
  logic                           sort_we_a;

  logic [(DWIDTH-1):0]            sort_data_b;
  logic [$clog2(MAX_PKT_LEN)-1:0] sort_addr_b;
  logic                           sort_we_b;

  ///////////////////////////////////////////////
  // DUAL PORT RAM
  ///////////////////////////////////////////////

  // PORT A
  logic [(DWIDTH-1):0]            ram_data_a;
  logic [$clog2(MAX_PKT_LEN)-1:0] ram_addr_a;
  logic                           ram_we_a;
  logic [(DWIDTH-1):0]            ram_q_a;

  assign ram_data_a = ( state == SORT_S ) ? sort_data_a : snk_data_i ;
  // fix little problem with later reading from ram
  // may be need use a 2-nd PORT of RAM to read from avalon-st
  // (besides, it might be better for the path-tracing(?))
  assign ram_addr_a = ( state == SORT_S && next_state == SORT_S) ? sort_addr_a : stream_addr_a_reg ;
  assign ram_we_a   = ( state == SORT_S ) ? sort_we_a   : stream_we_a ;
  
  // PORT B
  logic [(DWIDTH-1):0]            ram_data_b;
  logic [$clog2(MAX_PKT_LEN)-1:0] ram_addr_b;
  logic                           ram_we_b;
  logic [(DWIDTH-1):0]            ram_q_b;

  assign ram_data_b = sort_data_b;
  assign ram_addr_b = sort_addr_b;
  assign ram_we_b   = sort_we_b;

  true_dual_port_ram_single_clock #(
    .DATA_WIDTH ( DWIDTH              ),
    .ADDR_WIDTH ( $clog2(MAX_PKT_LEN) )
  ) ram_ins(
    .clk    ( clk_i ),

    .data_a ( ram_data_a ),
    .addr_a ( ram_addr_a ),
    .we_a   ( ram_we_a   ),
    .q_a    ( ram_q_a    ),

    .data_b ( ram_data_b ),
    .addr_b ( ram_addr_b ),
    .we_b   ( ram_we_b   ),
    .q_b    ( ram_q_b    )
  );

  ///////////////////////////////////////////////
  // MAIN STATE MACHINE FOR AVALON-ST
  ///////////////////////////////////////////////
  // output data
  logic src_valid_d;

  assign src_data_o  = ram_q_a;
  assign snk_ready_o = ( state < SORT_S );
  assign src_valid_o = ( state > SORT_S ) || src_valid_d;
  assign src_startofpacket_o = ( state > SORT_S ) && ~src_valid_d;
  assign src_endofpacket_o   = ~( state > SORT_S ) && src_valid_d;

  logic  start_sorting;
  assign start_sorting = ( state == WAIT_ENDPACKET_S && next_state == SORT_S );

  always_ff @( posedge clk_i )
    if( srst_i )
      src_valid_d <= 1'b0;
    else
      src_valid_d <= ( state > SORT_S );

  always_ff @( posedge clk_i )
    if( srst_i )
      state <= WAIT_STARTPACKET_S;
    else
      state <= next_state;
  
  always_comb 
    begin
      next_state = state;
      case ( next_state )
        WAIT_STARTPACKET_S:
          begin
            if( snk_valid_i && snk_startofpacket_i )
              next_state = WAIT_ENDPACKET_S;
            else
              next_state = WAIT_STARTPACKET_S;
          end

        WAIT_ENDPACKET_S:
          begin
            if( snk_valid_i && snk_endofpacket_i )
              next_state = SORT_S;
            else
              next_state = WAIT_ENDPACKET_S;
          end

        SORT_S:
          begin
            if( end_sorting && stream_addr_a_reg == 1 )
              next_state = SEND_ENDPACKET_S;
            else 
              if( end_sorting )
                next_state = SEND_STARTPACKET_S;
              else
                next_state = SORT_S;
          end

        SEND_STARTPACKET_S:
          begin
            if( stream_addr_a_reg == 1 )
              next_state = SEND_ENDPACKET_S;
            else
              next_state = SEND_STARTPACKET_S;
          end

        SEND_ENDPACKET_S:
          begin
              next_state = WAIT_STARTPACKET_S;
          end

        default:
          begin
            next_state = WAIT_STARTPACKET_S;
          end
      endcase
    end

  ///////////////////////////////////////////////
  // INCLUDE SORT
  ///////////////////////////////////////////////
  insertion_sort #(
    .DWIDTH          ( DWIDTH            ),
    .MAX_PKT_LEN     ( MAX_PKT_LEN       )
  ) ins_sort (
    .clk_i           ( clk_i             ),
    .srst_i          ( srst_i            ),

    .last_addr       ( stream_addr_a_reg ),
    .start_sorting_i ( start_sorting     ),
    .end_sorting_o   ( end_sorting       ),

    .data_a_o        ( sort_data_a       ),
    .addr_a_o        ( sort_addr_a       ),
    .we_a_o          ( sort_we_a         ),
    .q_a_i           ( ram_q_a           ),

    .data_b_o        ( sort_data_b       ),
    .addr_b_o        ( sort_addr_b       ),
    .we_b_o          ( sort_we_b         ),
    .q_b_i           ( ram_q_b           )
  );


endmodule
