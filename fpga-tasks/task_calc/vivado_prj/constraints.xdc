create_clock -name clk -period 2.5 [get_ports clk]

set_clock_uncertainty -setup 0.2 [get_clocks clk]
set_clock_uncertainty -hold  0.1 [get_clocks clk]

set_false_path -from [all_inputs] -to [all_outputs]
set_false_path -from [all_inputs] -to [all_registers]
set_false_path -from [all_registers] -to [all_outputs]
