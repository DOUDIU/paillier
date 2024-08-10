`ifndef AXI_FULL_DEFINES_SVH
`define AXI_FULL_DEFINES_SVH

    `ifndef TVIP_AXI_MAX_ID_WIDTH
        `define TVIP_AXI_MAX_ID_WIDTH 32
    `endif

    `ifndef TVIP_AXI_MAX_ADDRESS_WIDTH
        `define TVIP_AXI_MAX_ADDRESS_WIDTH  36
    `endif

    `ifndef TVIP_AXI_MAX_DATA_WIDTH
        `define TVIP_AXI_MAX_DATA_WIDTH 128
    `endif

    `ifndef TVIP_AXI_BURST_LEN
        // Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
        `define TVIP_AXI_BURST_LEN 32
    `endif

    `ifndef TVIP_AXI_LITE_MAX_ADDRESS_WIDTH
        `define TVIP_AXI_LITE_MAX_ADDRESS_WIDTH  4
    `endif

    `ifndef TVIP_AXI_LITE_MAX_DATA_WIDTH
        `define TVIP_AXI_LITE_MAX_DATA_WIDTH 32
    `endif


`endif
