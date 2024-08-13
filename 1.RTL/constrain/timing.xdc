create_clock -period 4.000 -name clk -waveform {0.000 2.000} [get_ports clk]
create_clock -period 4.000 -name clk -waveform {0.000 2.000} [get_ports S_AXI_ACLK]
create_clock -period 4.000 -name clk -waveform {0.000 2.000} [get_ports M_AXI_ACLK]

set_multicycle_path 2 -setup -from [get_pins {u_axi_full_core/fifo_is_full_reg[*]/C}] -to [get_pins {u_axi_full_core/block_is_busy_reg[*]/CE}]
set_multicycle_path 1 -holdup -from [get_pins {u_axi_full_core/fifo_is_full_reg[*]/C}] -to [get_pins {u_axi_full_core/block_is_busy_reg[*]/CE}]

set_multicycle_path 2 -setup -from [get_pins {u_axi_full_core/fifo_is_full_reg[*]/C}] -to [get_pins {u_axi_full_core/block_target_addr_reg[*][*]/CE}]
set_multicycle_path 1 -holdup -from [get_pins {u_axi_full_core/fifo_is_full_reg[*]/C}] -to [get_pins {u_axi_full_core/block_target_addr_reg[*][*]/CE}]

set_multicycle_path 2 -setup -from [get_pins {u_axi_full_core/fifo_is_full_reg[*]/C}] -to [get_pins {u_axi_full_core/block_is_busy_next_reg[*]/CE}]
set_multicycle_path 1 -holdup -from [get_pins {u_axi_full_core/fifo_is_full_reg[*]/C}] -to [get_pins {u_axi_full_core/block_is_busy_next_reg[*]/CE}]

