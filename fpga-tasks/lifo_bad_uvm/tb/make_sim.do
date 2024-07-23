vlib work

vlog -sv ../rtl/lifo.sv
vlog -sv ./lifo_tb.sv

vsim -novopt lifo_tb
add log -r /*
add wave -radix unsigned -r *

run -all