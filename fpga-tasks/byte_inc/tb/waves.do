# add    wave  -radix hex                   -r /*
add wave  /top_tb/dut/clk_i
add wave  /top_tb/dut/srst_i

# settings
add wave  -divider "Settings signals"
add wave  -group settings -radix unsigned  /top_tb/dut/base_addr_i
add wave  -group settings -radix unsigned  /top_tb/dut/length_i
add wave  -group settings                  /top_tb/dut/run_i
add wave  -group settings                  /top_tb/dut/waitrequest_o

# reader
add wave  -divider "Reader signals"
add wave  -group reader   -radix unsigned  /top_tb/dut/amm_rd_address_o
add wave  -group reader                    /top_tb/dut/amm_rd_read_o
add wave  -group reader   -radix hex       /top_tb/dut/amm_rd_readdata_i
add wave  -group reader                    /top_tb/dut/amm_rd_readdatavalid_i
add wave  -group reader                    /top_tb/dut/amm_rd_waitrequest_i

# writer
add wave  -divider "Writer signals"
add wave  -group writer   -radix unsigned  /top_tb/dut/amm_wr_address_o
add wave  -group writer                    /top_tb/dut/amm_wr_write_o
add wave  -group writer   -radix hex       /top_tb/dut/amm_wr_writedata_o
add wave  -group writer   -radix bin       /top_tb/dut/amm_wr_byteenable_o
add wave  -group writer                    /top_tb/dut/amm_wr_waitrequest_i
