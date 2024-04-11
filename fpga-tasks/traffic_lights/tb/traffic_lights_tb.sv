//`timescale 10us/10us

module traffic_lights_tb #();

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

 
  logic  [2:0]   cmd_type;
  logic          cmd_valid;
  logic  [15:0]  cmd_data;

  traffic_lights #(

  ) DUT (
    .clk_i  ( clk  ),
    .srst_i ( srst ),

    .cmd_type_i  ( cmd_type  ),
    .cmd_valid_i ( cmd_valid ),
    .cmd_data_i  ( cmd_data  )
  );

  initial
    begin
      // sync reset
      srst = 1'b1;
      ##2;
      srst = 1'b0;
      ##1000;

      // switch OFF lights
      cmd_valid = 1'b1;
      cmd_type  = 3'd1;
      ##1
      cmd_valid = 1'b0;
      ##1000;
      
      // switch ON/switch to normal mode lights
      cmd_valid = 1'b1;
      cmd_type  = 3'd0;
      ##1;
      cmd_valid = 1'b0;
      //spam data into wrong state (not manual yellow)
      cmd_valid  = 1'b1;
      cmd_type   = 3'd3;
      cmd_data = 16'd100;
      ##1;
      cmd_type   = 3'd4;
      cmd_data = 16'd200;
      ##1;
      cmd_type   = 3'd5;
      cmd_data = 16'd300;
      ##1;
      cmd_valid  = 1'b0;
      //end spam
      ##1000;
      
      // switch to manual yellow mode
      cmd_valid = 1'b1;
      cmd_type  = 3'd2;
      ##1;
      cmd_valid = 1'b0;
      // write into valid state
      cmd_valid  = 1'b1;
      cmd_type   = 3'd3;
      cmd_data = 16'd100;
      ##1;
      cmd_type   = 3'd4;
      cmd_data = 16'd200;
      ##1;
      cmd_type   = 3'd5;
      cmd_data = 16'd300;
      ##1;
      cmd_valid  = 1'b0;
      // end write valid
      ##1000;

      // switch ON/switch to normal mode lights
      cmd_valid = 1'b1;
      cmd_type  = 3'd0;
      ##1;
      cmd_valid = 1'b0;
      ##10000;

      $stop();
    end

endmodule