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