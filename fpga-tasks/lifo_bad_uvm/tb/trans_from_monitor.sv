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