module stream_upsize #(
    parameter T_DATA_WIDTH = 4,
              T_DATA_RATIO = 2
)(
    input  logic                    clk,
    input  logic                    rst_n,

    input  logic [T_DATA_WIDTH-1:0] s_data_i,
    input  logic                    s_last_i,
    input  logic                    s_valid_i,
    output logic                    s_ready_o,

    output logic [T_DATA_WIDTH-1:0] m_data_o  [T_DATA_RATIO-1:0],
    output logic [T_DATA_RATIO-1:0] m_keep_o,
    output logic                    m_last_o,
    output logic                    m_valid_o,
    input  logic                    m_ready_i
);
  //bit-mask
  logic [T_DATA_RATIO-1:0] val_data_packets;
  //buffer for saving tmp_data
  logic [T_DATA_WIDTH-1:0] data [T_DATA_RATIO-1:0];
  //pointer to write new data
  logic [$clog2(T_DATA_RATIO)-1:0] cnt;
  //dffs for valid and last flags
  logic valid_d;
  logic last_d;

  logic empty_buff;
  logic wr_en;
  logic wr_event;
  logic send_event;

  assign empty_buff = ( cnt != (T_DATA_RATIO - 1) || (cnt == T_DATA_RATIO - 1 && !s_valid_i) );
  assign wr_en      = empty_buff || (m_ready_i && !empty_buff) ;
  assign wr_event   = wr_en && s_valid_i;
  assign send_event = (s_last_i || !empty_buff) && m_ready_i;


  always_ff @( posedge clk )
    if ( !rst_n )
      valid_d <= 1'b0;
    else
      valid_d <= send_event;

  always_ff @( posedge clk )
    if ( !rst_n )
      last_d <= 1'b0;
    else
      if( wr_event )
        last_d <= s_last_i;

  always_ff @( posedge clk )
    if( !rst_n )
      cnt <= '0;
    else
      if( send_event )
        cnt <= '0;
      else
        if( wr_event )
          cnt <= cnt + 1'b1;

  always_ff @( posedge clk )
    if( wr_event )
      data[cnt] <= s_data_i;

  always_ff @( posedge clk )
    if( !rst_n )
      val_data_packets <= '0;
    else
      if( valid_d && wr_event && !s_last_i)
        val_data_packets <= 1'b1;
      else if ( valid_d && wr_event )
        val_data_packets <= 1'b0;
      
      else
        if( wr_event )
          val_data_packets <= { val_data_packets, 1'b1 };

  assign s_ready_o = wr_en || empty_buff;
  assign m_keep_o  = val_data_packets;
  assign m_data_o  = data;
  assign m_valid_o = valid_d;
  assign m_last_o  = last_d;

endmodule