vlib work

vlog -sv ./lifo_if.sv
vlog -sv ./lifo_package.sv
vlog -sv ./lifo_tb.sv


vsim -novopt lifo_tb
add log -r /*

add wave -radix unsigned -r /lifo_tb/lifo_ins/*

run -all