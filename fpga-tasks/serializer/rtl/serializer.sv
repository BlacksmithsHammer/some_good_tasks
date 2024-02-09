module serializer (
  input  logic         clk_i,
  input  logic         srst_i,
  input  logic [15:0]  data_i,
  input  logic         data_val_i,
  input  logic [3:0]   data_mod_i,

  output logic         ser_data_o,
  output logic         ser_data_val_o,
  output logic         busy_o
);

  logic        busy;
  logic [3:0]  cnt;
  logic        ser_data_val;
  logic [15:0] data;

  always_ff @( posedge clk_i )
    begin
      if( srst_i )
        begin
          ser_data_val <= 1'b0;
          busy         <= 1'b0;
          data         <= '0;
          cnt          <= '0;
        end
      else
        if( data_val_i && ~busy && ( data_mod_i > 2 || data_mod_i == 0 ) )
          begin
            busy         <= 1'b1;
            ser_data_val <= 1'b1;
            data         <= data_i;
            cnt          <= ( data_mod_i - 1 );
          end
        else
          if (~busy && data_mod_i < 3)
            ser_data_val <= 1'b0;

      if ( busy )
        begin
          if ( cnt > 1 )
            begin
              for (int i = 15; i > 0; i = i - 1)
                data[i] <= data[i-1];
              data[0] <= 1'b0;
              cnt     <= cnt - 1;
            end
          else
            begin
              cnt      <= cnt - 1;
              data[15] <= data[14];
              busy     <= 1'b0;
            end
        end
      else
        if ( ~data_val_i)
          ser_data_val <= 1'b0;
    end

  assign ser_data_o     = data[15];
  assign busy_o         = busy;
  assign ser_data_val_o = ser_data_val;

endmodule