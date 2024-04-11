module traffic_lights #(
//===================================================================
// parameters
//===================================================================

// 1s = 1000ms = 2000 hz/s
// BLINK_HALF_PERIOD_MS > 0
  parameter BLINK_HALF_PERIOD_MS  = 3,
// BLINK_GREEN_TIME_TICK > 0
  parameter BLINK_GREEN_TIME_TICK = 4,
// RED_YELLOW_MS >= 0
  parameter RED_YELLOW_MS         = 7

//===================================================================
// end parameters
//===================================================================
)(
//===================================================================
// ports
// clk_i = 2000hz
//===================================================================
  input          clk_i,
  input          srst_i,

  input  [2:0]   cmd_type_i,
  input          cmd_valid_i,
  input  [15:0]  cmd_data_i,

  output logic   red_o,
  output logic   yellow_o,
  output logic   green_o
);
//===================================================================
// end ports
//===================================================================

//===================================================================
// variables
//===================================================================
// hz/1ms
// may be need write a function to convert ms into clk_i cycles
  localparam hz_ms = 2000 / 1000;
// time of red-yellow light in cycles
  localparam cycles_red_yellow = RED_YELLOW_MS*hz_ms;
// time of red, green and yellow light in cycles
// (may be all this would look better in an array)
  logic [15:0]  cycles_red    = 16'd10;
  logic [15:0]  cycles_yellow = 16'd10;
  logic [15:0]  cycles_green  = 16'd10;
// counter for time of red, green, yellow and red-yellow light
  logic [15:0]  cnt_rgb_light = '0;
// counter for green-blink ticks light
  logic [$clog2(hz_ms*BLINK_GREEN_TIME_TICK):0]   cnt_green_periods_blinks;
// counter for one half-period blink, example: 
//   period      = 4s
//   half_period = 2s = cnt_blink, in 1 period 2 blinks (off and on)
  logic [$clog2(hz_ms*BLINK_HALF_PERIOD_MS):0]  cnt_blink;

  enum logic [2:0] {
    RED,
    RED_YELLOW,
    GREEN,
    GREEN_BLINK,
    YELLOW,
    YELLOW_MANUAL,
    LIGHTS_OFF
  } state, next_state;
//===================================================================
// end variables
//===================================================================

//===================================================================
// flip-flop blocks
//===================================================================

  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_rgb_light <= '0;
    else
      if( state == next_state )
        cnt_rgb_light <= cnt_rgb_light + 1'b1;
      else
        cnt_rgb_light <= '0;

  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_green_periods_blinks <= '0;
    else
      if( state == GREEN_BLINK && cnt_blink == hz_ms*BLINK_HALF_PERIOD_MS - 1 )
        cnt_green_periods_blinks <= cnt_green_periods_blinks + 1'b1;
      else
        if ( state != GREEN_BLINK )
          cnt_green_periods_blinks <= '0;
    
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_blink <= '0;
    else
      if ( state == GREEN_BLINK && cnt_blink < (hz_ms*BLINK_HALF_PERIOD_MS - 1) )
        cnt_blink <= cnt_blink + 1'b1;
      else
        cnt_blink <= '0;

// changes dynamic time of green light
  always_ff @( posedge clk_i )
    if( srst_i )
      cycles_green <= 16'd10;
    else
      if( state == YELLOW_MANUAL && cmd_valid_i == 1'b1 && cmd_type_i == 3 )
        cycles_green <= cmd_data_i;

// changes dynamic time of red light
  always_ff @( posedge clk_i )
    if( srst_i )
      cycles_red <= 16'd10;
    else
      if( state == YELLOW_MANUAL && cmd_valid_i == 1'b1 && cmd_type_i == 4 )
        cycles_red <= cmd_data_i;

// changes dynamic time of yellow light
  always_ff @( posedge clk_i )
    if( srst_i )
      cycles_yellow <= 16'd10;
    else
      if( state == YELLOW_MANUAL && cmd_valid_i == 1'b1 && cmd_type_i == 5 )
        cycles_yellow <= cmd_data_i;

// FSM stage-changer
  always_ff @( posedge clk_i ) 
    if( srst_i )
      begin
        state <= RED;
      end
    else
      state <= next_state;

//===================================================================
// end flip-flop blocks    
//===================================================================

//===================================================================
// FSM states
//===================================================================
  always_comb 
    begin
      next_state = state;
      case( state )
        RED:
          begin
            if( cnt_rgb_light < cycles_red - 1 )
              next_state = RED;
            else
              next_state = ( RED_YELLOW_MS == 0 ) ? GREEN : RED_YELLOW;
          end

        RED_YELLOW:
          begin
            if( cnt_rgb_light < cycles_red_yellow - 1 )
              next_state = RED_YELLOW;
            else
              next_state = GREEN;
          end

        GREEN:
          begin
            if( cnt_rgb_light < cycles_green - 1 )
              next_state = GREEN;
            else
              next_state = GREEN_BLINK;
          end

        GREEN_BLINK:
          begin
            if( 
                cnt_green_periods_blinks < hz_ms*BLINK_GREEN_TIME_TICK &&
              // fix the problem with 1 cycle without lights
                ~( 
                  cnt_green_periods_blinks == hz_ms*BLINK_GREEN_TIME_TICK - 1 &&
                  cnt_blink == hz_ms*BLINK_HALF_PERIOD_MS - 1 
                )
              // end fix
              )
              next_state = GREEN_BLINK;
            else
              next_state = YELLOW;
          end

        YELLOW:
          begin
            if( cnt_rgb_light < cycles_yellow - 1 )
              next_state = YELLOW;
            else
              next_state = RED;
          end

        YELLOW_MANUAL:
          begin
            if( cmd_valid_i == 1'b1 && cmd_type_i == 0 )
              next_state = RED;
            else
              next_state = YELLOW_MANUAL;
          end

        LIGHTS_OFF:
          begin
            if( cmd_valid_i == 1'b1 && cmd_type_i == 0 )
              next_state = RED;
            else
              next_state = LIGHTS_OFF;
          end
      endcase

      if( cmd_valid_i == 1'b1 && cmd_type_i == 1 )
        next_state = LIGHTS_OFF;

      if( cmd_valid_i == 1'b1 && cmd_type_i == 2 )
        next_state = YELLOW_MANUAL;  

    end
//===================================================================
// end FSM states
//===================================================================

//===================================================================
// assign output ports
//===================================================================
  always_comb
    begin
      red_o = ( 
        state == RED ||
        state == RED_YELLOW
      );

      yellow_o = ( 
          state == YELLOW     ||
          state == RED_YELLOW ||
        ( state == YELLOW_MANUAL )
      );
        
      green_o  = ( 
          state == GREEN  ||
        ( state == GREEN_BLINK && cnt_green_periods_blinks[0] == 1'b1 )
      );
    end
//===================================================================
// end assign output ports
//===================================================================
endmodule