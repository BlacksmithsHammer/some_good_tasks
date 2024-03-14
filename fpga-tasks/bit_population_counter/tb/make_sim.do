vlib work

vlog -sv ../rtl/simple_counter.sv
vlog -sv ../rtl/bit_population_counter.sv
vlog -sv bit_population_counter_tb.sv

vsim -novopt bit_population_counter_tb

add log -r /*
add wave -r *
run -all