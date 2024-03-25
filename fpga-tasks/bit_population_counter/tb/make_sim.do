vlib work

vlog -sv ../rtl/simple_counter.sv
vlog -sv ../rtl/bit_population_counter.sv
vlog -sv bit_population_counter_tb.sv

#8 24 32 64 128 256

set arr_widths { 256 }
if { [lindex $argv 1] == "-batch"} {
  set arr_widths { 8 24 32 64 128 256 }
}
set passed_tests 0

foreach width $arr_widths {
  vsim -voptargs="+acc=r+/bit_population_counter_tb/status_accuracy" -gWIDTH=$width bit_population_counter_tb
  #vsim -voptargs="+acc" -gWIDTH=$width bit_population_counter_tb
  #add log -r /*
  #add wave -r *
  run -all

  set result [examine -int /bit_population_counter_tb/status_accuracy]

  if {$result == "32'h00000000"} {
    echo "NOT ALL TESTS PASSED FOR WIDTH: $width"
    set passed_tests [expr {$passed_tests + 1}]
    break
  }

  set passed_tests [expr {$passed_tests + 1}]
}

echo "iteration: $passed_tests/[llength $arr_widths]"