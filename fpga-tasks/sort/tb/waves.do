add wave                       /main_sort_tb/clk
add wave                       /main_sort_tb/srst

# add wave -color pink -unsigned /main_sort_tb/dut/ram_ins/ram
add wave             -unsigned /main_sort_tb/avst_if_i/data
add wave                       /main_sort_tb/avst_if_i/startofpacket
add wave                       /main_sort_tb/avst_if_i/endofpacket
add wave                       /main_sort_tb/avst_if_i/valid
add wave                       /main_sort_tb/avst_if_i/ready
# add wave                       /main_sort_tb/dut/src_valid_d

add wave             -unsigned /main_sort_tb/avst_if_o/data
add wave                       /main_sort_tb/avst_if_o/startofpacket
add wave                       /main_sort_tb/avst_if_o/endofpacket
add wave                       /main_sort_tb/avst_if_o/valid
add wave                       /main_sort_tb/avst_if_o/ready
# add wave                       /main_sort_tb/dut/state
# add wave                       /main_sort_tb/dut/start_sorting
# add wave -color blue           /main_sort_tb/dut/ins_sort/start_sorting_i

# add wave             -unsigned /main_sort_tb/dut/ins_sort/i
# add wave             -unsigned /main_sort_tb/dut/ins_sort/j
# add wave             -unsigned /main_sort_tb/dut/ins_sort/j_swap_d
# add wave             -unsigned /main_sort_tb/dut/ins_sort/j_value

# add wave             -unsigned /main_sort_tb/dut/ins_sort/q_a_i_reg
# add wave             -unsigned /main_sort_tb/dut/ins_sort/q_b_i_reg

# add wave             -unsigned /main_sort_tb/dut/ins_sort/q_a_i
# add wave             -unsigned /main_sort_tb/dut/ins_sort/q_b_i

# add wave             -unsigned /main_sort_tb/dut/ins_sort/we_a_o
# add wave             -unsigned /main_sort_tb/dut/ins_sort/we_b_o

# add wave             -unsigned /main_sort_tb/dut/ins_sort/need_swap
# add wave                       /main_sort_tb/dut/ins_sort/sort_state
# add wave                       /main_sort_tb/dut/ins_sort/change_i_d
# add wave  -r *