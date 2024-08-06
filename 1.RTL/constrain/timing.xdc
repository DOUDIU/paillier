create_clock -period 4.080 -name clk -waveform {0.000 2.040} [get_ports clk]
create_clock -period 4.080 -name clk -waveform {0.000 2.040} [get_ports S_AXI_ACLK]
create_clock -period 4.080 -name clk -waveform {0.000 2.040} [get_ports M_AXI_ACLK]