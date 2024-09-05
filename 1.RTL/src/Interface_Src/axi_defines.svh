`ifndef AXI_DEFINES_SVH
`define AXI_DEFINES_SVH

    `ifndef AXI_ID_WIDTH
        `define AXI_ID_WIDTH 32
    `endif

    `ifndef AXI_ADDR_WIDTH
        `define AXI_ADDR_WIDTH  36
    `endif

    `ifndef AXI_DATA_WIDTH
        `define AXI_DATA_WIDTH 256
    `endif

    `ifndef AXI_BURST_LEN
        // Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
        `define AXI_BURST_LEN 16
    `endif

    `ifndef AXI_LITE_ADDR_WIDTH
        `define AXI_LITE_ADDR_WIDTH  4
    `endif

    `ifndef AXI_LITE_DATA_WIDTH
        `define AXI_LITE_DATA_WIDTH 32
    `endif

    `define Vivado_Sim
`endif
