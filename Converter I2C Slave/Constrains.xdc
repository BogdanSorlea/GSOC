set_property SEVERITY {Warning} [get_drc_checks LUTLP-1]
set_property IOSTANDARD LVCMOS33 [get_ports clock]
set_property PACKAGE_PIN R4 [get_ports clock]
create_clock -name clk_in -period 10 -waveform {0 5} [get_ports clock]

#set_property ALLOW_COMBINATORIAL_LOOPS TRUE

set_property IOSTANDARD LVCMOS33 [get_ports SDA]
#set_property PACKAGE_PIN W7 - V8 [get_ports SDA]   #JB1
set_property LOC AB21 [get_ports SDA]

set_property IOSTANDARD LVCMOS33 [get_ports SCL]
#set_property PACKAGE_PIN V7 - Y9 [get_ports SCL]   #JB2
set_property LOC AB22 [get_ports SCL]

#set_property IOSTANDARD LVCMOS33 [get_ports {state[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {state[1]}]                                                   
#set_property IOSTANDARD LVCMOS33 [get_ports {state[2]}]

#set_property PACKAGE_PIN T14 [get_ports {state[0]}]
#set_property PACKAGE_PIN T15 [get_ports {state[1]}]
#set_property PACKAGE_PIN T16 [get_ports {state[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports test]
set_property LOC V8 [get_ports test]


set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[1]}]                                                   
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {addr_r[7]}]


set_property PACKAGE_PIN T14 [get_ports {addr_r[0]}]
set_property PACKAGE_PIN T15 [get_ports {addr_r[1]}]
set_property PACKAGE_PIN T16 [get_ports {addr_r[2]}]
set_property PACKAGE_PIN U16 [get_ports {addr_r[3]}]
set_property PACKAGE_PIN V15 [get_ports {addr_r[4]}]
set_property PACKAGE_PIN W16 [get_ports {addr_r[5]}]
set_property PACKAGE_PIN W15 [get_ports {addr_r[6]}]
set_property PACKAGE_PIN Y13 [get_ports {addr_r[7]}]
