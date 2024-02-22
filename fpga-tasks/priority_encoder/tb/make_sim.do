vlib work

vlog -sv ../rtl/priority_encoder.sv
vlog -sv priority_encoder_tb.sv

vsim -novopt priority_encoder_tb

add log -r /*
add wave -r *
run -all