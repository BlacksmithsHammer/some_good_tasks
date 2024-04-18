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
// parameters
//===================================================================
// hz/1ms
// may be need write a function to convert ms into clk_i cycles
  localparam HZ_MS = 2000 / 1000;
// time of red-yellow light in cycles
  localparam CYCLES_RED_YELLOW       = RED_YELLOW_MS*HZ_MS;
// default times of RED, GREEN and YELLOW in cycles (clk)
  localparam DEFAULT_RGY_SETTINGS = 10;
// cmd_data_i types
  localparam CMD_ON          = 3'd0;
  localparam CMD_OFF         = 3'd1;
  localparam CMD_MANUAL_MODE = 3'd2;
  localparam CMD_SET_GREEN   = 3'd3;
  localparam CMD_SET_RED     = 3'd4;
  localparam CMD_SET_YELLOW  = 3'd5;
//===================================================================
// end parameters
//===================================================================

//===================================================================
// variables
//===================================================================
// time of red, green and yellow light in cycles
// (may be all this would look better in an array)
  logic [15:0]  cycles_red;
  logic [15:0]  cycles_yellow;
  logic [15:0]  cycles_green;

// may be need place logic of lights in small module, 
// but we have not only long-time lights: infinite blinks, long-time blinks
  logic [15:0]  cnt_cycles_red;
  logic [15:0]  cnt_cycles_yellow;
  logic [15:0]  cnt_cycles_red_yellow; 
  logic [15:0]  cnt_cycles_green;

// counter for green-blink ticks light
  logic [$clog2(HZ_MS*BLINK_GREEN_TIME_TICK):0] cnt_green_periods_blinks;

// wire for long logic of green blinks
  logic green_blinks_fix;

// counter for one half-period blink, example: 
//   period      = 4s
//   half_period = 2s = cnt_blink, in 1 period 2 blinks (off and on)
logic [$clog2(HZ_MS*BLINK_HALF_PERIOD_MS):0]  cnt_blink;
// light or no at half-period in yellow manual mode
  logic yellow_manual_blink;

  enum logic [2:0] {
    RED_S,
    RED_YELLOW_S,
    GREEN_S,
    GREEN_BLINK_S,
    YELLOW_S,
    YELLOW_MANUAL_S,
    LIGHTS_OFF_S
  } state, next_state;
//===================================================================
// end variables
//===================================================================

//===================================================================
// flip-flop blocks
//===================================================================

// counter for RED light in cycles
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_cycles_red <= '0;
    else
      if( state == RED_S )
        cnt_cycles_red <= cnt_cycles_red + 1'b1;
      else
        cnt_cycles_red <= '0;

// counter for YELLOW light in cycles
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_cycles_yellow <= '0;
    else
      if( state == YELLOW_S )
        cnt_cycles_yellow <= cnt_cycles_yellow + 1'b1;
      else
        cnt_cycles_yellow <= '0;

// counter for GREEN light in cycles
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_cycles_green <= '0;
    else
      if( state == GREEN_S )
        cnt_cycles_green <= cnt_cycles_green + 1'b1;
      else
        cnt_cycles_green <= '0;

// counter for RED_YELLOW light in cycles
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_cycles_red_yellow <= '0;
    else
      if( state == RED_YELLOW_S )
        cnt_cycles_red_yellow <= cnt_cycles_red_yellow + 1'b1;
      else
        cnt_cycles_red_yellow <= '0;

// counter of blinks (half-period) fo
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_green_periods_blinks <= '0;
    else
      if( state == GREEN_BLINK_S && cnt_blink == HZ_MS*BLINK_HALF_PERIOD_MS - 1 )
        cnt_green_periods_blinks <= cnt_green_periods_blinks + 1'b1;
      else
        if ( state != GREEN_BLINK_S )
          cnt_green_periods_blinks <= '0;
// counter for time of ONE blink (half-period)
  always_ff @( posedge clk_i )
    if( srst_i )
      cnt_blink <= '0;
    else
      if( cmd_valid_i == 1'b1 && cmd_type_i == CMD_MANUAL_MODE)
        cnt_blink <= '0;
      else
        if( 
          ( state == GREEN_BLINK_S || state == YELLOW_MANUAL_S ) && 
            cnt_blink < (HZ_MS*BLINK_HALF_PERIOD_MS - 1)
          )
          cnt_blink <= cnt_blink + 1'b1;
        else
          cnt_blink <= '0;

  always_ff @( posedge clk_i )
    if( srst_i )
      cycles_green <= DEFAULT_RGY_SETTINGS[15:0];
    else
      if( state == YELLOW_MANUAL_S && cmd_valid_i == 1'b1 && cmd_type_i == CMD_SET_GREEN )
        cycles_green <= cmd_data_i;

  always_ff @( posedge clk_i )
    if( srst_i )
      cycles_red <= DEFAULT_RGY_SETTINGS[15:0];
    else
      if( state == YELLOW_MANUAL_S && cmd_valid_i == 1'b1 && cmd_type_i == CMD_SET_RED )
        cycles_red <= cmd_data_i;

  always_ff @( posedge clk_i )
    if( srst_i )
      cycles_yellow <= DEFAULT_RGY_SETTINGS[15:0];
    else
      if( state == YELLOW_MANUAL_S && cmd_valid_i == 1'b1 && cmd_type_i == CMD_SET_YELLOW )
        cycles_yellow <= cmd_data_i;

// logic for YELLOW_MANUAL blinks
  always_ff @( posedge clk_i )
    if( srst_i )
      yellow_manual_blink <= 1'b0;
    else
      if( state != YELLOW_MANUAL_S )
        yellow_manual_blink <= 1'b0;
      else
        if( cnt_blink == ( HZ_MS*BLINK_HALF_PERIOD_MS - 1 ) )
          yellow_manual_blink <= ~yellow_manual_blink;

// FSM state-changer
  always_ff @( posedge clk_i ) 
    if( srst_i )
      state <= RED_S;
    else
      state <= next_state;

//===================================================================
// end flip-flop blocks    
//===================================================================

//===================================================================
// combinational logic
//===================================================================
// fix to fill 1 time (1 cycle) when light after green blinks of next state delay
  assign green_blinks_fix = ~(
    (  cnt_green_periods_blinks == HZ_MS*BLINK_GREEN_TIME_TICK - 1 ) &&
    (  cnt_blink == HZ_MS*BLINK_HALF_PERIOD_MS - 1 )
  );
//===================================================================
// end combinational logic
//===================================================================

//===================================================================
// FSM states
//===================================================================
  always_comb 
    begin

      next_state = state;
      case( next_state )
        RED_S:
          begin
            if( cnt_cycles_red != cycles_red - 1 )
              next_state = RED_S;
            else
              next_state = ( RED_YELLOW_MS == 0 ) ? GREEN_S : RED_YELLOW_S;
          end

        RED_YELLOW_S:
          begin
            if( cnt_cycles_red_yellow != CYCLES_RED_YELLOW - 1 )
              next_state = RED_YELLOW_S;
            else
              next_state = GREEN_S;
          end

        GREEN_S:
          begin
            if( cnt_cycles_green != cycles_green - 1 )
              next_state = GREEN_S;
            else
              next_state = GREEN_BLINK_S;
          end

        GREEN_BLINK_S:
          begin
            if( 
                (  cnt_green_periods_blinks != HZ_MS*BLINK_GREEN_TIME_TICK - 1 ) ||
                (  cnt_blink != HZ_MS*BLINK_HALF_PERIOD_MS - 1 )
              )
              next_state = GREEN_BLINK_S;
            else
              next_state = YELLOW_S;
          end

        YELLOW_S:
          begin
            if( cnt_cycles_yellow != cycles_yellow - 1 )
              next_state = YELLOW_S;
            else
              next_state = RED_S;
          end

        YELLOW_MANUAL_S:
          begin
            if( cmd_valid_i == 1'b1 && cmd_type_i == CMD_ON )
              next_state = RED_S;
            else
              next_state = YELLOW_MANUAL_S;
          end

        LIGHTS_OFF_S:
          begin
            if( cmd_valid_i == 1'b1 && cmd_type_i == CMD_ON )
              next_state = RED_S;
            else
              next_state = LIGHTS_OFF_S;
          end

        default:
          begin
            next_state = LIGHTS_OFF_S;
          end
      endcase

      if( cmd_valid_i == 1'b1 && cmd_type_i == CMD_OFF )
        next_state = LIGHTS_OFF_S;

      if( cmd_valid_i == 1'b1 && cmd_type_i == CMD_MANUAL_MODE )
        next_state = YELLOW_MANUAL_S;
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
          state == RED_S ||
          state == RED_YELLOW_S
      );

      yellow_o = ( 
          state == YELLOW_S     ||
          state == RED_YELLOW_S ||
        ( state == YELLOW_MANUAL_S && yellow_manual_blink)
      );
        
      green_o  = ( 
          state == GREEN_S  ||
        ( state == GREEN_BLINK_S && cnt_green_periods_blinks[0] == 1'b1 )
      );
    end
//===================================================================
// end assign output ports
//===================================================================
endmodule
