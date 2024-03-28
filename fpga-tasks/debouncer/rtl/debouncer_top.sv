module debouncer_top #(
  parameter  CLK_FREQ_MHZ   = 150,
  parameter  GLITCH_TIME_NS = 100000
)(
    input  logic clk_i_top, 

    input  logic key_i_top,

    output logic key_pressed_stb_o_top
);
  
  logic key;
  logic key_pressed_stb;

  debouncer #(
    .CLK_FREQ_MHZ   ( CLK_FREQ_MHZ   ),
    .GLITCH_TIME_NS ( GLITCH_TIME_NS )
  ) debouncer_ins(
    .clk_i             ( clk_i_top       ),

    .key_i             ( key             ),

    .key_pressed_stb_o ( key_pressed_stb )
  );

  always_ff @( posedge clk_i_top )
    key <= key_i_top;
  
  always_ff @( posedge clk_i_top )
    key_pressed_stb_o_top <= key_pressed_stb;

endmodule