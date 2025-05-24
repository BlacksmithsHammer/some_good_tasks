vlib work

vlog -sv ../rtl/calc_pkg.svh
vlog -sv ../rtl/calc.sv
vlog -sv ./top_tb.sv

vsim -voptargs="+acc" top_tb

do wave.do

run -all

exec python py_checker.py