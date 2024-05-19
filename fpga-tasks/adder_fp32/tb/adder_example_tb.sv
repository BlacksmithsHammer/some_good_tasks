module adder_example_tb #();

  bit clk;
  bit srst;

  logic         valid_stb_input;
  logic  [31:0] a;
  logic  [31:0] b;

  logic  [31:0] z;

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking

  adder_example adder_ex_ins (
    .clk  (clk),
    .srst (srst),

    .valid_stb_i (valid_stb_input),
    .a_i  (a),
    .b_i  (b),

    .z_o  (z)
  );

  initial
    begin
      srst = 1'b1;
      ##1;
      srst = 1'b0;
      ##5;
      valid_stb_input = 1'b1;
      a = 32'b01000010100000001101110100101111; //64.432
      b = 32'b01000011010000011110011001100110; //193.9
      ##1;
      valid_stb_input = 1'b0;
      ##5
      valid_stb_input = 1'b1;
      ##20;
      
      $stop();
    end

endmodule