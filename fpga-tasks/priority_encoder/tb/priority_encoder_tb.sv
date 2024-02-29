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
  
  function logic [WIDTH-1:0] find_right;
    input  logic [WIDTH-1:0] data;
    find_right = data & ( ~(data-1) );
  endfunction

  function logic [WIDTH-1:0] find_left;
    input  logic [WIDTH-1:0] data;
    find_left = { <<{ find_right({ <<{data} }) } };
  endfunction

  task add_custom_task( mailbox #( task_struct ) generated_tasks,
                        logic    [WIDTH-1:0]     new_data,
                        logic    [WIDTH-1:0]     data_left,
                        logic    [WIDTH-1:0]     data_right);
    task_struct new_task;
    
    new_task.data_i     = new_data;
    new_task.data_left  = data_left;
    new_task.data_right = data_right;

    generated_tasks.put(new_task);
  endtask

  task add_tasks( mailbox #( task_struct ) generated_tasks,
                  int                      cnt,
                  int                      left_border_skip,
                  int                      right_border_skip);
    while( cnt-- > 0 )
      begin
        task_struct new_task;

        new_task.data_i     = $urandom_range(2**WIDTH-1, 0);
        new_task.data_left  = find_left(new_task.data_i);
        new_task.data_right = find_right(new_task.data_i);

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
            cnt--;
            expected_data.get(tmp_task);
            if( ( tmp_task.data_left != data_left_o ) || ( tmp_task.data_right != data_right_o ) )
              begin
                $display("wrong data in time: ", $time);
                $stop();
              end
          end
      end
  endtask

  int number_of_tasks = 10000; //tasks per 1 group of specified tasks

  initial
    begin
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;

      //custom tasks
      fork
        add_custom_task(generated_tasks, '0, '0, '0);
        send_tasks(generated_tasks, expected_data, 1);
        check_results(expected_data, 1);
      join
      //end custom tasks

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