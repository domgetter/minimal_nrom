#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 

# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 

# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "clk50" -period 20.000ns [get_ports {clk50}]
create_clock -name "mcu_clk" -period 23.809ns [get_ports {mcu_clk}]
create_clock -name "m2" -period 558.730ns -waveform {209.524 558.730} [get_ports {m2}]


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints

# Input constraints


set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[0]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[1]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[2]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[3]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[4]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[5]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[6]}]

set_input_delay -clock { clk } -max 150 [get_ports {chr_dat[7]}]