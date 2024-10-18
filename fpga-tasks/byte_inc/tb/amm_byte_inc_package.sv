package amm_byte_inc_package;

  typedef enum {
    MVP                = 0,
    RANDOM_WAITREQUEST = 1,
    STATIC_WAITREQUEST = 2,
    OVERSIZE_LENGTH    = 3,
    MAX_LATENCY        = 4,
    BIG_TEST           = 5
  } test_case;

  `include "macro.sv"
  `include "amm_byte_inc_transaction.sv"
  `include "amm_byte_inc_generator.sv"
  `include "amm_byte_inc_driver.sv"
  `include "amm_byte_inc_monitor.sv"
  `include "amm_byte_inc_scoreboard.sv"
  `include "amm_byte_inc_enviroment.sv"

endpackage