vlib work

vlog -sv ../rtl/sc_ram.sv
vlog -sv ../rtl/fifo.sv
vlog -sv altera_dev_family.sv
vlog -sv fifo_ref.sv
vlog -sv fifo_tb.sv


if [batch_mode] {
  coverage attribute -name TESTSTATUS

  onbreak {
    if { [coverage attribute -name TESTSTATUS -concise] > 1 } { 
      echo_err "Have erros in test!"
      if [batch_mode] { quit -f -code 2 } 
    }   
    resume
  }
  #vsim -wlf none 
  #check every mode
  vsim -do "run -all" -gREGISTER_OUTPUT=0 -gSHOWAHEAD=0 fifo_tb
  vsim -do "run -all" -gREGISTER_OUTPUT=1 -gSHOWAHEAD=0 fifo_tb
  vsim -do "run -all" -gREGISTER_OUTPUT=0 -gSHOWAHEAD=1 fifo_tb
  vsim -do "run -all" -gREGISTER_OUTPUT=1 -gSHOWAHEAD=1 fifo_tb


} else {
  vsim -novopt fifo_tb

  # add log -r  /fifo_tb/*
  # add wave -r /fifo_tb/*

  add wave /fifo_tb/clk
  add wave /fifo_tb/srst

  # add wave -color blue -radix hex /fifo_tb/DUT/ram_ins/genblk1/data_reg
  # add wave -color blue -radix hex /fifo_tb/DUT/ram_ins/data_o

  add wave -color yellow /fifo_tb/wrreq
  add wave -color yellow /fifo_tb/rdreq

  add wave -color pink -radix hex /fifo_tb/DUT/q_o
  add wave -color pink -radix hex /fifo_tb/GOLDEN/q

  add wave -radix hex             /fifo_tb/DUT/ram_ins/mem
  add wave -radix hex             /fifo_tb/GOLDEN/mem_data

  add wave -radix unsigned        /fifo_tb/DUT/usedw_o
  add wave -radix unsigned        /fifo_tb/GOLDEN/usedw

  add wave                        /fifo_tb/DUT/full_o
  add wave                        /fifo_tb/GOLDEN/full

  add wave                        /fifo_tb/DUT/empty_o
  add wave                        /fifo_tb/GOLDEN/empty

  add wave                        /fifo_tb/DUT/almost_empty_o
  add wave                        /fifo_tb/GOLDEN/almost_empty

  add wave                        /fifo_tb/DUT/almost_full_o
  add wave                        /fifo_tb/GOLDEN/almost_full

  add wave  -radix unsigned       /fifo_tb/DUT/*

  run -all
}
