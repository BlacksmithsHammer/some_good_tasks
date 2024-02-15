vlib work

vlog -sv ../rtl/serializer.sv
vlog -sv serializer_tb.sv

vsim -novopt top_tb

add log -r /*
add wave -r *
run -all
