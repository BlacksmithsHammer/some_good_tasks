module top_tb;

bit clk;
bit srst;

logic [15:0]  data;
logic         data_val;
logic [3:0]   data_mod;
logic         ser_data;
logic         ser_data_val;
logic         busy;

serializer DUT (
  .clk_i           ( clk ),
  .srst_i          ( srst ),
  .data_i          ( data ),
  .data_val_i      ( data_val ),
  .data_mod_i      ( data_mod ),
  .ser_data_o      ( ser_data ),
  .ser_data_val_o  ( ser_data_val ),
  .busy_o          ( busy )
);

initial
  forever
    #5 clk = !clk;

default clocking cb
  @( posedge clk );
endclocking

task send_and_compare( logic [15:0] test_data,
                       logic [3:0]  test_data_mod);
  //begin input test data in correct format
  data     <= test_data;
  data_mod <= test_data_mod;
  data_val <= 1'b1;
  ##1;
  data_val <= 1'b0;
  //end input
  if (test_data_mod - 1 > 1)
    begin

      logic [3:0]  test_cnt;

      test_cnt = 4'd15;
      while (ser_data_val && busy && test_cnt > 0)
        begin
          if (ser_data != test_data[test_cnt])
            begin
              $display("test fallen, wrong bit in time: ", $time);
              $stop();
            end
          test_cnt = test_cnt - 1;
          ##1;
        end

      if (ser_data_val && ser_data != test_data[test_cnt])
          begin
            $display("test fallen, wrong bit in time: ", $time);
            $stop();
          end
      if (~test_cnt + 4'b0001 != test_data_mod)
          begin
            $display("test fallen, difference between lengths of serialized and test data in time:", $time);
            $stop();
          end
    end
  else
    if (ser_data_val)
      begin
        $display("the data is sent at a time when it is not allowed in time: ", $time);
        $stop();
      end


endtask

initial
  begin
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;
    ##1;
    //continuous data_sending
    send_and_compare(16'b0110110011110001, 4'd5);
    send_and_compare(16'b1000110000010001, 4'd10);
    send_and_compare(16'b1010110010101001, 4'd3);
    send_and_compare(16'b1010010110010100, 4'd0);
    send_and_compare(16'b0110110011110001, 4'd1);
    send_and_compare(16'b1000110000010001, 4'd10);
    send_and_compare(16'b1010110010101001, 4'd0);
    send_and_compare(16'b1010010110010100, 4'd2);
    send_and_compare(16'b0110110011110001, 4'd1);
    send_and_compare(16'b1000110000010001, 4'd10);
    send_and_compare(16'b1010110010101001, 4'd3);
    send_and_compare(16'b1010010110010100, 4'd6);
    
    //sending with random pauses
    for (int i = 0; i < 100; i = i + 1)
      begin
        ##($urandom_range(0, 5));
        send_and_compare($urandom_range(2**16-1, 0), $urandom_range(2**4-1, 0));
      end;

    $display("The tests were passed successfully");
    $stop();
  end
endmodule