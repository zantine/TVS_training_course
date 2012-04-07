onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/clk
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/clr_fifo
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/rd_fifo
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/wr_fifo
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/data_in
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/data_out
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/data_counter
add wave -noupdate -radix symbolic /testbench/d3/gpio0/grgpio0/data_fifo/data_out_valid
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/empty
add wave -noupdate /testbench/d3/gpio0/grgpio0/data_fifo/full
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/nxt_wr
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/data_fifo/nxt_rd
add wave -noupdate /testbench/d3/gpio0/grgpio0/rst
add wave -noupdate /testbench/d3/gpio0/grgpio0/apbi.psel(11)
add wave -noupdate /testbench/d3/gpio0/grgpio0/apbi.penable
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/apbi.paddr
add wave -noupdate /testbench/d3/gpio0/grgpio0/apbi.pwrite
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/apbo.prdata
add wave -noupdate -radix hexadecimal /testbench/d3/gpio0/grgpio0/gpioo.dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {247171000 ps} 0}
configure wave -namecolwidth 302
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
WaveRestoreZoom {247051471 ps} {247290529 ps}
