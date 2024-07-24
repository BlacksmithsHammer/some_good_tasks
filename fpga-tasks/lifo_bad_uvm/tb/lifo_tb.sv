/////////////////////////////////////////////////////////////////////
// DEFINES
/////////////////////////////////////////////////////////////////////
parameter int REQ_EMPTY = 0;
parameter int REQ_READ  = 1;
parameter int REQ_WRITE = 2;
parameter int REQ_RW    = 3;

typedef enum { 
  SOME_RW,
  WRITE_READ_FULL,
  OVER_RW
} test_case;
/////////////////////////////////////////////////////////////////////
// MACRO
/////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////
// INTERFACE
/////////////////////////////////////////////////////////////////////
interface lifo_if #(
  parameter int DWIDTH = 16,
  parameter int AWIDTH = 8
)(
    input  clk
);

  default clocking cb
    @( posedge clk );
  endclocking;
  
  logic              wrreq;
  logic [DWIDTH-1:0] data;
  logic              rdreq;

  logic [DWIDTH-1:0] q;
  logic              almost_empty;
  logic              empty;
  logic              almost_full;
  logic              full;
  logic [AWIDTH:0]   usedw;
      
endinterface 

/////////////////////////////////////////////////////////////////////
// CLASS TRANSACTION: GENERATOR TO DRIVER,
//                    GENERATOR TO SCOREBOARD
/////////////////////////////////////////////////////////////////////

class trans_from_generator #(
  parameter int DWIDTH = 16
);
  local int req_type;
  local logic [DWIDTH-1:0] word;
  
  function new(int req_type, word);
    this.req_type = req_type;
    this.word     = word;
  endfunction

  function int get_req_type();
    return this.req_type;
  endfunction

  function logic [DWIDTH-1:0] get_word();
    return this.word;
  endfunction
endclass 

/////////////////////////////////////////////////////////////////////
// CLASS TRANSACTION: MONITOR TO SCOREBOARD
/////////////////////////////////////////////////////////////////////
class trans_from_monitor #(
  parameter int DWIDTH = 16,
  parameter int AWIDTH = 8
);
  local logic [DWIDTH-1:0] word;
  local logic              almost_empty;
  local logic              empty;
  local logic              almost_full;
  local logic              full;
  local logic [AWIDTH:0]   usedw;
  
  function new(virtual lifo_if _if);
    this.word         = _if.q;
    this.almost_empty = _if.almost_empty;
    this.empty        = _if.empty;
    this.almost_full  = _if.almost_full;
    this.full         = _if.full;
    this.usedw        = _if.usedw;
  endfunction

  function logic [DWIDTH-1:0] get_word();
    return this.word;
  endfunction

  function logic get_almost_empty();
    return this.almost_empty;
  endfunction
  
  function logic get_empty();
    return this.empty;
  endfunction
  
  function logic get_almost_full();
    return this.almost_full;
  endfunction

  function logic get_full();
    return this.full;
  endfunction

  function logic [AWIDTH:0] get_usedw();
    return this.usedw;
  endfunction
endclass 

/////////////////////////////////////////////////////////////////////
// GENERATOR (+-sequencer)
/////////////////////////////////////////////////////////////////////
class lifo_generator #(
  type T
  // ignored DWIDTH and AWIDTH
);
  local mailbox #( T ) gen2drv;

  function new( input mailbox #( T ) gen2drv );
    this.gen2drv = gen2drv;
  endfunction

  task generate_stimulus( int n  = 10,
                          int op = REQ_RW);
    T tr;
    for (int i = 0; i < n; i++) 
      begin
        tr = new( op, $urandom_range(2**32 - 1, 0) );
        $display(tr.get_word());
        this.gen2drv.put( tr );
      end
  endtask

  task generate_test(test_case _test);
    case( _test )
      SOME_RW:
        begin
          generate_stimulus(5, REQ_WRITE);
          generate_stimulus(5, REQ_READ );
        end
      WRITE_READ_FULL:
        begin

        end

      OVER_RW:
        begin

        end
      
      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end
    endcase
  endtask

endclass

/////////////////////////////////////////////////////////////////////
// TX driver
/////////////////////////////////////////////////////////////////////
class lifo_driver #(
  type T
);
  local mailbox #( T ) gen2drv;
  local mailbox #( T ) drv2scb;
  
  local T trans;
  local virtual lifo_if _if;

  function new(virtual lifo_if _if, mailbox #( T ) gen2drv, mailbox #( T ) drv2scb);
    this.gen2drv   = gen2drv;
    this.drv2scb   = drv2scb;
    this._if       = _if;
    this._if.rdreq = 0;
    this._if.wrreq = 0;
    this._if.data  = $urandom_range(2**32-1, 0);
  endfunction

  task update(T trans);
    this.trans = trans;
  endtask

  task send();
    this.drv2scb.put( this.trans );

    case( this.trans.get_req_type() )
      REQ_EMPTY:
        begin
          this._if.data <= $urandom_range(2**32-1, 0);
        end
      REQ_READ:
        begin
          this._if.rdreq <= 1'b1;
          this._if.data  <= $urandom_range(2**32-1, 0);
        end
      REQ_WRITE:
        begin
          this._if.wrreq <= 1'b1;
          this._if.data  <= this.trans.get_word();
        end
      REQ_RW:
        begin
          this._if.rdreq <= 1'b1;
          this._if.wrreq <= 1'b1;
          this._if.data  <= this.trans.get_word();
        end
      default:
        begin
          `THROW_CRITICAL_ERROR("UNEXPECTED CODE IN DRIVER TRANSACTION");
        end
    endcase

    @( this._if.cb );
    this._if.wrreq <= 1'b0;
    this._if.rdreq <= 1'b0;
    this._if.data  <= $urandom_range(2**32-1, 0);
  endtask

  task run();
    T _trans;

    while (this.gen2drv.num())
      begin
        this.gen2drv.get(_trans);
        this.update(_trans);
        this.send();
      end
  endtask
endclass

/////////////////////////////////////////////////////////////////////
// monitor
/////////////////////////////////////////////////////////////////////
class lifo_monitor #(type T);
  local mailbox #( T ) mon2scb;
  local virtual lifo_if _if;

  function new(virtual lifo_if _if, mailbox #( T ) mon2scb);
    this.mon2scb   = mon2scb;
    this._if       = _if;
  endfunction

  task run(int time_cycles);
    T tr;
    while(time_cycles)
      begin
        time_cycles = time_cycles - 1;
        @( this._if.cb );
        tr = new(_if);
        mon2scb.put(tr);
      end
  endtask
endclass


/////////////////////////////////////////////////////////////////////
// scoreboard
/////////////////////////////////////////////////////////////////////
class lifo_scoreboard #(
  type T_from_generator,
  type T_from_monitor
);
  local mailbox #( T_from_generator ) gen2scb;
  local mailbox #( T_from_monitor   ) mon2scb;

  function new( mailbox #( T_from_generator ) gen2scb,
                mailbox #( T_from_monitor   ) mon2scb);
    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;
  endfunction
endclass


/////////////////////////////////////////////////////////////////////
// enviroment with part-phase structure
/////////////////////////////////////////////////////////////////////
class lifo_enviroment #( 
  type T_from_generator, 
  type T_from_monitor
);
  local lifo_generator  #( T_from_generator                 ) gen;
  local lifo_driver     #( T_from_generator                 ) drv;
  local lifo_monitor    #(                   T_from_monitor ) mon;
  local lifo_scoreboard #( T_from_generator, T_from_monitor ) scb;
  
  mailbox #( T_from_generator   ) gen2drv;
  mailbox #( T_from_generator   ) drv2scb;
  mailbox #( T_from_monitor     ) mon2scb;
  
  
  task build(virtual lifo_if _if);
    gen2drv = new();
    drv2scb = new();
    mon2scb = new();

    gen = new(      gen2drv          );
    drv = new( _if, gen2drv, drv2scb );
    mon = new( _if,          mon2scb );
    scb = new(      drv2scb, mon2scb );
  endtask

  task run(test_case _test);
    gen.generate_test(_test);
    drv.run();
  endtask

endclass


module lifo_tb #(
  parameter int DWIDTH        = 16,
  parameter int AWIDTH        = 8,
  parameter int ALMOST_FULL   = 2,
  parameter int ALMOST_EMPTY  = 2
);
  
  bit clk;
  bit srst;

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking
  
  lifo_if #(
    .DWIDTH ( DWIDTH ),
    .AWIDTH ( AWIDTH )
  ) _if (
    .clk    ( clk    )
  ); 

  //////////////////////////////////////////////////////////
  // DUT instance
  //////////////////////////////////////////////////////////
  lifo #(
    .DWIDTH         ( DWIDTH           ),
    .AWIDTH         ( AWIDTH           ),
    .ALMOST_FULL    ( ALMOST_FULL      ),
    .ALMOST_EMPTY   ( ALMOST_EMPTY     )
  ) lifo_ins (
    .clk_i          ( clk              ),
    .srst_i         ( srst             ),

    .wrreq_i        ( _if.wrreq        ),
    .data_i         ( _if.data         ),

    .rdreq_i        ( _if.rdreq        ),
    .q_o            ( _if.q            ),

    .almost_empty_o ( _if.almost_empty ),
    .empty_o        ( _if.empty        ),
    .almost_full_o  ( _if.almost_full  ),
    .full_o         ( _if.full         ),
    .usedw_o        ( _if.usedw        )
  );

  task reset();
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;
  endtask

  initial
    begin
      lifo_enviroment #(trans_from_generator, trans_from_monitor) env;
      env = new();
      env.build(_if);
      reset();
      
      env.run(SOME_RW);

      ##5;      
      $stop();
    end

endmodule
