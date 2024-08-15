package ast_we_package;
  typedef enum { 
    TEST_MVP,
    TEST_EVERY_SIZE,
    TEST_RANDOM_BIG
  } test_case;

  `include "macro.sv"
  `include "ast_we_transaction.sv"
  `include "ast_we_generator.sv"
  `include "ast_we_driver.sv"
  `include "ast_we_monitor.sv"
  `include "ast_we_scoreboard.sv"
  `include "ast_we_enviroment.sv"

endpackage