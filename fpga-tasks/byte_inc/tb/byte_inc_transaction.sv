class byte_inc_transaction #(
  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local logic [7:0] data [2**ADDR_WIDTH * BYTE_CNT];
  local int         length_add;
  local int         base_addr;
  local int         min_pause;
  local int         max_pause;

  function new( int base_addr,
                int length_add,
                int min_pause,
                int max_pause);
    this.base_addr  = base_addr;
    this.length_add = length_add;
    this.min_pause  = min_pause;
    this.max_pause  = max_pause;
  endfunction

  function logic [7:0] get_byte(int byte_addr);
    if( byte_addr >= 2**ADDR_WIDTH * BYTE_CNT) 
      `THROW_CRITICAL_ERROR("TRANSACTION: get_byte - ADDRESS OF BYTE IN MEMORY TOO BIG");

    return this.data[byte_addr];
  endfunction

  function void set_byte(int         byte_addr,
                         logic [7:0] byte_data);
    if( byte_addr >= 2**ADDR_WIDTH * BYTE_CNT) 
      `THROW_CRITICAL_ERROR("TRANSACTION: set_byte - ADDRESS OF BYTE IN MEMORY TOO BIG");
    
    this.data[byte_addr] = byte_data;
  endfunction

  function int get_min_pause();
    return this.min_pause;
  endfunction

  function int get_max_pause();
    return this.max_pause;
  endfunction
endclass 