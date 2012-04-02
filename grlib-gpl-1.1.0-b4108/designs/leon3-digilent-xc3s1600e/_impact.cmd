setMode -bs
setMode -bs
setMode -bs
setMode -bs
addDevice -p 1 -file "/home/mike/grlib-gpl-1.1.0-b4108/designs/leon3-digilent-xc3s1600e/digilent-xc3s1600e.bit"
setCable -port auto
ReadStatusRegister -p 1 
ReadIdcode -p 1 
Verify -p 1 
ReadIdcode -p 1 
ReadStatusRegister -p 1 
setMode -bs
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
