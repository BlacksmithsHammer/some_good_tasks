`timescale 1ns / 1ns

module debouncer_tb #(
  parameter  CLK_FREQ_MHZ   = 100,
  parameter  GLITCH_TIME_NS = 150,

  localparam int GLITCH_TIME_CYCLES  = $ceil(real'(CLK_FREQ_MHZ*GLITCH_TIME_NS)/64'd1000),
  localparam int GLITCH_CYCLES_WIDTH = $clog2(GLITCH_TIME_CYCLES),
  localparam int TIME_OF_CYCLE       = 1000000000/(CLK_FREQ_MHZ*1000000)
);

bit clk_i;

logic key;
logic key_pressed_stb;

// int last_stb_pressed_time;
// int last_key_pressed;


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

time expected_prev_prev_stb;
time expected_prev_stb;
time expected_curr_stb;
int  num_cycles;
initial 
  begin
    key = 1'b1;
    for(int test_num = 0; test_num < 1000; test_num = test_num + 1)
      begin
        //if GLITCH more than 10000ns - should use an other way to set range
        num_cycles = $urandom_range(GLITCH_TIME_NS, 1);
        // + 3 because DFF-delay of resync key_i
        if( num_cycles >= GLITCH_TIME_CYCLES )
          expected_curr_stb = $time + TIME_OF_CYCLE*(GLITCH_TIME_CYCLES + 3);
        else
          expected_curr_stb = '0;

        for(int test_cycle = 0; test_cycle < num_cycles; test_cycle = test_cycle + 1)
          begin
            key = 1'b0;
            if( key_pressed_stb == 1'b1 && $time != expected_curr_stb && $time != expected_prev_stb && $time != expected_prev_prev_stb )
              begin
                $display("WRONG STB AT ", $time);
                $display("expected stb's at: ", expected_curr_stb, "or", expected_prev_stb, " or ", expected_prev_prev_stb);
                ##3;
                $stop();
              end
            if( key_pressed_stb == 1'b0 )
              if( $time == expected_curr_stb == 1'b1 || $time == expected_prev_stb || $time == expected_prev_prev_stb )
                begin
                  $display("EXPECTED STB BUT NO AT ", $time);
                  $stop();
                end
            ##1;
          end
        key = 1'b1;
        expected_prev_prev_stb = expected_prev_stb;
        expected_prev_stb      = expected_curr_stb;
        //can randomize pause to deep testing
        ##1;
      end


    key = 1'b1;
    for(int test_num = 0; test_num < 1000; test_num = test_num + 1)
      begin

        //if GLITCH more than 10000ns - should use an other way to set range
        num_cycles = $urandom_range(GLITCH_TIME_NS, 1);
        // + 3 because DFF-delay of resync key_i
        if( num_cycles >= GLITCH_TIME_CYCLES )
          expected_curr_stb = $time + TIME_OF_CYCLE*(GLITCH_TIME_CYCLES + 3);
        else
          expected_curr_stb = '0;

        for(int test_cycle = 0; test_cycle < num_cycles; test_cycle = test_cycle + 1)
          begin
            key = 1'b0;
            if( key_pressed_stb == 1'b1 && $time != expected_curr_stb && $time != expected_prev_stb && $time != expected_prev_prev_stb )
              begin
                $display("WRONG STB AT ", $time);
                $display("expected stb's at: ", expected_curr_stb, "or", expected_prev_stb, " or ", expected_prev_prev_stb);
                ##3;
                $stop();
              end
            if( key_pressed_stb == 1'b0 )
              if( $time == expected_curr_stb == 1'b1 || $time == expected_prev_stb || $time == expected_prev_prev_stb )
                begin
                  $display("EXPECTED STB BUT NO AT ", $time);
                  $stop();
                end
            ##1;
          end
        key = 1'b1;
        expected_prev_prev_stb = expected_prev_stb;
        expected_prev_stb      = expected_curr_stb;
        //can randomize pause to deep testing
        for(int unpush = 0; unpush < $urandom_range(GLITCH_TIME_NS*3, 1); unpush = unpush + 1)
          begin
            if( key_pressed_stb == 1'b1 && $time != expected_curr_stb && $time != expected_prev_stb && $time != expected_prev_prev_stb )
              begin
                $display("WRONG STB AT ", $time);
                $display("expected stb's at: ", expected_curr_stb, "or", expected_prev_stb, " or ", expected_prev_prev_stb);
                ##3;
                $stop();
              end
            if( key_pressed_stb == 1'b0 )
              if( $time == expected_curr_stb == 1'b1 || $time == expected_prev_stb || $time == expected_prev_prev_stb )
                begin
                  $display("EXPECTED STB BUT NO AT ", $time);
                  $stop();
                end
            ##1;
          end
      end

    key = 1'b1;
    for(int test_num = 0; test_num < 1000; test_num = test_num + 1)
      begin
        num_cycles = $urandom_range(GLITCH_TIME_CYCLES, 1);
        // + 3 because DFF-delay of resync key_i
        if( num_cycles >= GLITCH_TIME_CYCLES )
          expected_curr_stb = $time + TIME_OF_CYCLE*(GLITCH_TIME_CYCLES + 3);
        else
          expected_curr_stb = '0;

        for(int test_cycle = 0; test_cycle < num_cycles; test_cycle = test_cycle + 1)
          begin
            key = 1'b0;
            if( key_pressed_stb == 1'b1 && $time != expected_curr_stb && $time != expected_prev_stb && $time != expected_prev_prev_stb )
              begin
                $display("WRONG STB AT ", $time);
                $display("expected stb's at: ", expected_curr_stb, "or", expected_prev_stb, " or ", expected_prev_prev_stb);
                ##3;
                $stop();
              end
            if( key_pressed_stb == 1'b0 )
              if( $time == expected_curr_stb == 1'b1 || $time == expected_prev_stb || $time == expected_prev_prev_stb )
                begin
                  $display("EXPECTED STB BUT NO AT ", $time);
                  $stop();
                end
            ##1;
          end
        key = 1'b1;
        expected_prev_prev_stb = expected_prev_stb;
        expected_prev_stb      = expected_curr_stb;
        //can randomize pause to deep testing
        for(int unpush = 0; unpush < $urandom_range(GLITCH_TIME_CYCLES, 1); unpush = unpush + 1)
          begin
            if( key_pressed_stb == 1'b1 && $time != expected_curr_stb && $time != expected_prev_stb && $time != expected_prev_prev_stb )
              begin
                $display("WRONG STB AT ", $time);
                $display("expected stb's at: ", expected_curr_stb, "or", expected_prev_stb, " or ", expected_prev_prev_stb);
                ##3;
                $stop();
              end
            if( key_pressed_stb == 1'b0 )
              if( $time == expected_curr_stb == 1'b1 || $time == expected_prev_stb || $time == expected_prev_prev_stb )
                begin
                  $display("EXPECTED STB BUT NO AT ", $time);
                  $stop();
                end
            ##1;
          end
      end


    $display("============================\nTESTS PASSED SUCCESSFULLY\n============================\n");
    $stop();
  end
    
endmodule