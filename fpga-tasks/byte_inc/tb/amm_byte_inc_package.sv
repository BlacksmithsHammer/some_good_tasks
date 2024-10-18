package amm_byte_inc_package;

  typedef enum {
    MVP = 0
  } test_case;

  `include "macro.sv"
  `include "amm_byte_inc_transaction.sv"
  `include "amm_byte_inc_generator.sv"
  `include "amm_byte_inc_driver.sv"
  `include "amm_byte_inc_monitor.sv"
  `include "amm_byte_inc_scoreboard.sv"
  `include "amm_byte_inc_enviroment.sv"

endpackage