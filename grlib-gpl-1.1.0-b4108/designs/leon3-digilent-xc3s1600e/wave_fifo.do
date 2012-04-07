onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/clk
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/clr_fifo
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/rd_fifo
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/wr_fifo
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/data_in
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/data_out
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/fifo_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {247715246 ps} 0}
configure wave -namecolwidth 313
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {247715246 ps} {248571635 ps}
