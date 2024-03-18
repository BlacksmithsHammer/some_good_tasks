vlib work

vlog -sv ../rtl/simple_counter.sv
vlog -sv ../rtl/bit_population_counter.sv
vlog -sv bit_population_counter_tb.sv

foreach width {8 24 32 64 128 256} {
   vsim -novopt -gWIDTH=$width bit_population_counter_tb
   run -all
}

# vsim -novopt -gWIDTH=8 bit_population_counter_tb
# add wave *
# run -all