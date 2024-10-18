vlib work

vlog -sv ../rtl/byte_inc.sv
vlog -sv ./amm_if.sv
vlog -sv ./amm_byte_inc_set_if.sv
vlog -sv ./amm_byte_inc_package.sv
vlog -sv ./top_tb.sv

# MVP
vsim -voptargs="+acc" -gTEST_CASE=0 top_tb

# RANDOM_WAITREQUEST
# vsim -voptargs="+acc" -gTEST_CASE=1 top_tb

# STATIC_WAITREQUEST
# vsim -voptargs="+acc" -gTEST_CASE=2 top_tb

# OVERSIZE_LENGTH
# vsim -voptargs="+acc" -gTEST_CASE=3 top_tb

# MAX_LATENCY
# vsim -voptargs="+acc" -gTEST_CASE=4 top_tb

# BIG_TEST
# vsim -voptargs="+acc" -gTEST_CASE=5 top_tb

add log -r /*

do waves.do

run -all
