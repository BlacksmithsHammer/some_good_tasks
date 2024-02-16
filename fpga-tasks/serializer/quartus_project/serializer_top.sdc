set_time_format -unit ns -decimal_places 3

create_clock -name {clk_150} -period 150MHz [get_ports {clk_150_mhz_i_top}]

derive_clock_uncertainty


set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_i_top[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_mod_i_top[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_mod_i_top[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_mod_i_top[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_mod_i_top[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {data_val_i_top}]
set_input_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {srst_i_top}]

set_output_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {busy_o_top}]
set_output_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {ser_data_o_top}]
set_output_delay -add_delay  -clock [get_clocks {clk_150}]  1.000 [get_ports {ser_data_val_o_top}]