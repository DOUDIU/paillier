`ifndef AXI_IF_SV
`define AXI_IF_SV
    interface tvip_axi_if (
        input var AXI_ACLK,
        input var AXI_ARESETN
    );

    import  tvip_axi_types_pkg::*;

    //  Write Address Channel
    logic                 AXI_AWVALID   ;
    logic                 AXI_AWREADY   ;
    tvip_axi_id           AXI_AWID      ;
    tvip_axi_address      AXI_AWADDR    ;
    tvip_axi_burst_length AXI_AWLEN     ;
    tvip_axi_burst_size   AXI_AWSIZE    ;
    tvip_axi_burst_type   AXI_AWBURST   ;
    tvip_axi_write_cache  AXI_AWCACHE   ;
    tvip_axi_protection   AXI_AWPROT    ;
    tvip_axi_qos          AXI_AWQOS     ;
    // AXI_AWLOCK
    // AXI_AWUSER

    //  Write Data Channel
    logic                 AXI_WVALID    ;
    logic                 AXI_WREADY    ;
    tvip_axi_data         AXI_WDATA     ;
    tvip_axi_strobe       AXI_WSTRB     ;
    logic                 AXI_WLAST     ;
    // AXI_WUSER
    
    //  Write Response Channel
    logic                 AXI_BVALID    ;
    logic                 AXI_BREADY    ;
    tvip_axi_id           AXI_BID       ;
    tvip_axi_response     AXI_BRESP     ;
    // AXI_BUSER

    //  Read Address Channel
    logic                 AXI_ARVALID   ;
    logic                 AXI_ARREADY   ;
    tvip_axi_id           AXI_ARID      ;
    tvip_axi_address      AXI_ARADDR    ;
    tvip_axi_burst_length AXI_ARLEN     ;
    tvip_axi_burst_size   AXI_ARSIZE    ;
    tvip_axi_burst_type   AXI_ARBURST   ;
    tvip_axi_read_cache   AXI_ARCACHE   ;
    tvip_axi_protection   AXI_ARPROT    ;
    tvip_axi_qos          AXI_ARQOS     ;
    // AXI_ARLOCK
    // AXI_ARUSER

    //  Read Data Channel
    logic                 AXI_RVALID    ;
    logic                 AXI_RREADY    ;
    tvip_axi_id           AXI_RID       ;
    tvip_axi_data         AXI_RDATA     ;
    tvip_axi_response     AXI_RRESP     ;
    logic                 AXI_RLAST     ;
    // AXI_RUSER



endinterface

`endif