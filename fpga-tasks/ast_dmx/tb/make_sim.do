vlib work

vlog -sv ../rtl/ast_dmx.sv
vlog -sv ./ast_dmx_if.sv
vlog -sv ./ast_dmx_package.sv
vlog -sv ./top_tb.sv

vsim -novopt top_tb

add log -r /*

do waves.do

run -all