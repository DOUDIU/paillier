module axi_rsa2048_top #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of ID for for write address, write data, read address and read data
    parameter integer C_S_AXI_ID_WIDTH	= 1,
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH	= 32,
    // Width of optional user defined signal in write address channel
    parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
    // Width of optional user defined signal in read address channel
    parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
    // Width of optional user defined signal in write data channel
    parameter integer C_S_AXI_WUSER_WIDTH	= 0,
    // Width of optional user defined signal in read data channel
    parameter integer C_S_AXI_RUSER_WIDTH	= 0,
    // Width of optional user defined signal in write response channel
    parameter integer C_S_AXI_BUSER_WIDTH	= 0
)(
    // Users to add ports here

    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write Address ID
    input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
    // Write address
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Burst length. The burst length gives the exact number of transfers in a burst
    input wire [7 : 0] S_AXI_AWLEN,
    // Burst size. This signal indicates the size of each transfer in the burst
    input wire [2 : 0] S_AXI_AWSIZE,
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    input wire [1 : 0] S_AXI_AWBURST,
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    input wire  S_AXI_AWLOCK,
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    input wire [3 : 0] S_AXI_AWCACHE,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Quality of Service, QoS identifier sent for each
    // write transaction.
    input wire [3 : 0] S_AXI_AWQOS,
    // Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
    input wire [3 : 0] S_AXI_AWREGION,
    // Optional User-defined signal in the write address channel.
    input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
    // Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
    output wire  S_AXI_AWREADY,
    // Write Data
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write last. This signal indicates the last transfer
    // in a write burst.
    input wire  S_AXI_WLAST,
    // Optional User-defined signal in the write data channel.
    input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire  S_AXI_WREADY,
    // Response ID tag. This signal is the ID tag of the
    // write response.
    output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Optional User-defined signal in the write response channel.
    output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
    // Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address ID. This signal is the identification
    // tag for the read address group of signals.
    input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
    // Read address. This signal indicates the initial
    // address of a read burst transaction.
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Burst length. The burst length gives the exact number of transfers in a burst
    input wire [7 : 0] S_AXI_ARLEN,
    // Burst size. This signal indicates the size of each transfer in the burst
    input wire [2 : 0] S_AXI_ARSIZE,
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    input wire [1 : 0] S_AXI_ARBURST,
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    input wire  S_AXI_ARLOCK,
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    input wire [3 : 0] S_AXI_ARCACHE,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Quality of Service, QoS identifier sent for each
    // read transaction.
    input wire [3 : 0] S_AXI_ARQOS,
    // Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
    input wire [3 : 0] S_AXI_ARREGION,
    // Optional User-defined signal in the read address channel.
    input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
    // Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
    output wire  S_AXI_ARREADY,
    // Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
    output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
    // Read Data
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of
    // the read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read last. This signal indicates the last transfer
    // in a read burst.
    output wire  S_AXI_RLAST,
    // Optional User-defined signal in the read address channel.
    output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
    // Read valid. This signal indicates that the channel
    // is signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire  S_AXI_RREADY
);
    //--------------------------------------------------------
    localparam FIFO_AW      = 7           ;//memory size = 2*(K*N/32)
    localparam K            = 128         ;
    localparam N            = 16          ;
    localparam ADDR_BASE    = 32'h78000000;
    //--------------------------------------------------------
    wire                        fwd_wr_rdy  ;
    wire                        fwd_wr_vld  ;
    wire [31        :   0]      fwd_wr_dat  ;
    wire                        fwd_rd_rdy  ;
    wire                        fwd_rd_vld  ;
    wire [31        :   0]      fwd_rd_dat  ;
    wire                        fwd_full    ;
    wire                        fwd_empty   ;
    wire [FIFO_AW   :   0]      fwd_cnt_rd  ;
    wire [FIFO_AW   :   0]      fwd_cnt_wr  ;
    wire                        bwd_rd_rdy  ;
    wire                        bwd_rd_vld  ;
    wire [31        :   0]      bwd_rd_dat  ;
    wire                        bwd_wr_rdy  ;
    wire                        bwd_wr_vld  ;
    wire [31        :   0]      bwd_wr_dat  ;
    wire                        bwd_full    ;
    wire                        bwd_empty   ;
    wire [FIFO_AW   :   0]      bwd_cnt_rd  ;
    wire [FIFO_AW   :   0]      bwd_cnt_wr  ;
    wire                        rsa_start   ;
//----------------------------------------------------
// It handles AHB transaction as a slave.
// Two registers are used to store the state of the rsa2048 module
// master write to register 0 to start the rsa2048 module, default: 0x0000_0000
// slave write to register 1 to indicate the rsa2048 module is done, default: 0x0000_0000


//----------------------------------------------------
// It handles AHB transaction as a slave.
// It pushes request information to the forward FIFO.
// It pops response information from the backwoard FIFO.
axi2fifo_slave_core #(  
        .FIFO_AW                (FIFO_AW                )
    ,   .ADDR_BASE              (ADDR_BASE              )
    ,   .K                      (K                      )
    ,   .N                      (N                      )

    ,   .C_S_AXI_ID_WIDTH       (C_S_AXI_ID_WIDTH       )
    ,   .C_S_AXI_DATA_WIDTH     (C_S_AXI_DATA_WIDTH     )
    ,   .C_S_AXI_ADDR_WIDTH     (C_S_AXI_ADDR_WIDTH     )
    ,   .C_S_AXI_AWUSER_WIDTH   (C_S_AXI_AWUSER_WIDTH   )
    ,   .C_S_AXI_ARUSER_WIDTH   (C_S_AXI_ARUSER_WIDTH   )
    ,   .C_S_AXI_WUSER_WIDTH    (C_S_AXI_WUSER_WIDTH    )
    ,   .C_S_AXI_RUSER_WIDTH    (C_S_AXI_RUSER_WIDTH    )
    ,   .C_S_AXI_BUSER_WIDTH    (C_S_AXI_BUSER_WIDTH    )
) axi2fifo_slave_core_inst (
        .S_AXI_ACLK             (S_AXI_ACLK             )
    ,   .S_AXI_ARESETN          (S_AXI_ARESETN          )

    ,   .S_AXI_AWID             (S_AXI_AWID             )
    ,   .S_AXI_AWADDR           (S_AXI_AWADDR           )
    ,   .S_AXI_AWLEN            (S_AXI_AWLEN            )
    ,   .S_AXI_AWSIZE           (S_AXI_AWSIZE           )
    ,   .S_AXI_AWBURST          (S_AXI_AWBURST          )
    ,   .S_AXI_AWLOCK           (S_AXI_AWLOCK           )
    ,   .S_AXI_AWCACHE          (S_AXI_AWCACHE          )
    ,   .S_AXI_AWPROT           (S_AXI_AWPROT           )
    ,   .S_AXI_AWQOS            (S_AXI_AWQOS            )
    ,   .S_AXI_AWREGION         (S_AXI_AWREGION         )//unconnected
    ,   .S_AXI_AWUSER           (S_AXI_AWUSER           )
    ,   .S_AXI_AWVALID          (S_AXI_AWVALID          )
    ,   .S_AXI_AWREADY          (S_AXI_AWREADY          )

    ,   .S_AXI_WDATA            (S_AXI_WDATA            )
    ,   .S_AXI_WSTRB            (S_AXI_WSTRB            )
    ,   .S_AXI_WLAST            (S_AXI_WLAST            )
    ,   .S_AXI_WUSER            (S_AXI_WUSER            )
    ,   .S_AXI_WVALID           (S_AXI_WVALID           )
    ,   .S_AXI_WREADY           (S_AXI_WREADY           )

    ,   .S_AXI_BID              (S_AXI_BID              )
    ,   .S_AXI_BRESP            (S_AXI_BRESP            )
    ,   .S_AXI_BUSER            (S_AXI_BUSER            )
    ,   .S_AXI_BVALID           (S_AXI_BVALID           )
    ,   .S_AXI_BREADY           (S_AXI_BREADY           )

    ,   .S_AXI_ARID             (S_AXI_ARID             )
    ,   .S_AXI_ARADDR           (S_AXI_ARADDR           )
    ,   .S_AXI_ARLEN            (S_AXI_ARLEN            )
    ,   .S_AXI_ARSIZE           (S_AXI_ARSIZE           )
    ,   .S_AXI_ARBURST          (S_AXI_ARBURST          )
    ,   .S_AXI_ARLOCK           (S_AXI_ARLOCK           )
    ,   .S_AXI_ARCACHE          (S_AXI_ARCACHE          )
    ,   .S_AXI_ARPROT           (S_AXI_ARPROT           )
    ,   .S_AXI_ARQOS            (S_AXI_ARQOS            )
    ,   .S_AXI_ARREGION         (S_AXI_ARREGION         )//unconnected
    ,   .S_AXI_ARUSER           (S_AXI_ARUSER           )
    ,   .S_AXI_ARVALID          (S_AXI_ARVALID          )
    ,   .S_AXI_ARREADY          (S_AXI_ARREADY          )

    ,   .S_AXI_RID              (S_AXI_RID              )
    ,   .S_AXI_RDATA            (S_AXI_RDATA            )
    ,   .S_AXI_RRESP            (S_AXI_RRESP            )
    ,   .S_AXI_RLAST            (S_AXI_RLAST            )
    ,   .S_AXI_RUSER            (S_AXI_RUSER            )
    ,   .S_AXI_RVALID           (S_AXI_RVALID           )
    ,   .S_AXI_RREADY           (S_AXI_RREADY           )

    ,   .fwr_clk                (                       )// output: should be S_AXI_ACLK
    ,   .fwr_rdy                (fwd_wr_rdy             )
    ,   .fwr_vld                (fwd_wr_vld             )
    ,   .fwr_dat                (fwd_wr_dat             )
    ,   .fwr_full               (fwd_full               )
    ,   .fwr_cnt                (fwd_cnt_wr             )// how many rooms available
    ,   .brd_clk                (                       )// output: should be S_AXI_ACLK
    ,   .brd_rdy                (bwd_rd_rdy             )
    ,   .brd_vld                (bwd_rd_vld             )
    ,   .brd_dat                (bwd_rd_dat             )
    ,   .brd_empty              (bwd_empty              )
    ,   .brd_cnt                (bwd_cnt_rd             )// how many items avilable
    ,   .rsa_start              (rsa_start              )
    ,   .rsa_finish             (bwd_cnt_rd == (K*N/32) )
);

//---------------------------------------------------
// read from slave, write to master
// control read salve fifo, write master fifo
fifo_rsa2048_ctrl #(
    32, 
    FIFO_AW
)u_fifo_rsa2048_ctrl(
        .rst        (~S_AXI_ARESETN         ) // asynchronous reset (active high)
    ,   .clr        (1'b0                   ) // synchronous reset (active high)
    ,   .clk        (S_AXI_ACLK             )
    ,   .rd_start   (rsa_start & (fwd_cnt_rd == (K*N/32)))
    ,   .rd_rdy     (fwd_rd_rdy             )
    ,   .rd_vld     (fwd_rd_vld             )
    ,   .rd_din     (fwd_rd_dat             )
    ,   .wr_rdy     (bwd_wr_rdy             )
    ,   .wr_vld     (bwd_wr_vld             )
    ,   .wr_dout    (bwd_wr_dat             )
);
   
//---------------------------------------------------
// from slave-to-master
// all address related information
ahb_fifo #(
    32,
    FIFO_AW
)Ufwd_fifo (
        .rst        (~S_AXI_ARESETN         )
    ,   .clr        (1'b0                   )
    ,   .clk        (S_AXI_ACLK             ) // it should be S_AXI_ACLK
    ,   .wr_rdy     (fwd_wr_rdy             )
    ,   .wr_vld     (fwd_wr_vld             )
    ,   .wr_din     (fwd_wr_dat             )
    ,   .rd_rdy     (fwd_rd_rdy             )
    ,   .rd_vld     (fwd_rd_vld             )
    ,   .rd_dout    (fwd_rd_dat             )
    ,   .empty      (fwd_empty              )
    ,   .full       (fwd_full               )
    ,   .fullN      ()
    ,   .emptyN     ()
    ,   .rd_cnt     (fwd_cnt_rd             ) // how many items
    ,   .wr_cnt     (fwd_cnt_wr             ) // how many rooms
);

//---------------------------------------------------
// from master-to-slave
// all data related information
ahb_fifo #(
    32, 
    FIFO_AW
)Ubwd_fifo (
        .rst        (~S_AXI_ARESETN         )
    ,   .clr        (1'b0                   )
    ,   .clk        (S_AXI_ACLK             ) // it should be S_AXI_ACLK
    ,   .wr_rdy     (bwd_wr_rdy             )
    ,   .wr_vld     (bwd_wr_vld             )
    ,   .wr_din     (bwd_wr_dat             )
    ,   .rd_rdy     (bwd_rd_rdy             )
    ,   .rd_vld     (bwd_rd_vld             )
    ,   .rd_dout    (bwd_rd_dat             )
    ,   .empty      (bwd_empty              )
    ,   .full       (bwd_full               )
    ,   .fullN      ()
    ,   .emptyN     ()
    ,   .rd_cnt     (bwd_cnt_rd             )
    ,   .wr_cnt     (bwd_cnt_wr             )
);





endmodule
