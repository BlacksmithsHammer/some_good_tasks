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
                  int                      cnt);
    while( cnt-- > 0 )
      begin
        

        task_struct new_task;
        new_task.data_i = $urandom_range(2**WIDTH-1, 0);
        
      end
    
  endtask

  initial
    begin
      srst <= 1'b1;
      ##1;
      srst <= 1'b0;
      ##1;
      data_val <= 1'b1;
      data     <= WIDTH*{1'b0};
      ##1;
      data_val <= 1'b1;
      data     <= $urandom_range(2**WIDTH-1, 0);
      for( int i = 0; i < 100; i = i + 1 )
        begin
          data_val <= 1'b1;
          data     <= $urandom_range(2**WIDTH-1, 0);
          ##1;
          data_val <= 1'b0;
          ##3;
        end
      ##2;
      $stop();
    end
endmodule