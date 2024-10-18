class amm_byte_inc_transaction #(
  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local logic [7:0] data [2**ADDR_WIDTH * BYTE_CNT];
  local int         base_addr;
  local int         length_add;
  local int         chance_of_read;
  local int         chance_of_write;
  local int         latency_of_read;
  local int         have_problem;

  function new( int base_addr,
                int length_add,
                int chance_of_read,
                int chance_of_write,
                int latency_of_read);
    this.base_addr       = base_addr;
    this.length_add      = length_add;
    this.chance_of_read  = chance_of_read;
    this.chance_of_write = chance_of_write;
    this.latency_of_read = latency_of_read;
    this.have_problem    = 0;
  endfunction

  function amm_byte_inc_transaction #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) copy();
    amm_byte_inc_transaction cpy_tr;
    cpy_tr = new( this.get_base_addr(),
                  this.get_length_add(),
                  this.get_chance_of_read(),
                  this.get_chance_of_write(),
                  this.get_latency_of_read());
    
    for( int i = 0; i < 2**ADDR_WIDTH * BYTE_CNT; i++)
      cpy_tr.set_byte(i, this.get_byte(i));

    return cpy_tr;
  endfunction

  function logic [7:0] get_byte(int byte_addr);
    if( byte_addr >= 2**ADDR_WIDTH * BYTE_CNT) 
      `THROW_CRITICAL_ERROR("TRANSACTION: get_byte - ADDRESS OF BYTE IN MEMORY TOO BIG");

    return this.data[byte_addr];
  endfunction

  function void set_byte(int         byte_addr,
                         logic [7:0] byte_data);
    // if( byte_addr >= 2**ADDR_WIDTH * BYTE_CNT) 
    //   `THROW_CRITICAL_ERROR("TRANSACTION: set_byte - ADDRESS OF BYTE IN MEMORY TOO BIG");
    if( byte_addr < 2**ADDR_WIDTH * BYTE_CNT) 
      this.data[byte_addr] = byte_data;
  endfunction

  function void set_problem(int problem_id);
    this.have_problem = problem_id;
  endfunction

  function int get_problem();
    return this.have_problem;
  endfunction

  function int get_base_addr();
    return this.base_addr;
  endfunction

  function int get_length_add();
    return this.length_add;
  endfunction

  function int get_chance_of_read();
    return this.chance_of_read;
  endfunction

  function int get_chance_of_write();
    return this.chance_of_write;
  endfunction

  function int get_latency_of_read();
    return this.latency_of_read;
  endfunction

endclass 