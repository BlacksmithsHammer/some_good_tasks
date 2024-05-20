module stream_upsize_tb #(
  parameter T_DATA_WIDTH = 4,
  parameter T_DATA_RATIO = 3
);

  bit clk;
  bit rst_n;

  initial
    forever
      #5 clk = !clk;
  
  default clocking cb
    @( posedge clk );
  endclocking

  logic [T_DATA_WIDTH-1:0] s_data;
  logic                    s_last;
  logic                    s_valid;
  logic                    s_ready;

  logic [T_DATA_WIDTH-1:0] m_data  [T_DATA_RATIO-1:0];
  logic [T_DATA_RATIO-1:0] m_keep;
  logic                    m_last;
  logic                    m_valid;
  logic                    m_ready;

  stream_upsize #(
    .T_DATA_WIDTH ( T_DATA_WIDTH ),
    .T_DATA_RATIO ( T_DATA_RATIO )
  ) stream_ins (
    .clk       ( clk     ),
    .rst_n     ( rst_n   ),

    .s_data_i  ( s_data  ),
    .s_last_i  ( s_last  ),
    .s_valid_i ( s_valid ),
    .s_ready_o ( s_ready ),

    .m_data_o  ( m_data  ),
    .m_keep_o  ( m_keep  ),
    .m_last_o  ( m_last  ),
    .m_valid_o ( m_valid ),
    .m_ready_i ( m_ready )
  );

  task send_word(logic [T_DATA_WIDTH-1:0] test_data,
                 logic                    last_word);
    s_data = test_data;
    s_valid = 1'b1;
    if( last_word )
      s_last = 1'b1;
    ##1;
    s_last  = 1'b0;
    s_valid = 1'b0;
  endtask 

  task send_packet(int   num_packets,
                   logic last_not_full);
    while (num_packets-- > 1) 
      begin
        //up to 32 bits, no more
        send_word($urandom_range(2**32 - 1, 0), 0);
      end

    send_word($urandom_range(2**32 - 1, 0), 1);
  endtask

  initial
    forever
      begin
      ##1;
      if( m_valid ) $info($time);
      end

  initial
    begin
      rst_n = 1'b0;
      ##1;
      m_ready = 1'b1;
      s_last  = 1'b0;
      rst_n = 1'b1;
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      send_word($urandom_range(2**32 - 1, 0), 0);
      ##20
      send_packet(5, 1);
      ##20;
      send_packet(5, 1);
      ##4;



      $stop();
    end
endmodule