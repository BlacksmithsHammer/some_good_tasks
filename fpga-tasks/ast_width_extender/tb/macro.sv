`define THROW_WRONG_SIGNALS(expected, got, problem_name) \
    begin \
      $display("EXPECTED %5u, got %5u", expected, got); \
      $error(problem_name, $time); \
      $stop(); \
    end 

`define SHOW_WRONG_SIGNALS(expected, got, problem_name) \
    begin \
      $display(problem_name, "  AT TIME: %8d", $time); \
      $display("EXPECTED %8d, got %8d", expected, got); \
      $display("------------------------------------------------------------------");\
      //$stop  <-- uncomment me for find only first errors\
    end 

`define THROW_CRITICAL_ERROR(problem_name) \
    begin \
      $error(problem_name, $time); \
      $stop(); \
    end