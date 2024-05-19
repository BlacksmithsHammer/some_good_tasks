module adder_example (
    input  clk,
    input  srst,

    input  valid_stb_i,
    output ready_o,

    input  [31:0] a_i,
    input  [31:0] b_i,

    output [31:0] z_o
);

  //https://github.com/dawsonjon/fpu/tree/master/adder
  adder adder_ins (
    .clk          ( clk  ),
    .rst          ( srst ),

    .input_a      ( a_i         ),
    .input_a_stb  ( valid_stb_i ),
    .input_a_ack  ( ready_o     ),

    .input_b      ( b_i ),
    .input_b_stb  ( valid_stb_i ),
    .input_b_ack  (),

    .output_z     ( z_o ),
    .output_z_stb (),
    .output_z_ack ()
  );
    
endmodule