`timescale 1ns / 1ns

module debouncer_tb #(
  parameter  CLK_FREQ_MHZ   = 100,
  parameter  GLITCH_TIME_NS = 150,

  localparam int GLITCH_TIME_CYCLES  = $ceil(real'(CLK_FREQ_MHZ*GLITCH_TIME_NS)/64'd1000),
  localparam int GLITCH_CYCLES_WIDTH = $clog2(GLITCH_TIME_CYCLES)
);

bit clk_i;

logic key;
logic key_pressed_stb;

int last_stb_pressed_time;
int last_key_pressed;


initial
  forever 
    #5 clk_i = !clk_i;

default clocking cb
  @( posedge clk_i );
endclocking

debouncer #(
  .CLK_FREQ_MHZ      ( CLK_FREQ_MHZ   ),
  .GLITCH_TIME_NS    ( GLITCH_TIME_NS )
) DUT (
  .clk_i             ( clk_i          ),

  .key_i             ( key            ),

  .key_pressed_stb_o ( key_pressed_stb )
);

always_ff @( negedge key )
  begin
    $display("KEY PRESSED AT: ", $time);
    last_key_pressed = $time;
  end
  

always_ff @( negedge key_pressed_stb )
  begin
    $display("GOT STB AT: ", $time);
    last_stb_pressed_time = $time;
    $display("diff: ", last_stb_pressed_time - last_key_pressed);
  end

initial 
  begin
    key = 1'b0;
    ##20;
    key = 1'b1;
    ##7;
    key = 1'b0;
    ##100;
    key = 1'b1;
    ##1;
    key = 1'b0;
    ##100;
    key = 1'b1;
    ##5;
    key = 1'b0;
    ##5;
    key = 1'b1;
    ##100;
    key = 1'b0;
    ##30;
    key = 1'b1;
    ##100;
    for (int i = 0; i < 30; i = i + 1)
      begin
        key = 1;
        ##1
        key = 0;
        ##(i);
      end

    for (int i = 0; i < 500; i = i + 1)
     begin
       key = $urandom_range(1, 0);
       ##($urandom_range(100, 1));
     end

    

    $stop();
  end
    
endmodule