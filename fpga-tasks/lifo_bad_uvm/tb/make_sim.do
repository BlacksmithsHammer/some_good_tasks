vlib work

vlog -sv ../rtl/lifo.sv
vlog -sv ./lifo_if.sv
vlog -sv ./lifo_package.sv
vlog -sv ./lifo_tb.sv

# uncomment ONLY 1 of 4 test cases to check that
# i do it for visual checking
# for auto-check it can be moved in array...

# SOME_RW
vsim -novopt -gTEST_CASE=0 lifo_tb

# FULL_RW
# vsim -novopt -gTEST_CASE=1 lifo_tb

# OVER_RW
# vsim -novopt -gTEST_CASE=2 lifo_tb

# BIG_TEST
# vsim -novopt -gTEST_CASE=3 lifo_tb

add log -r /*

add wave -radix unsigned -r /lifo_tb/lifo_ins/*

run -all