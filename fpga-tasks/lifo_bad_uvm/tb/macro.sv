`define THROW_WRONG_SIGNALS(expected, got, problem_name) \
    begin \
      $display("EXPECTED %5u, got %5u", expected, got); \
      $error(problem_name, $time); \
      $stop(); \
    end 

`define SHOW_WRONG_SIGNALS(expected, got, problem_name) \
    begin \
      $display("EXPECTED %5u, got %5u", expected, got); \
      $display(problem_name, $time); \
    end 

`define THROW_CRITICAL_ERROR(problem_name) \
    begin \
      $error(problem_name, $time); \
      $stop(); \
    end