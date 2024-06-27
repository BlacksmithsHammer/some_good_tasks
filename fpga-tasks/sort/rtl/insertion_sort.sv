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
  logic need_swap;
  logic [$clog2(MAX_PKT_LEN)-1:0] i;
  logic [$clog2(MAX_PKT_LEN)-1:0] j;

  // logic need_sort;
  // logic need_sort_d;
  
  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     need_sort <= 1'b0;
  //   else
  //     if( start_sorting_i )
  //       need_sort <= 1'b1;
  //     else
  //       if( i - 1 == last_addr )
  //         need_sort <= 1'b0;
  
  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     need_sort_d <= 1'b0;
  //   else
  //     need_sort_d <= need_sort;

  
  // // insertion-like sort
  // // for (int i = 0; i <= last_addr; i++)
  // //   for (int j = i; j <= last_addr; j++)
  // //     if (arr[i] > arr[j]) 
  // //       swap(arr[i], arr[j]);


  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     i <= '0;
  //   else
  //     if( start_sorting_i )
  //       i <= '0;

          

  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     j <= '0;
  //   else
  //     if( start_sorting_i )
  //       j <= '0;
  //     else
  //       if( need_sort_d && ~need_swap )
  //         j <= ( j == last_addr) ? i + 1 : j + 1;

          

  // assign need_swap =  ( q_a_i < q_b_i );
  // assign end_sorting_o = ~need_sort;

  // assign addr_a_o = i;
  // assign addr_b_o = ( need_sort_d ) ? ( ( need_swap ) ? j - 1 : j ) : j;

  // assign data_a_o = q_b_i;
  // assign data_b_o = q_a_i;

  // assign we_a_o = need_swap && need_sort_d;
  // assign we_b_o = need_swap && need_sort_d; 
 
  assign end_sorting_o = 1'b1;
  

endmodule



  // logic need_swap;
  // logic [$clog2(MAX_PKT_LEN)-1:0] i;
  // logic [$clog2(MAX_PKT_LEN)-1:0] j;

  // logic need_sort;
  // logic need_sort_d;
  
  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     need_sort <= 1'b0;
  //   else
  //     if( start_sorting_i )
  //       need_sort <= 1'b1;
  //     else
  //       if( i - 1 == last_addr )
  //         need_sort <= 1'b0;
  
  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     need_sort_d <= 1'b0;
  //   else
  //     need_sort_d <= need_sort;

  
  // // insertion-like sort
  // // for (int i = 0; i <= last_addr; i++)
  // //   for (int j = i; j <= last_addr; j++)
  // //     if (arr[i] > arr[j]) 
  // //       swap(arr[i], arr[j]);


  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     i <= '0;
  //   else
  //     if( start_sorting_i )
  //       i <= '0;

          

  // always_ff @( posedge clk_i )
  //   if( srst_i )
  //     j <= '0;
  //   else
  //     if( start_sorting_i )
  //       j <= '0;
  //     else
  //       if( need_sort_d && ~need_swap )
  //         j <= ( j == last_addr) ? i + 1 : j + 1;

          

  // assign need_swap =  ( q_a_i < q_b_i );
  // assign end_sorting_o = ~need_sort;

  // assign addr_a_o = i;
  // assign addr_b_o = ( need_sort_d ) ? ( ( need_swap ) ? j - 1 : j ) : j;

  // assign data_a_o = q_b_i;
  // assign data_b_o = q_a_i;

  // assign we_a_o = need_swap;
  // assign we_b_o = need_swap; 