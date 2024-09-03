module ast_dmx #(
  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),

  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
)(
  input                                clk_i,
  input                                srst_i,

  input       [DIR_SEL_WIDTH - 1 : 0]  dir_i,

  input       [DATA_WIDTH    - 1 : 0]  ast_data_i,
  input                                ast_startofpacket_i,
  input                                ast_endofpacket_i,
  input                                ast_valid_i,
  input       [EMPTY_WIDTH   - 1 : 0]  ast_empty_i,
  input       [CHANNEL_WIDTH - 1 : 0]  ast_channel_i,
  output logic                         ast_ready_o,

  output logic [DATA_WIDTH    - 1 : 0] ast_data_o          [TX_DIR-1:0],
  output logic                         ast_startofpacket_o [TX_DIR-1:0],
  output logic                         ast_endofpacket_o   [TX_DIR-1:0],
  output logic                         ast_valid_o         [TX_DIR-1:0],
  output logic [EMPTY_WIDTH   - 1 : 0] ast_empty_o         [TX_DIR-1:0],
  output logic [CHANNEL_WIDTH - 1 : 0] ast_channel_o       [TX_DIR-1:0],
  input                                ast_ready_i         [TX_DIR-1:0]
);

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "ModelSim" , encrypt_agent_info = "10.5b"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
W5TAFbqKfJi6UVi+TDLAUrYEeXWEAbwjqvoVGpv7RBi7LVK8q1L2kUESe9p5QyeI
KmIftPYanHWWyAO6NVG7jX24NMg/L4QtQWC2eC2O0xRuTl5A2zUkAlMJa14J8xzT
6vPFAI5bTWdsvWepAtzeC2DtS0IvzXxzkYc2dCsCMlwtPKUPEprBcDcVMKXtMsZi
SVsP+0Fa4ceiE5jdbO4vVkaveUpBKjpTvyhdJMPwooqs8yi3Wx9JBefRggchFRJs
oNSmx6UurWb/0vsHStpMX3LOVoFGwaVoho+KWaatFdlqrLw5KJsRRZnnJV/gXE+e
LxImcamhdRCWsudin4DTuQ==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 2800 )
`pragma protect data_block
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
3F/ldtNQ2NgsD7BTl94nwA==
`pragma protect end_protected
