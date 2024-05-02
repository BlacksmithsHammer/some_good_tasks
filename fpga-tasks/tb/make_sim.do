vlib work

vlog -sv ../rtl/fifo.sv
vlog -sv fifo_tb.sv

vsim -novopt fifo_tb

add log -r /*
add wave -r *

run -all