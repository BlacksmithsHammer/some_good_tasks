module adder_example_tb #();

  bit clk;
  bit srst;

  logic         ready;

  logic         valid_stb_input;
  logic  [31:0] a;
  logic  [31:0] b;

  logic         ack_z;
  logic  [31:0] z;
  logic         valid_stb_z;


  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking

  adder_example adder_ex_ins (
    .clk  ( clk  ),
    .srst ( srst ),

    .valid_stb_i ( valid_stb_input),
    .ready_o     ( ready          ),

    .a_i         ( a              ),
    .b_i         ( b              ),

    //signal of valid z = a + b in output
    .valid_stb_o ( valid_stb_z    ),
    .z_o         ( z              ),
    .ack_z_i     ( ack_z          )
  );

  task send_a_b(logic [31:0] test_a,
                logic [31:0] test_b);
    valid_stb_input = 1'b1;
    a = test_a;
    b = test_b;
    ##1;
    valid_stb_input = 1'b0;
  endtask
  

  int counter_test = 0;
  task new_test(logic [31:0] test_a,
                logic [31:0] test_b,
                logic [31:0] test_expected);
    wait(ready);
    ##1;
    send_a_b(test_a, test_b);
    wait(valid_stb_z);
    ack_z = 1'b1;
    counter_test++;
    $display("=========================Test case %d =========================", counter_test);
    $display("%f + %f == %f", $bitstoshortreal(test_a), 
                              $bitstoshortreal(test_b), 
                              $bitstoshortreal(z));
    ##2;
    ack_z = 1'b0;
    if( z != test_expected )
      begin
        $display("test %d not passed, expected: %f,  got: ", counter_test,
                                                    $bitstoshortreal(test_expected),
                                                    $bitstoshortreal(z));
        $stop();
      end
  endtask

  initial
    begin
      //initialization
      ack_z = 1'b0;
      valid_stb_input = 1'b0;
      srst = 1'b1;
      ##1;
      srst = 1'b0;
      //end of initialization

      
      new_test(32'b01000010100000001101110100101111,
               32'b01000011010000011110011001100110,
               32'b01000011100000010010101001111111);

      new_test(0,
               0,
               0);

      new_test('1,
               '1,
               32'hff_c0_00_00);
      
      new_test(32'b01000010101111100000111100001111,
               32'b01000011100001011101010101110100,
               32'b01000011101101010101100100111000);

      $display("======================== Tests passed ========================");
      $stop();
    end

endmodule

