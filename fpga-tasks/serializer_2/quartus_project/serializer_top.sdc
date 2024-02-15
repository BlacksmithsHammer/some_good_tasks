set_time_format -unit ns -decimal_places 3

create_clock -name {clk_150} -period 150MHz [get_ports {clk_150_mhz_i_top}]

derive_clock_uncertainty