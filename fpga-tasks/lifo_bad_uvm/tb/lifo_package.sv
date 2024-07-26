package lifo_package;
  typedef enum { 
    REQ_EMPTY,
    REQ_READ,
    REQ_WRITE,
    REQ_RW
  } rq_code;

  typedef enum { 
    SOME_RW,
    FULL_RW,
    OVER_RW,
    BIG_TEST
  } test_case;
  
  `include "macro.sv"
  `include "trans_from_monitor.sv"
  `include "trans_from_generator.sv"
  `include "lifo_generator.sv"
  `include "lifo_driver.sv"
  `include "lifo_monitor.sv"
  `include "lifo_scoreboard.sv"
  `include "lifo_enviroment.sv"
endpackage