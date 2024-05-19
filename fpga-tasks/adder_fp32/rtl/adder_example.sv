module adder_example (
    input  clk,
    input  srst,

    output ready_o,

    output valid_stb_o,
    input  valid_stb_i,

    input  [31:0] a_i,
    input  [31:0] b_i,

    output [31:0] z_o,
    input         ack_z_i

);
  ////////////////////////////////////////////////////////
  //custom addition for easier use
  //now we can send valid data once (in 1 clock)
  //obviously not best solution, but this move only for make better interface

  logic [31:0]  b;
  logic [1:0]   b_d;

  always_ff @( posedge clk ) 
    if( srst )
      b_d <= '0;
    else
      b_d <= {b_d[0], valid_stb_i};
        

  always_ff @( posedge clk )
    if( valid_stb_i )
      b <= b_i;

  ////////////////////////////////////////////////////////

 
  //https://github.com/dawsonjon/fpu/tree/master/adder
  adder adder_ins (
    .clk          ( clk  ),
    .rst          ( srst ),

    .input_a      ( a_i         ),
    .input_a_stb  ( valid_stb_i ),
    .input_a_ack  ( ready_o     ),

    .input_b      ( b      ),
    .input_b_stb  ( b_d[1] ),

  //ignored because number of cycles to get b value fixed
    .input_b_ack  (),

    .output_z     ( z_o         ),
    .output_z_stb ( valid_stb_o ),
    .output_z_ack ( ack_z_i     )
  );
    
endmodule

