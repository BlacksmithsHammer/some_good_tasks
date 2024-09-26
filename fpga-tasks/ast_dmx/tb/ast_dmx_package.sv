package ast_dmx_package;
  typedef enum {
    ONE_BYTE              = 0,
    ONE_BYTE_RAND_READY   = 1,
    MANY_BYTES_RAND_READY = 2,
    SWAP_DIRS_RAND_READY  = 3,
    MAIN_TEST             = 4
  } test_case;

  `include "macro.sv"
  `include "ast_dmx_transaction.sv"
  `include "ast_dmx_generator.sv"
  `include "ast_dmx_driver.sv"
  `include "ast_dmx_monitor.sv"
  `include "ast_dmx_scoreboard.sv"
  `include "ast_dmx_enviroment.sv"

endpackage