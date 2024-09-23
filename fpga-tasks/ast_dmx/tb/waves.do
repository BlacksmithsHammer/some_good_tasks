add    wave  -radix hex                   /top_tb/_sink_if/clk
add    wave  -radix hex                   /top_tb/srst
add    wave  -radix hex                   /top_tb/_sink_if/cb/ready

add    wave  -radix hex                   -r {/top_tb/_sink_if/cbo/*}
delete wave                               /top_tb/_sink_if/cbo/ready

# add    wave  -radix hex                   -r /top_tb/dut/*
# add    wave  -radix hex                   -r /*

add    wave  -radix hex  -color yellow    -r {/top_tb/_source_if[0]/cb/ready}
add    wave  -radix hex  -color yellow    -r {/top_tb/_source_if[0]/cbo/*}

add    wave  -radix hex  -color orange    -r {/top_tb/_source_if[1]/cb/ready}
add    wave  -radix hex  -color orange    -r {/top_tb/_source_if[1]/cbo/*}

add    wave  -radix hex  -color yellow    -r {/top_tb/_source_if[2]/cb/ready}
add    wave  -radix hex  -color yellow    -r {/top_tb/_source_if[2]/cbo/*}

add    wave  -radix hex  -color orange    -r {/top_tb/_source_if[3]/cb/ready}
add    wave  -radix hex  -color orange    -r {/top_tb/_source_if[3]/cbo/*}
