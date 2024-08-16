vlib work

vlog -sv ../rtl/ast_width_extender.sv
vlog -sv ./ast_we_if.sv
vlog -sv ./ast_we_package.sv
vlog -sv ./top_tb.sv

# uncomment one line to check test case

# FOUND_PROBLEM_CHANNEL
vsim -novopt -gTEST_CASE=0 top_tb

# TEST_PLAIN
# vsim -novopt -gTEST_CASE=1 top_tb

# TEST_PLAIN_RANDOMIZED
# vsim -novopt -gTEST_CASE=2 top_tb

# TEST_CHANNELS
# vsim -novopt -gTEST_CASE=3 top_tb

# TEST_RANDOM_BIG
# vsim -novopt -gTEST_CASE=4 top_tb


add log -r /*

add    wave -radix hex -r /*
delete wave            -r /top_tb/ast_we_ins/*

run -all