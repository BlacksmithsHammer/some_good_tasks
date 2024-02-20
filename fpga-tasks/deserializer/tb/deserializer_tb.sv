module deserializer_tb #(
  parameter DATA_WIDTH = 15
);
  bit                     clk;
  bit                     srst;

  logic                   data;
  logic                   data_val;

  logic [DATA_WIDTH-1:0]  deser_data;
  logic                   deser_data_val;

  typedef struct {
    logic [DATA_WIDTH-1:0]  test_data;
    int                     chance_bad_val; //the chance of the data_val for each transmitted bit will be true is: (1/chance_bad_val + 1)*100%;
  } task_struct;

  deserializer #(
    .DATA_WIDTH        ( DATA_WIDTH     )
  ) DUT (
    .clk_i             ( clk            ),
    .srst_i            ( srst           ),

    .data_i            ( data           ),
    .data_val_i        ( data_val       ),

    .deser_data_o      ( deser_data     ),
    .deser_data_val_o  ( deser_data_val )
  );
  
  mailbox                   expected_data = new(10);
  mailbox #( task_struct )  generated_tasks = new(10);

  task generate_tasks( mailbox #( task_struct )  mb_tasks,
                       int                       tasks_cnt,
                       int                       chance_bad_val);
    for (int i = 0; i <  tasks_cnt; i = i + 1)
      begin
        task_struct new_task;
        new_task.chance_bad_val = chance_bad_val;
        new_task.test_data      = $urandom_range(2**DATA_WIDTH-1, 0);
        mb_tasks.put( new_task );
      end
  endtask

  task send_tasks( mailbox #( task_struct )  mb_tasks );
    while( mb_tasks.num != 0 )
      begin
        int tmp_cnt;
        task_struct curr_task;

        tmp_cnt = 0;
        mb_tasks.get( curr_task );
        expected_data.put( curr_task.test_data );

        while( tmp_cnt < DATA_WIDTH )
          begin
            if( $urandom_range(curr_task.chance_bad_val, 0) == 0 )
              begin
                data                 <= curr_task.test_data[DATA_WIDTH-1];
                curr_task.test_data  <= curr_task.test_data << 1;
                data_val             <= 1'b1;
                tmp_cnt              = tmp_cnt + 1;
              end
            else
              begin
                data     <= $urandom_range(1, 0);
                data_val <= 1'b0;
              end
            ##1;
          end
      end
  endtask

  task check_tasks( int cnt_tasks );
    logic [DATA_WIDTH-1:0]  tmp_data;

    while( cnt_tasks > 0)
      begin
        ##1;
        if( deser_data_val )
          begin
            expected_data.get(tmp_data);
            if ( tmp_data == deser_data )
              cnt_tasks--;
            else
              begin
                $display("wrong data in time: ", $time);
                $stop();
              end
          end
      end
  endtask

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking

  int num_of_tasks = 1000;

  initial
    begin
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;

      for(int i = 0; i < DATA_WIDTH; i++)
        begin
          fork
            generate_tasks(generated_tasks, num_of_tasks, i);
            send_tasks(generated_tasks);
            check_tasks(num_of_tasks);
          join
          $display("%d tasks with %f%% of bad data_val_i were passed successfully", num_of_tasks, ( $bitstoreal(i)/$bitstoreal( i + 1 ) ) * 100 );
        end
      
      $display("All tests were passed successfully");
      ##1;

      $stop();
    end

endmodule