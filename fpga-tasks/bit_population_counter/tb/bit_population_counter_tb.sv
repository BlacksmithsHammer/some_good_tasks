module bit_population_counter_tb #(
  parameter WIDTH = 64
);

  bit                        clk_i;
  bit                        srst_i;

  logic [WIDTH-1:0]          data_i;
  logic                      data_val_i;

  logic [$clog2(WIDTH):0]    data_o;
  logic                      data_val_o;

   typedef struct {
    //data that put into the data_i
    logic [WIDTH-1:0]          data;
    //expected data in data_o
    logic [$clog2(WIDTH):0]    cnt;
    //time without sending new tasks
    int                        skip;
  } task_struct;

  mailbox #( task_struct ) generated_tasks = new(100);
  mailbox                  expected_data   = new(100);

  bit_population_counter #(
    .WIDTH         ( WIDTH      )
  ) DUT (
    .clk_i         ( clk_i      ),
    .srst_i        ( srst_i     ),

    .data_i        ( data_i     ),
    .data_val_i    ( data_val_i ),

    .data_o        ( data_o     ),
    .data_val_o    ( data_val_o )
  );

  initial
    forever
      #5 clk_i = !clk_i;

  default clocking cb
    @( posedge clk_i );
  endclocking

  //creating the number of tasks = number_of_tasks and uploading them to a dynamic queue
  task add_tasks( mailbox #( task_struct ) generated_tasks,
                  int                      number_of_tasks,
                  int                      skip);
    while(number_of_tasks-- > 0)
      begin
        logic [7:0][31:0] tmp_data; 
        logic [WIDTH-1:0] tmp_cnt;      
        task_struct new_task;
        new_task.skip = skip;
        new_task.cnt  = '0;
        
        for (int i = 0; i < 8; i++)
          tmp_data[i] = $urandom_range(2**32-1, 0);
      
        //like a converting decimal into the binary number
        new_task.data = tmp_data;
        tmp_cnt = new_task.data;
        while(tmp_cnt > 0)
          begin
            new_task.cnt += tmp_cnt % 2;
            tmp_cnt /= 2;
          end

        generated_tasks.put(new_task);
      end
  endtask

  task add_custom_task( mailbox #( task_struct )  generated_tasks,
                        logic   [WIDTH-1:0]       custom_data,
                        logic   [$clog2(WIDTH):0] custom_cnt,
                        int                       skip);

    task_struct new_task;
    new_task.skip = skip;
    new_task.cnt  = custom_cnt;
    new_task.data = custom_data;

    generated_tasks.put(new_task);
  endtask

  //receiving new tasks from the queue
  task send_tasks( mailbox #( task_struct ) generated_tasks,
                   mailbox                  expected_data,
                   int                      number_of_tasks);
    while(number_of_tasks-- > 0)
      begin
        task_struct tmp_task;
        generated_tasks.get(tmp_task);
        expected_data.put(tmp_task.cnt);
        
        data_i     <= tmp_task.data;
        data_val_i <= 1'b1;
        ##1;
        data_val_i <= 1'b0;
        ##(tmp_task.skip);
      end
  endtask
  
  //checking the output data with the correct answer
  task check_tasks( mailbox expected_data,
                    int     number_of_tasks);
    int tmp_cnt;
    while(number_of_tasks > 0)
      begin
        ##1;
        if( data_val_o == 1'b1 )
          begin
            number_of_tasks--;
            expected_data.get(tmp_cnt);
            if( tmp_cnt != data_o)
              begin
                $display("Wrong data in time: ", $time, "WIDTH = ", WIDTH, "   expected: ", tmp_cnt);
                $stop();
              end
          end
      end
  endtask 

  initial
    begin
      int tasks_per_call = 2000;
      srst_i <= 1'b1;
      ##1;
      srst_i <= 1'b0;
      ##1;
      //start of custom tests
      fork
        add_custom_task(generated_tasks, '0, 0, 0);
        add_custom_task(generated_tasks, '1, WIDTH, 0);
        send_tasks(generated_tasks, expected_data, 2);
        check_tasks(expected_data, 2);
      join
      //end of custom tests
      ##1;
      for(int i = 0; i < 10; i++)
        fork
          add_tasks(generated_tasks, tasks_per_call, i);
          send_tasks(generated_tasks, expected_data, tasks_per_call);
          check_tasks(expected_data, tasks_per_call);
        join
      $display("tests passed successfully with WIDTH =", WIDTH);
      $stop();
    end
endmodule