create_clock -period 4.080 -name clk -waveform {0.000 2.040} [get_ports clk]
create_clock -period 4.080 -name clk -waveform {0.000 2.040} [get_ports S_AXI_ACLK]
create_clock -period 4.080 -name clk -waveform {0.000 2.040} [get_ports M_AXI_ACLK]

set_multicycle_path -from [get_pins {u_axi_full_core/block_is_busy_reg[4]/C}] -to [get_pins {u_axi_full_core/block_is_busy_reg[13]/CE}] 2
set_multicycle_path -from [get_pins {u_axi_full_core/block_is_busy_reg[*]/C}] -to [get_pins {u_axi_full_core/block_is_busy_reg[*]/CE}] 2

set _xlnx_shared_i0 [get_pins {u_axi_full_core/block_target_addr_reg[*][*]/CE}]
set_multicycle_path -from [get_pins {u_axi_full_core/block_is_busy_reg[*]/C}] -to $_xlnx_shared_i0 2
set_multicycle_path -from [get_pins {u_axi_full_core/block_is_busy_reg[*]/C}] -to [get_pins {u_axi_full_core/loop_counter_reg[*]/CE}] 2
