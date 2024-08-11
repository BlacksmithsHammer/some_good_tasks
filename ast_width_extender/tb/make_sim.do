vlib work

vlog -sv ../rtl/ast_width_extender.sv
vlog -sv ./ast_we_if.sv
vlog -sv ./ast_we_package.sv
vlog -sv ./top_tb.sv

vsim -novopt top_tb

add log -r /*

add    wave -radix hex -r /*
delete wave            -r /top_tb/ast_we_ins/*

run -all