create_project -force -part $::env(XRAY_PART) design design
read_verilog top.v
synth_design -top top

set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_00) IOSTANDARD LVCMOS33" [get_ports clk]
set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_01) IOSTANDARD LVCMOS33" [get_ports stb]
set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_02) IOSTANDARD LVCMOS33" [get_ports di]
set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_03) IOSTANDARD LVCMOS33" [get_ports do]

create_pblock roi

add_cells_to_pblock [get_pblocks roi] [get_cells roi]
resize_pblock [get_pblocks roi] -add "$::env(XRAY_ROI)"

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.PERFRAMECRC YES [current_design]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]
# Disable MMCM frequency etc sanity checks
set_property IS_ENABLED 0 [get_drc_checks {PDRC-29}]
set_property IS_ENABLED 0 [get_drc_checks {PDRC-30}]
set_property IS_ENABLED 0 [get_drc_checks {AVAL-50}]
set_property IS_ENABLED 0 [get_drc_checks {AVAL-53}]
set_property IS_ENABLED 0 [get_drc_checks {REQP-126}]
# PLL
set_property IS_ENABLED 0 [get_drc_checks {REQP-161}]

place_design
route_design

write_checkpoint -force design.dcp
write_bitstream -force design.bit
