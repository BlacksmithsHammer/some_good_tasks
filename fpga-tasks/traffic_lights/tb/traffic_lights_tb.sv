//`timescale 10us/10us

module traffic_lights_tb #(
  parameter BLINK_HALF_PERIOD_MS  = 3,
  parameter BLINK_GREEN_TIME_TICK = 4,
  parameter RED_YELLOW_MS         = 7
);

  bit clk;
  bit srst;

  initial
    forever
      //#(25) clk = !clk; if timescale 10us/10us
      //4000ps - 2000 hz
      #1 clk = !clk;

  default clocking cb
    @( posedge clk );
  endclocking

  task throw_err(string msg);
    $display(msg, $time);
    $stop();
  endtask

 
  logic  [2:0]   cmd_type;
  logic          cmd_valid;
  logic  [15:0]  cmd_data;

  logic         red;
  logic         yellow;
  logic         green;

  traffic_lights #(
    .BLINK_HALF_PERIOD_MS  ( BLINK_HALF_PERIOD_MS  ),
    .BLINK_GREEN_TIME_TICK ( BLINK_GREEN_TIME_TICK ),
    .RED_YELLOW_MS         ( RED_YELLOW_MS         )
  ) DUT (
    .clk_i  ( clk  ),
    .srst_i ( srst ),

    .cmd_type_i  ( cmd_type  ),
    .cmd_valid_i ( cmd_valid ),
    .cmd_data_i  ( cmd_data  ),

    .red_o       ( red    ),
    .yellow_o    ( yellow ),
    .green_o     ( green  )
  );

  localparam CMD_ON          = 3'd0;
  localparam CMD_OFF         = 3'd1;
  localparam CMD_MANUAL_MODE = 3'd2;
  localparam CMD_SET_GREEN   = 3'd3;
  localparam CMD_SET_RED     = 3'd4;
  localparam CMD_SET_YELLOW  = 3'd5;

  enum logic [2:0] {
    RED_S,
    RED_YELLOW_S,
    GREEN_S,
    GREEN_BLINK_S,
    YELLOW_S,
    YELLOW_MANUAL_S,
    LIGHTS_OFF_S
  } state;
  

  task change_state( logic        valid,
                     logic [2:0]  state,
                     logic [15:0] data);
    cmd_valid = valid; 
    cmd_type  = state;
    cmd_data  = data;
    ##1;
    cmd_valid = 1'b0;
  endtask

  time last_green_pos = 0;
  time last_green_neg = 0;

  time last_yellow_pos = 0;
  time last_yellow_neg = 0;

  int time_of_check;

  task check_full_state(  int          time_cycles,
                          logic [2:0]  curr_state,
                          logic [15:0] green_cycles,
                          logic [15:0] yellow_cycles,
                          logic [15:0] red_cycles,
                          int          blinks = 0);
    time_of_check = time_cycles;

    while (time_cycles > 0) 
      begin

        if( green  == 1'b1  ) last_green_pos  = $time;
        if( green  == 1'b0  ) last_green_neg  = $time;

        if( yellow  == 1'b1 ) last_yellow_pos = $time;
        if( yellow  == 1'b0 ) last_yellow_neg = $time;

        // static red color
        if( curr_state == RED_S )
          begin
            if( green || yellow || ~red)
              throw_err("wrong colors in time: ");
          end
        // static red and yellow colors
        if( curr_state == RED_YELLOW_S )
          begin
            if( green || ~red || ~yellow)
              throw_err("wrong colors in time: ");
          end
        // static green color
        if( curr_state == GREEN_S )
          begin
            if( red || yellow || ~green)
              throw_err("wrong colors in time: ");
          end
    
        if( curr_state == GREEN_BLINK_S )
          begin
            if( red || yellow )
              throw_err("wrong colors in time: ");

            if( (last_green_neg - last_green_pos == BLINK_HALF_PERIOD_MS*4) ||
                (last_green_pos - last_green_neg == BLINK_HALF_PERIOD_MS*4) )
                begin
                  blinks++;
                end
          end

        // static yellow color
        if( curr_state == YELLOW_S )
          begin
            if( red || green || ~yellow)
              throw_err("wrong colors in time: ");
          end

        // blinking yellow color
        if( curr_state == YELLOW_MANUAL_S )
          begin
            if( red || green)
              throw_err("wrong lights in time: ");

            if( (last_yellow_neg - last_yellow_pos == BLINK_HALF_PERIOD_MS*4) ||
                (last_yellow_pos - last_yellow_neg == BLINK_HALF_PERIOD_MS*4) )
              begin
                blinks++;
              end
          end

        // static OFF
        if( curr_state == LIGHTS_OFF_S )
          begin
            if( red || green || yellow )
              throw_err("lights in OFF mode in time ");
          end
        ##1;
        time_cycles = time_cycles - 1;
      end
      
      //fix, because time of last states 0 and 1 of green color global
      if( green_cycles == BLINK_HALF_PERIOD_MS*2)
        blinks = blinks - 1;

      if( curr_state == GREEN_BLINK_S && blinks != time_of_check / ( BLINK_HALF_PERIOD_MS * 2 ) )
        throw_err("Wrong number of blinks or expected other state (check time of previos state also in time) ");
      
      if( curr_state == YELLOW_MANUAL_S && blinks != time_of_check / ( BLINK_HALF_PERIOD_MS * 2 ) - 1 &&
          curr_state == YELLOW_MANUAL_S && blinks != time_of_check / ( BLINK_HALF_PERIOD_MS * 2 ) )
        begin
          $display(blinks, " ", time_of_check / ( BLINK_HALF_PERIOD_MS * 2 ) - 1);
          throw_err("Wrong number of blinks or expected other state (check time of previos state also in time) ");
        end

  endtask

  task check_state_ON(int          cycles,
                      logic [2:0]  curr_state,
                      logic [15:0] green_cycles,
                      logic [15:0] yellow_cycles,
                      logic [15:0] red_cycles);
    while(cycles > 0)
      begin
        cycles = cycles - red_cycles;
        if( cycles < 0 )
          begin
            check_full_state(red_cycles + cycles, RED_S, green_cycles, yellow_cycles, red_cycles);
            break;
          end
        else
          check_full_state(red_cycles, RED_S, green_cycles, yellow_cycles, red_cycles);

        cycles = cycles - RED_YELLOW_MS*2;
        if( cycles < 0 )
          begin
            check_full_state(RED_YELLOW_MS*2 + cycles, RED_YELLOW_S, green_cycles, yellow_cycles, red_cycles);
            break;
          end
        else
          check_full_state(RED_YELLOW_MS*2, RED_YELLOW_S, green_cycles, yellow_cycles, red_cycles);

        cycles = cycles - green_cycles;
        if( cycles < 0 )
          begin
            check_full_state(green_cycles + cycles, GREEN_S, green_cycles, yellow_cycles, red_cycles);
            break;
          end
        else
          check_full_state(green_cycles, GREEN_S, green_cycles, yellow_cycles, red_cycles);

        cycles = cycles - BLINK_HALF_PERIOD_MS*BLINK_GREEN_TIME_TICK*4;
        if( cycles < 0 )
          begin
            check_full_state(BLINK_HALF_PERIOD_MS*BLINK_GREEN_TIME_TICK*4 + cycles, GREEN_BLINK_S, green_cycles, yellow_cycles, red_cycles);
            break;
          end
        else
          check_full_state(BLINK_HALF_PERIOD_MS*BLINK_GREEN_TIME_TICK*4, GREEN_BLINK_S, green_cycles, yellow_cycles, red_cycles);

        cycles = cycles - yellow_cycles;
        if( cycles < 0 )
          begin
            check_full_state(yellow_cycles + cycles, YELLOW_S, green_cycles, yellow_cycles, red_cycles);
            break;
          end
        else
          check_full_state(yellow_cycles, YELLOW_S, green_cycles, yellow_cycles, red_cycles);
      end
  endtask

    

  initial
    begin
      // sync reset
      srst = 1'b1;
      ##1;
      srst = 1'b0;
      //check default timings of light
      fork
        check_state_ON(1000, RED_S, 10, 10, 10);
        // spam data in wrong time
        for(int i = 0; i < 100; i++)
        begin
          change_state(1, CMD_SET_GREEN, $urandom_range(100, 1));
          change_state(1, CMD_SET_YELLOW, $urandom_range(100, 1));
          change_state(1, CMD_SET_RED, $urandom_range(100, 1));
        end
      join
      change_state(1, CMD_MANUAL_MODE, 1);
      change_state(1, CMD_SET_GREEN, 20);
      change_state(1, CMD_SET_YELLOW, 30);
      change_state(1, CMD_SET_RED, 40);
      change_state(1, CMD_ON, 1);
      //check changed timings of lights
      fork
        // spam data in wrong time
        check_state_ON(100000, RED_S, 20, 30, 40);
        for(int i = 0; i < 10000; i++)
        begin
          change_state(1, CMD_SET_GREEN, $urandom_range(100, 1));
          change_state(1, CMD_SET_YELLOW, $urandom_range(100, 1));
          change_state(1, CMD_SET_RED, $urandom_range(100, 1));
        end
      join

      //check lights in manual mode
      change_state(1, CMD_MANUAL_MODE, 1);
      fork
        check_full_state(100000, YELLOW_MANUAL_S, 20, 30, 40);
      join

      //check lights in OFF mode
      change_state(1, CMD_OFF, 1);
      fork
        check_full_state(100000, LIGHTS_OFF_S, 20, 30, 40);
      join

      //on and check lights again
      change_state(1, CMD_ON, 1);
      fork
        // spam data in wrong time
        check_state_ON(100000, RED_S, 20, 30, 40);
        for(int i = 0; i < 10000; i++)
        begin
          change_state(1, CMD_SET_GREEN, $urandom_range(100, 1));
          change_state(1, CMD_SET_YELLOW, $urandom_range(100, 1));
          change_state(1, CMD_SET_RED, $urandom_range(100, 1));
        end
      join

      ##5;

      $display("ALL TESTS PASSED SUCCESSFULLY");
      $stop();
    end

endmodule
