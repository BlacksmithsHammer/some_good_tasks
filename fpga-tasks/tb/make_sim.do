vlib work

vlog -sv ../rtl/ast_dmx.sv
vlog -sv ./ast_dmx_if.sv
vlog -sv ./ast_dmx_package.sv
vlog -sv ./top_tb.sv






# ONE_BYTE
vsim -voptargs="+acc" -gTEST_CASE=0 -suppress 3839 top_tb

# ONE_BYTE_RAND_READY
# vsim -voptargs="+acc" -gTEST_CASE=0 -suppress 3839 top_tb

# MANY_BYTES_RAND_READY
# vsim -voptargs="+acc" -gTEST_CASE=0 -suppress 3839 top_tb

# SWAP_DIRS_RAND_READY
# vsim -voptargs="+acc" -gTEST_CASE=0 -suppress 3839 top_tb

# MAIN_TEST
# vsim -voptargs="+acc" -gTEST_CASE=0 -suppress 3839 top_tb

add log -r /*

do waves.do

run -all
