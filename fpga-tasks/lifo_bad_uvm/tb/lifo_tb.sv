/////////////////////////////////////////////////////////////////////
// DEFINES
/////////////////////////////////////////////////////////////////////
localparam int REQ_EMPTY = 0;
localparam int REQ_READ  = 1;
localparam int REQ_WRITE = 2;
localparam int REQ_RW    = 3;

/////////////////////////////////////////////////////////////////////
//MACRO
/////////////////////////////////////////////////////////////////////
`define THROW_WRONG_SIGNALS(expected, got, problem_name) \
    begin \
      $display("EXPECTED %5u, got %5u", expected, got); \
      $error(problem_name, $time); \
      $stop(); \
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

class trans_from_gen #(
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
  local virtual lifo_if    _if;
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

  task generate_new( int n  = 10,
                     int op = REQ_RW);
    T tr;
    for (int i = 0; i < n; i++) 
      begin
        tr = new( op, $urandom_range(2**32 - 1, 0) );
        $display(tr.get_word());
        this.gen2drv.put( tr );
      end
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

  function new(virtual lifo_if _if, mailbox #( T ) gen2drv);
    this.gen2drv   = gen2drv;
    this._if       = _if;
    this._if.rdreq = 0;
    this._if.wrreq = 0;
    this._if.data  = $urandom_range(2**32-1, 0);
  endfunction

  task update(T trans);
    this.trans = trans;
  endtask

  task send();
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

  initial
    begin


      mailbox #( trans_from_gen ) gen2drv;

      lifo_generator #( trans_from_gen ) gen;
      lifo_driver    #( trans_from_gen ) drv;
      gen2drv = new();
      gen = new(      gen2drv );
      drv = new( _if, gen2drv );


      srst <= 1;
      ##1;
      srst <= 0;



      fork      
        gen.generate_new(20, REQ_WRITE);
        gen.generate_new(20, REQ_READ);
        drv.run();
      join_none



      ##100;
      $stop();
    end

endmodule
