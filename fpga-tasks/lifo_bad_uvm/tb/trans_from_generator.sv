class trans_from_generator #(
  parameter int DWIDTH = 16
);
  local rq_code req_type;
  local logic [DWIDTH-1:0] word;
  
  function new(rq_code req_type, logic [DWIDTH-1:0] word);
    this.req_type = req_type;
    this.word     = word;
  endfunction

  function rq_code get_req_type();
    return this.req_type;
  endfunction

  function logic [DWIDTH-1:0] get_word();
    return this.word;
  endfunction
endclass 