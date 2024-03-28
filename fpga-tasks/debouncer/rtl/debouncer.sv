module debouncer #(
  //1 mhz == 1 000 000 Hz
  parameter CLK_FREQ_MHZ   = 150,
  //1 ns  == 0,000 000 001 s
  parameter GLITCH_TIME_NS = 100
)(
  input  logic clk_i,

  input  logic key_i,

  output logic key_pressed_stb_o
);
  //======================================================================================
  // CLK_FREQ_MHZ*1000000 - clock Hz per second
  // CLK_FREQ_MHZ*1000000/1000000000 - cycles per 1ns, then *GLITCH_TIME_NS to get
  // number of cycles clk_i for time in GLITCH_TIME_NS ns. (cycles per 1 GLITCH)
  //
  //
  // cycles of continuous waiting: CLK_FREQ_MHZ * 64'd1000000 * GLITCH_TIME_NS / 64'd1000000000
  //                                          |||
  //                                           V
  // cycles of continuous waiting: CLK_FREQ_MHZ * GLITCH_TIME_NS / 64'd1000
  //======================================================================================
  // since negedge key_i moment to negedge strobe await GLITCH_TIME_NS + 4 clocks
  ////////////////////////////////////////////////////////////////////////////////////////

  //parameter int GLITCH_TIME_CYCLES  = $ceil(real'(CLK_FREQ_MHZ*GLITCH_TIME_NS)/1000) 
  localparam int GLITCH_TIME_CYCLES  = (CLK_FREQ_MHZ*GLITCH_TIME_NS + 1000 - 1)/1000;
  localparam int GLITCH_CYCLES_WIDTH = $clog2(GLITCH_TIME_CYCLES);

  logic [2:0]                   key_press_d;

  logic [GLITCH_CYCLES_WIDTH:0] counter;
  
  always_ff @( posedge clk_i )
    key_press_d <= {key_press_d[1:0], key_i};

  always_ff @( posedge clk_i )
    if( key_press_d[2] == 1'b1 )
      counter <= '0;
    else
      if( key_press_d[2] == 1'b0 && counter <= GLITCH_TIME_CYCLES )
        counter <= counter + 1'b1;
  
  always_comb 
    begin
      if( counter == GLITCH_TIME_CYCLES )
        key_pressed_stb_o = 1'b1;
      else
        key_pressed_stb_o = 1'b0;
    end
  
endmodule
