vlib work

vlog -sv ../rtl/adder.sv
vlog -sv ../rtl/adder_example.sv
vlog -sv adder_example_tb.sv

vsim -novopt adder_example_tb

add log -r /*
add wave -r *
run -all