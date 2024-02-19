module deserializer_tb;
  bit clk;
  bit srst;

  logic         data;
  logic         data_val;

  logic [15:0]  deser_data;
  logic         deser_data_val;

  typedef struct {
    logic [15:0]  test_data;
    int           chance_bad_val; //the chance of the data_val for each transmitted bit will be true is: (1/chance_bad_val + 1)*100%;
  } task_struct;

  deserializer DUT (
    .clk_i             ( clk ),
    .srst_i            ( srst ),

    .data_i            ( data ),
    .data_val_i        ( data_val ),

    .deser_data_o      ( deser_data ),
    .deser_data_val_o  ( deser_data_val )
  );
  
  logic   [15:0]           current_task_data;
  mailbox #( task_struct ) generated_tasks = new();

  task generate_task( mailbox #( task_struct )  mb_tasks,
                      int                       tasks_cnt,
                      int                       chance_bad_val);
    for (int i = 0; i <  tasks_cnt; i = i + 1)
      begin
        task_struct new_task;
        new_task.chance_bad_val = chance_bad_val;
        new_task.test_data      = $urandom_range(2**16-1, 0);
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
        current_task_data <= curr_task.test_data;
        while( tmp_cnt < 16 )
          begin
            if( $urandom_range(curr_task.chance_bad_val, 0) == 0 )
              begin
                data                 <= curr_task.test_data[15];
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
    while( cnt_tasks > 0)
      begin
        ##1;
        if( deser_data_val )
          if ( current_task_data == deser_data )
            cnt_tasks--;
          else
            begin
              $display("wrong data in time: ", $time);
              $stop();
            end
      end
  endtask

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking

  int NUM_OF_TASKS = 1000;


  initial
    begin
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;

      for(int i = 0; i < 16; i++)
        begin
          generate_task(generated_tasks, NUM_OF_TASKS, i);
          fork
            send_tasks(generated_tasks);
            check_tasks(NUM_OF_TASKS);
          join
          $display("%d tasks with %f%% of bad data_val_i were passed successfully", NUM_OF_TASKS, $bitstoreal(i)/$bitstoreal( i + 1 ) * 100 );
        end
      $display("All tests were passed successfully");
      ##1;
      $stop();
    end

endmodule
