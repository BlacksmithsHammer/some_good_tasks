module bit_population_counter#(
  parameter WIDTH         = 32,
  parameter SIZE_PIPELINE = 16
)(
  input  logic                      clk_i,
  input  logic                      srst_i,

  input  logic [WIDTH-1:0]          data_i,
  input  logic                      data_val_i,

  output logic [$clog2(WIDTH):0]    data_o,
  output logic                      data_val_o
);
  
  logic [WIDTH-1:0]          data;
  logic                      data_val;

  always_ff @( posedge clk_i ) 
    if( srst_i )
      data_val <= 1'b0;
    else
      data_val <= data_val_i;

  always_ff @( posedge clk_i )
    data <= data_i;
  
  generate
    if (WIDTH <= 24)
      begin
        simple_counter#(
          .WIDTH  ( WIDTH )
        ) simple_counter_ins (
          .data_i ( data   ), 
          .data_o ( data_o )
        );
        assign data_val_o = data_val;
      end
    else
      begin
        logic [(WIDTH/SIZE_PIPELINE)-1:0][$clog2(SIZE_PIPELINE):0] tmp_cnts;
        logic [1:0] dff;

        always_ff @( posedge clk_i )
          if( srst_i )
            dff <= '0;
          else
            dff <= { dff[0], data_val };
        
        genvar i;
        for(i = 0; i < WIDTH/SIZE_PIPELINE; i = i + 1)
          begin: pipes
            logic [$clog2(SIZE_PIPELINE):0] tmp_cnt;

            simple_counter#(
              .WIDTH  ( SIZE_PIPELINE )
            ) simple_counter_ins (
              .clk_i  ( clk_i                                           ),

              .data_i ( data[SIZE_PIPELINE*(i+1)-1 : SIZE_PIPELINE*(i)] ), 
              .data_o ( tmp_cnt                                         )
            );

            always_ff @( posedge clk_i )
              tmp_cnts[i] <= tmp_cnt;
          end

            
        always_comb
          begin
            logic [$clog2(WIDTH):0] sum_cnts;
            sum_cnts = '0;
            
            for(int i = 0; i < WIDTH/SIZE_PIPELINE; i = i + 1)
              sum_cnts += tmp_cnts[i];
            
            data_o     = sum_cnts;
            data_val_o = dff[1];
          end
      end
  endgenerate

endmodule