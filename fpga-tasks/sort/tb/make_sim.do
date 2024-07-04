vlib work

if [batch_mode] { onerror { quit -f -code 2 } }
vlog -sv ../rtl/main_sort.sv
vlog -sv ../rtl/true_dual_port_scram.sv
vlog -sv ../rtl/insertion_sort.sv
vlog -sv main_sort_tb.sv

set PARAM_LIST { " " }
if [batch_mode] {
  set PARAM_LIST {
    "-gDWIDTH=8  -gMAX_PKT_LEN=8"
    "-gDWIDTH=8  -gMAX_PKT_LEN=16"
    "-gDWIDTH=16 -gMAX_PKT_LEN=8"
    "-gDWIDTH=16 -gMAX_PKT_LEN=16"
    "-gDWIDTH=32 -gMAX_PKT_LEN=8"
    "-gDWIDTH=32 -gMAX_PKT_LEN=16"
  }
} else {
  set PARAM_LIST {
    "-gDWIDTH=8 -gMAX_PKT_LEN=16"
  }
}

foreach params $PARAM_LIST {

  eval "vsim $params -novopt main_sort_tb"

  if ![batch_mode] { do waves.do }

  when {$now = @300 ms} {
    echo_err "Simulation timeout $now!"
    if [batch_mode] { quit -f -code 2 } 
    stop
  }

  coverage attribute -name TESTSTATUS

  onbreak {
    if { [coverage attribute -name TESTSTATUS -concise] > 1 } { 
      echo_err "Have erros in test!"
      if [batch_mode] { quit -f -code 2 } 
    }   
    resume
  }

  run -all
  echo "Finish run with parameters override $params."
}

if [batch_mode] { quit -f }