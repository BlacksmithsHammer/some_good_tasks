module traffic_lights_top #(
  parameter BLINK_HALF_PERIOD_MS  = 1000,
  parameter BLINK_GREEN_TIME_TICK = 10,
  parameter RED_YELLOW_MS         = 5000
)(
  input          clk_i_top,
  input          srst_i_top,

  input  [2:0]   cmd_type_i_top,
  input          cmd_valid_i_top,
  input  [15:0]  cmd_data_i_top,

  output logic   red_o_top,
  output logic   yellow_o_top,
  output logic   green_o_top
);
  logic         srst;

  logic [2:0]   cmd_type;
  logic         cmd_valid;
  logic [15:0]  cmd_data;

  logic         red;
  logic         yellow;
  logic         green;

  traffic_lights #(
    .BLINK_HALF_PERIOD_MS  ( BLINK_HALF_PERIOD_MS  ),
    .BLINK_GREEN_TIME_TICK ( BLINK_GREEN_TIME_TICK ),
    .RED_YELLOW_MS         ( RED_YELLOW_MS         )
  ) traffic_lights_ins(
    .clk_i       ( clk_i_top  ),
    .srst_i      ( srst       ),

    .cmd_type_i  ( cmd_type  ),
    .cmd_valid_i ( cmd_valid ),
    .cmd_data_i  ( cmd_data  ),

    .red_o       ( red    ),
    .yellow_o    ( yellow ),
    .green_o     ( green  )
  );

  always_ff @( posedge clk_i_top )
    srst <= srst_i_top;

  always_ff @( posedge clk_i_top )
    cmd_type <= cmd_type_i_top;

  always_ff @( posedge clk_i_top )
    cmd_valid <= cmd_valid_i_top;

  always_ff @( posedge clk_i_top )
    cmd_data <= cmd_data_i_top;

  always_ff @( posedge clk_i_top )
    red_o_top <= red;
  always_ff @( posedge clk_i_top )
    green_o_top <= green;
  always_ff @( posedge clk_i_top )
    yellow_o_top <= yellow;

endmodule