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

task throw_err(string msg);
  $display(msg, $time);
  $stop();
endtask

task send_and_compare( logic [15:0] test_data,
                       logic [4:0]  test_data_mod,
                       int          test_counter   = 0,
                       int          test_index     = 15);
  //begin input test data in correct format
  data     <= test_data;
  data_mod <= test_data_mod;
  data_val <= 1'b1;
  ##1;
  data_val <= 1'b0;
  //end input
  
  if( test_data_mod == 0 )
    test_data_mod = 16;

  if( test_data_mod > 2 )
    begin
      while( test_counter < test_data_mod )
        begin
          if( ( ( test_data_mod - test_counter ) > 1 ) && ~busy )
            throw_err("Busy is incorrect: expected 1 in time:");

          if( ( ( test_data_mod - test_counter ) == 1 ) && busy )
            throw_err("Busy is incorrect: expected 0 in time:");

          if( ser_data_val )
            begin
              if( ser_data != test_data[test_index] )
                throw_err("Error: wrong ser_data in time:");
              test_counter++;
              test_index--;
            end
          else
            throw_err("Error: wrong ser_data_val expected 1 in time:");
            
          ##1;
        end
    end
  else
    if( ser_data_val || busy )
      throw_err("The module should not transmit or do anything in time:");
endtask

initial
  begin
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;
    ##1;
    //continuous data_sending
    send_and_compare(16'b0110110011110001, 4'd5);
    send_and_compare(16'b1000110000010001, 4'd15);
    send_and_compare(16'b1001101000101111, 4'd0);
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
    for (int i = 0; i < 1000; i = i + 1)
      begin
        ##($urandom_range(0, 5));
        send_and_compare($urandom_range(2**16-1, 0), $urandom_range(2**4-1, 0));
      end;
    
    $display("The tests were passed successfully");
    $stop();
  end
endmodule
