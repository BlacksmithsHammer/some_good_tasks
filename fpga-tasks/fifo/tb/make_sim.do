vlib work

vlog -sv ../rtl/sc_ram.sv
vlog -sv ../rtl/fifo.sv
vlog -sv altera_dev_family.sv
vlog -sv fifo_ref.sv
vlog -sv fifo_tb.sv

vsim -novopt fifo_tb

# add log -r  /fifo_tb/*
# add wave -r /fifo_tb/*

add wave /fifo_tb/clk
add wave /fifo_tb/srst


#add wave -color blue -radix hex /fifo_tb/DUT/ram_ins/genblk1/data_reg
#add wave -color blue -radix hex /fifo_tb/DUT/ram_ins/data_o

add wave -color yellow /fifo_tb/wrreq
add wave -color yellow /fifo_tb/rdreq

add wave -color pink -radix hex /fifo_tb/DUT/q_o
add wave -color pink -radix hex /fifo_tb/DUT_reg/q_o
add wave -color pink -radix hex /fifo_tb/golden/q
# add wave -color pink -radix hex /fifo_tb/golden_show/q
add wave -color pink -radix hex /fifo_tb/golden_reg/q
# add wave -color pink -radix hex /fifo_tb/golden_show_reg/q

add wave -radix hex             /fifo_tb/DUT/ram_ins/mem
add wave -radix hex             /fifo_tb/DUT_reg/ram_ins/mem
add wave -radix hex             /fifo_tb/golden/mem_data
# add wave -radix hex             /fifo_tb/golden_show/mem_data
add wave -radix hex             /fifo_tb/golden_reg/mem_data
# add wave -radix hex             /fifo_tb/golden_show_reg/mem_data

add wave -radix unsigned        /fifo_tb/DUT/usedw_o
add wave -radix unsigned        /fifo_tb/DUT_reg/usedw_o
add wave -radix unsigned        /fifo_tb/golden/usedw
# add wave -radix unsigned        /fifo_tb/golden_show/usedw
add wave -radix unsigned        /fifo_tb/golden_reg/usedw
# add wave -radix unsigned        /fifo_tb/golden_show_reg/usedw

add wave                        /fifo_tb/DUT/full_o
add wave                        /fifo_tb/DUT_reg/full_o
add wave                        /fifo_tb/golden/full
# add wave                        /fifo_tb/golden_show/full
add wave                        /fifo_tb/golden_reg/full
# add wave                        /fifo_tb/golden_show_reg/full

add wave                        /fifo_tb/DUT/empty_o
add wave                        /fifo_tb/DUT_reg/empty_o
add wave                        /fifo_tb/golden/empty
# add wave                        /fifo_tb/golden_show/empty
add wave                        /fifo_tb/golden_reg/empty
# add wave                        /fifo_tb/golden_show_reg/empty

run -all