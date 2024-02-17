module deserializer_tb;
  bit clk;
  bit srst;

  logic        data;
  logic        data_val;

  logic [15:0] deser_data;
  logic        deser_data_val;

  deserializer DUT (
    .clk_i             ( clk ),
    .srst_i            ( srst ),

    .data_i            ( data ),
    .data_val_i        ( data_val ),

    .deser_data_o      ( deser_data ),
    .deser_data_val_o  ( deser_data_val )
  );

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking

  initial
    begin
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      for (int i = 0; i < 1000; i++) 
        begin
          ##1;
          data     <= $urandom_range(0, 1);
          data_val <= $urandom_range(0, 1);
        end
      ##1;
      $stop();
    end

endmodule