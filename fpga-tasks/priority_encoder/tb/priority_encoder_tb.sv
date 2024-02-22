module priority_encoder_tb #(
  parameter WIDTH = 10
);

  bit                clk;
  bit                srst;

  logic [WIDTH-1:0]  data;
  logic              data_val;

  logic [WIDTH-1:0]  data_left_o;
  logic [WIDTH-1:0]  data_right_o;
  logic              data_val_o;

  typedef struct {
    logic [WIDTH-1:0]  data_i;
    logic [WIDTH-1:0]  data_left;
    logic [WIDTH-1:0]  data_right;
    int                left_border_skip;
    int                right_border_skip;
  } task_struct;

  mailbox #( task_struct )  generated_tasks = new(100);
  mailbox #( task_struct )  expected_data   = new(100);

  priority_encoder #(
    .WIDTH         ( WIDTH        )
  ) DUT (
    .clk_i         ( clk          ),
    .srst_i        ( srst         ),

    .data_i        ( data         ),
    .data_val_i    ( data_val     ),

    .data_left_o   ( data_left_o  ),
    .data_right_o  ( data_right_o ),
    .data_val_o    ( data_val_o   )
  );

  initial
    forever
      #5 clk = !clk;

  default clocking cb
    @( posedge clk );
  endclocking

  task add_tasks( mailbox #( task_struct ) generated_tasks,
                  int                      cnt,
                  int                      left_border_skip,
                  int                      right_border_skip);
    while( cnt-- > 0 )
      begin
        int right_flag, left_flag;
        task_struct new_task;

        right_flag = 0;
        left_flag  = WIDTH-1;
        new_task.data_i = $urandom_range(2**WIDTH-1, 0);
        
        while( ( new_task.data_i[right_flag] != 1'b1 ) && ( right_flag < WIDTH ) )
          right_flag++;
        while( ( new_task.data_i[left_flag]  != 1'b1 ) && ( left_flag > -1     ) )
          left_flag--;

        //second flag is not necessary
        if( right_flag != WIDTH )
          begin
            new_task.data_left              =  '0;
            new_task.data_left [left_flag ] = 1'b1;
            new_task.data_right             =  '0;
            new_task.data_right[right_flag] = 1'b1;
            //$display("%b   %b   %b", new_task.data_i, new_task.data_left, new_task.data_right);
          end
        else
          begin
            new_task.data_left  = '0;
            new_task.data_right = '0;
          end
        new_task.right_border_skip = right_border_skip;
        new_task.left_border_skip  = left_border_skip;
        generated_tasks.put(new_task);
      end
    
  endtask

  task send_tasks( mailbox #( task_struct ) generated_tasks,
                   mailbox #( task_struct ) expected_data,
                   int                      cnt);
    while( cnt-- > 0 )
      begin
        task_struct tmp_task;
        generated_tasks.get(tmp_task);
        expected_data.put(tmp_task);
        data_val <= 1'b1;
        data     <= tmp_task.data_i;
        ##1;
        data_val <= 1'b0;
        ##($urandom_range(tmp_task.left_border_skip, tmp_task.right_border_skip));

      end
  endtask

  task check_results( mailbox #( task_struct ) expected_data,
                      int                      cnt);
    task_struct tmp_task;
    while( cnt > 0 )
      begin
        ##1;
        if( data_val_o == 1'b1)
          begin
            cnt = cnt - 1;
            expected_data.get(tmp_task);
            if( ( tmp_task.data_left != data_left_o ) || ( tmp_task.data_right != data_right_o ) )
              begin
                $display("wrong data in time: ", $time);
                $stop();
              end
          end
      end
  endtask

  int number_of_tasks = 100; //tasks per 1 group of specified tasks

  initial
    begin
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;
      for(int i = 0; i < 10; i = i + 1)
        for(int j = i; j < 10; j = j + 1)
          begin
            fork
              add_tasks(generated_tasks, number_of_tasks, j, i);
              send_tasks(generated_tasks, expected_data, number_of_tasks);
              check_results(expected_data, number_of_tasks);
            join
            $display("Tests with random pauses range from %d to %d clocks passed", i, j);
          end
      $display("all tests were passed successfully");
      $stop();
    end
endmodule