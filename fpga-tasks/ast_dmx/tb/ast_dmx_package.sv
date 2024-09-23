package ast_dmx_package;
  typedef enum {
    ONE_BYTE,
    ONE_BYTE_RAND_READY,
    TEST
    
  } test_case;

  `include "macro.sv"
  `include "ast_dmx_transaction.sv"
  `include "ast_dmx_generator.sv"
  `include "ast_dmx_driver.sv"
  `include "ast_dmx_monitor.sv"
  `include "ast_dmx_scoreboard.sv"
  `include "ast_dmx_enviroment.sv"

endpackage