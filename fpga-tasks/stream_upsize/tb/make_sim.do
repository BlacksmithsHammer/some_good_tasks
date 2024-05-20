vlib work

vlog -sv ../rtl/stream_upsize.sv
vlog -sv stream_upsize_tb.sv



vsim -novopt stream_upsize_tb

add log -r /*

add wave -r *
#add wave -hexadecimal /stream_upsize_tb/stream_ins/data
add wave -hexadecimal /stream_upsize_tb/m_data
add wave              /stream_upsize_tb/m_valid
add wave -hexadecimal /stream_upsize_tb/s_data
run -all