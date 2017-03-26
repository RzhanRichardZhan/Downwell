vlib work

vlog -timescale 1ns/1ns processor.v counter.v vga_demux.v wall.v

vsim processor
log {/*}

add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {resetn} 0
force {color_in[2]} 1
force {color_in[1]} 0
force {color_in[0]} 1
run 2
force {resetn} 1
run 10000