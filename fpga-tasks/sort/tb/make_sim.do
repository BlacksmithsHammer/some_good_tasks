vlib work

vlog -sv ../rtl/main_sort.sv
vlog -sv ../rtl/true_dual_port_scram.sv
vlog -sv ../rtl/insertion_sort.sv

vlog -sv main_sort_tb.sv

vsim -novopt main_sort_tb


add log -r /*
add wave                       /main_sort_tb/clk
add wave                       /main_sort_tb/srst

add wave -color pink -unsigned /main_sort_tb/dut/ram_ins/ram
add wave             -unsigned /main_sort_tb/dut_snk_data
add wave                       /main_sort_tb/dut_snk_startofpacket
add wave                       /main_sort_tb/dut_snk_endofpacket
add wave                       /main_sort_tb/dut_snk_valid
add wave                       /main_sort_tb/dut_snk_ready
add wave                       /main_sort_tb/dut/src_valid_d

add wave             -unsigned /main_sort_tb/dut_src_data
add wave                       /main_sort_tb/dut_src_startofpacket
add wave                       /main_sort_tb/dut_src_endofpacket
add wave                       /main_sort_tb/dut_src_valid
add wave                       /main_sort_tb/dut_src_ready
add wave                       /main_sort_tb/dut/state

add wave             -unsigned /main_sort_tb/dut/ins_sort/*
add wave -color blue           /main_sort_tb/dut/ins_sort/start_sorting_i

add wave  -r *
run -all