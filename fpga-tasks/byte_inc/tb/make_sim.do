vlib work

vlog -sv ../rtl/byte_inc.sv
vlog -sv ./amm_if.sv
vlog -sv ./amm_byte_inc_set_if.sv
vlog -sv ./amm_byte_inc_package.sv
vlog -sv ./top_tb.sv

vsim -voptargs="+acc" -gTEST_CASE=0 top_tb


add log -r /*

do waves.do

run -all
