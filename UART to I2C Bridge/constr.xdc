lset_property SEVERITY {Warning} [get_drc_checks LUTLP-1]
set_property IOSTANDARD LVCMOS33 [get_ports clock]
set_property PACKAGE_PIN R4 [get_ports clock]
create_clock -name clk_in -period 10 -waveform {0 5} [get_ports clock]

#set_property ALLOW_COMBINATORIAL_LOOPS TRUE

set_property IOSTANDARD LVCMOS33 [get_ports TX]
set_property PACKAGE_PIN AA19 [get_ports TX]

set_property IOSTANDARD LVCMOS33 [get_ports RX]
set_property PACKAGE_PIN V18 [get_ports RX]

set_property IOSTANDARD LVCMOS33 [get_ports SDA]
#set_property PACKAGE_PIN W7 - V8 [get_ports SDA]   #JB1
set_property LOC V8 [get_ports SDA]

set_property IOSTANDARD LVCMOS33 [get_ports SCL]
#set_property PACKAGE_PIN V7 - Y9 [get_ports SCL]   #JB2
set_property LOC Y9 [get_ports SCL]


set_property IOSTANDARD LVCMOS33 [get_ports {state[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[1]}]                                                   
set_property IOSTANDARD LVCMOS33 [get_ports {state[2]}]


set_property PACKAGE_PIN T14 [get_ports {state[0]}]
set_property PACKAGE_PIN T15 [get_ports {state[1]}]
set_property PACKAGE_PIN T16 [get_ports {state[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {state_i2c[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state_i2c[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state_i2c[2]}]

set_property PACKAGE_PIN W16 [get_ports {state_i2c[0]}]
set_property PACKAGE_PIN W15 [get_ports {state_i2c[1]}]
set_property PACKAGE_PIN Y13 [get_ports {state_i2c[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports DAC_update]
set_property PACKAGE_PIN W9 [get_ports DAC_update]

set_property IOSTANDARD LVCMOS33 [get_ports pwm]
set_property PACKAGE_PIN Y8 [get_ports pwm]

set_property IOSTANDARD LVCMOS33 [get_ports fb]
set_property PACKAGE_PIN V7 [get_ports fb]

set_property IOSTANDARD LVCMOS33 [get_ports en]
set_property PACKAGE_PIN W7 [get_ports en]

set_property IOSTANDARD LVCMOS33 [get_ports fb_out]
set_property PACKAGE_PIN Y6 [get_ports fb_out]

set_property IOSTANDARD LVCMOS33 [get_ports fb_out_unaveraged]
set_property PACKAGE_PIN AA6 [get_ports fb_out_unaveraged]

set_property IOSTANDARD LVCMOS33 [get_ports test]
set_property PACKAGE_PIN AA8 [get_ports test]