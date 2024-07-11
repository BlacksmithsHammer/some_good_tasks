`define THROW_WITH_EXPLAIN(expected, got, problem_name) \
    begin \
      $display("EXPECTED %5u, got %5u", expected, got); \
      $error(problem_name, $time); \
      ##5; \
      $stop(); \
    end