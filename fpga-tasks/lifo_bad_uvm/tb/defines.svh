`include "macro.sv"
parameter int REQ_EMPTY = 0;
parameter int REQ_READ  = 1;
parameter int REQ_WRITE = 2;
parameter int REQ_RW    = 3;

typedef enum { 
  SOME_RW,
  WRITE_READ_FULL,
  OVER_RW
} test_case;

