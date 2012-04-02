onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb/DUV/DATA_WIDTH
add wave -noupdate -format Literal /tb/DUV/PTR_WIDTH
add wave -noupdate -format Logic /tb/DUV/clk
add wave -noupdate -color White -format Logic -itemcolor White /tb/DUV/clear
add wave -noupdate -color Orchid -format Logic -itemcolor Orchid /tb/DUV/wr
add wave -noupdate -color Orchid -format Literal -itemcolor Orchid -radix unsigned /tb/DUV/data_in
add wave -noupdate -color Orchid -format Literal -itemcolor Orchid -radix unsigned /tb/DUV/nxt_wr
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /tb/DUV/rd
add wave -noupdate -color Cyan -format Literal -itemcolor Cyan -radix unsigned /tb/DUV/data_out
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan /tb/DUV/data_out_valid
add wave -noupdate -color Cyan -format Literal -itemcolor Cyan -radix unsigned /tb/DUV/nxt_rd
add wave -noupdate -color {Indian Red} -format Literal -itemcolor {Indian Red} /tb/DUV/FIFO_DEPTH
add wave -noupdate -color {Indian Red} -format Literal -itemcolor {Indian Red} -radix unsigned /tb/DUV/data_counter
add wave -noupdate -color Gold -format Logic -itemcolor Gold /tb/DUV/empty
add wave -noupdate -color Gold -format Logic -itemcolor Gold /tb/DUV/full
add wave -noupdate -format Literal -radix unsigned -expand /tb/DUV/data_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {54 ns} 0}
configure wave -namecolwidth 229
configure wave -valuecolwidth 121
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
WaveRestoreZoom {0 ns} {152 ns}
