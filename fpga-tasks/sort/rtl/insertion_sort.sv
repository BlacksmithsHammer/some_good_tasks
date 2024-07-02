module insertion_sort #(
  parameter DWIDTH      = 8,
  parameter MAX_PKT_LEN = 16
)(
  input                             clk_i,
  input                             srst_i,
  // control signals
  input   [$clog2(MAX_PKT_LEN)-1:0] last_addr,
  input                             start_sorting_i,
  output                            end_sorting_o,
  // PORT A
  output  [(DWIDTH-1):0]            data_a_o,
  output  [$clog2(MAX_PKT_LEN)-1:0] addr_a_o,
  output                            we_a_o,
  input   [(DWIDTH-1):0]            q_a_i,
  // PORT B
  output  [(DWIDTH-1):0]            data_b_o,
  output  [$clog2(MAX_PKT_LEN)-1:0] addr_b_o,
  output                            we_b_o,
  input   [(DWIDTH-1):0]            q_b_i

);
  logic [1:0] start_sort_d;
  logic       sort_state;
  logic [2:0] change_i_d;
  // indexes of compared elements
  logic [$clog2(MAX_PKT_LEN)-1:0] i;
  logic [$clog2(MAX_PKT_LEN)-1:0] j;
  // dff because we have delay in registered ram - 2 cycles
  // j_swap_d[2] - saved index of max or min element
  // j_value     - saved value of max or min to swap
  logic [2:0][$clog2(MAX_PKT_LEN)-1:0] j_swap_d;
  logic [(DWIDTH-1):0]                 j_value;

  logic [(DWIDTH-1):0] q_a_i_reg;
  logic [(DWIDTH-1):0] q_b_i_reg;

  logic need_swap;
  assign need_swap = ( j_swap_d[0] != i ) && ( j_value > q_b_i_reg );

  always_ff @( posedge clk_i )
    if( j_swap_d[0] == i + 1'b1 && j_swap_d[1] == i )//i + 1'b1 == j && i + 1'b1 != last_addr )
      j_value <= q_a_i;
    else
      if( need_swap )
        j_value <= q_b_i_reg;
      

  always_ff @( posedge clk_i )
    if( srst_i )
      change_i_d <= '0;
    else
      if( change_i_d[2] )
        begin
          $display("change at %6d", $time);
          change_i_d <= '0;
        end
      else
        if( sort_state )
          change_i_d <= {change_i_d[1:0], j == last_addr};

  always_ff @( posedge clk_i )
    if( srst_i )
      j_swap_d <= '0;
    else
      if( start_sorting_i )
        j_swap_d <= '0;
      else
        if( change_i_d[2] )
          {j_swap_d[2], j_swap_d[1], j_swap_d[0]} <= {3{i + 1'b1}};
        else
          begin
            j_swap_d[1:0] <= { j_swap_d[0], j};
            if( need_swap )
              j_swap_d[2] <= j_swap_d[1];
          end
  
  always_ff @( posedge clk_i )
    if( srst_i )
      start_sort_d <= '0;
    else
      start_sort_d <= {start_sort_d[0], start_sorting_i};
  
  always_ff @( posedge clk_i )
    if( srst_i )
      sort_state <= 1'b0;
    else
      if( start_sort_d[1] )
        sort_state <= 1'b1;
      else
        if( i == last_addr - 1 && change_i_d[2])
          sort_state <= 1'b0;

  always_ff @( posedge clk_i )
    if( srst_i )
      i <= '0;
    else
      if( start_sorting_i )
        i <= '0;
      else
        if( j == last_addr && i + 1 != last_addr && change_i_d[2] )
          i <= i + 1'b1;

  always_ff @( posedge clk_i )
    if( srst_i )
      j <= '0;
    else
      if( start_sorting_i )
        j <= '0;
      else
        if( sort_state )
          if( j < last_addr )
            j <= j + 1'b1;
          else
            if( change_i_d[2] )
            // may change to i + 2
            // but need add into if one new condition
              j <= i + 1'b1; 

  always_ff @( posedge clk_i )
    if( srst_i )
      q_a_i_reg <= '0;
    else
      if( sort_state )
        q_a_i_reg <= q_a_i;

  always_ff @( posedge clk_i )
    if( srst_i )
      q_b_i_reg <= '0;
    else
      q_b_i_reg <= q_b_i;


  ///////////////////////////////////////////////
  // RAM control
  ///////////////////////////////////////////////
  assign we_a_o = change_i_d[2];
  assign we_b_o = change_i_d[2];

  assign data_a_o = j_value;
  assign data_b_o = q_a_i_reg;

  assign addr_a_o = i;
  assign addr_b_o = change_i_d[2] ? j_swap_d[2] : j ;

  ///////////////////////////////////////////////
  // output state
  ///////////////////////////////////////////////
  assign end_sorting_o = ~(sort_state || |start_sort_d);
  
endmodule

  // insertion-like sort
  // for (int i = 0; i <= last_addr; i++)
  //   for (int j = i; j <= last_addr; j++)
  //     if (arr[i] > arr[j]) 
  //       swap(arr[i], arr[j]);


  // bug when [j == lastaddr] and need swap it not fixed

  // logic start_sort_d;
  // logic sort_state;

  // logic need_swap;
  // logic [$clog2(MAX_PKT_LEN)-1:0] i;
  // logic [$clog2(MAX_PKT_LEN)-1:0] j;

  // logic [$clog2(MAX_PKT_LEN)-1:0] i_prev;
  // logic [$clog2(MAX_PKT_LEN)-1:0] j_prev;

  // assign need_swap = ( q_a_i < q_b_i );

  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     start_sort_d <= 1'b0;
  //   else
  //     start_sort_d <= start_sorting_i;
  
  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     sort_state <= 1'b0;
  //   else
  //     if( start_sort_d )
  //       sort_state <= 1'b1;
  //     else
  //       if( i == last_addr )
  //         sort_state <= 1'b0;
  // always_ff @( posedge clk_i )
  //   if( start_sorting_i )
  //     i <= '0;
  //   else
  //     if( sort_state )
  //       if( j == last_addr )
  //         i <= i + 1;

  // always_ff @( posedge clk_i )
  //   if( start_sorting_i )
  //     j <= 0;
  //   else
  //     if( sort_state )
  //       if( !need_swap )
  //         if( j == last_addr )
  //           j <= i + 2;
  //         else
  //           j <= j + 1;
  
  // always_ff @( posedge clk_i )
  //   i_prev <= i;
  
  // always_ff @( posedge clk_i )
  //   j_prev <= j;

  // assign data_a_o = q_b_i;
  // assign addr_a_o = need_swap ? i_prev : i;
  // assign we_a_o   = sort_state && need_swap;

  // assign data_b_o = q_a_i;
  // assign addr_b_o = need_swap ? j_prev : j;
  // assign we_b_o   = sort_state && need_swap;

  
  // assign end_sorting_o = ~(start_sort_d || sort_state);