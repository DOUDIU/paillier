module interface_translation#(
// Users to add parameters here
        parameter BLOCK_COUNT   = 1
	,	parameter K             = 128
    ,   parameter N             = 32
//----------------------------------------------------
// parameter of AXI-FULL slave port
		// Base address of targeted slave
	,   parameter  TARGET_RD_ADDR = 0_0000_0000
	,   parameter  TARGET_WR_ADDR = 0_0000_0000
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	,   parameter integer C_M_AXI_BURST_LEN	= 32
		// Thread ID Width
	,   parameter integer C_M_AXI_ID_WIDTH	= 1
		// Width of Address Bus
	,   parameter integer C_M_AXI_ADDR_WIDTH	= 64
		// Width of Data Bus
	,   parameter integer C_M_AXI_DATA_WIDTH	= 128
		// Width of User Write Address Bus
	,   parameter integer C_M_AXI_AWUSER_WIDTH	= 0
		// Width of User Read Address Bus
	,   parameter integer C_M_AXI_ARUSER_WIDTH	= 0
		// Width of User Write Data Bus
	,   parameter integer C_M_AXI_WUSER_WIDTH	= 0
		// Width of User Read Data Bus
	,   parameter integer C_M_AXI_RUSER_WIDTH	= 0
		// Width of User Response Bus
	,   parameter integer C_M_AXI_BUSER_WIDTH	= 0
//----------------------------------------------------
// parameter of AXI-LITE slave port
		// Width of S_AXI data bus
	,   parameter integer C_S_AXI_DATA_WIDTH	= 32
		// Width of S_AXI address bus
	,	parameter integer C_S_AXI_ADDR_WIDTH	= 4
)(

//----------------------------------------------------
// AXI-LITE slave port
    // Global Clock Signal
        input wire  S_AXI_ACLK
    // Global Reset Signal. This Signal is Active LOW
    ,   input wire  S_AXI_ARESETN
    // Write address (issued by master, acceped by Slave)
    ,   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    ,   input wire [2 : 0] S_AXI_AWPROT
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    ,   input wire  S_AXI_AWVALID
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    ,   output wire  S_AXI_AWREADY
    // Write data (issued by master, acceped by Slave) 
    ,   input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    ,   input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    ,   input wire  S_AXI_WVALID
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    ,   output wire  S_AXI_WREADY
    // Write response. This signal indicates the status
        // of the write transaction.
    ,   output wire [1 : 0] S_AXI_BRESP
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    ,   output wire  S_AXI_BVALID
    // Response ready. This signal indicates that the master
        // can accept a write response.
    ,   input wire  S_AXI_BREADY
    // Read address (issued by master, acceped by Slave)
    ,   input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    ,   input wire [2 : 0] S_AXI_ARPROT
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    ,   input wire  S_AXI_ARVALID
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    ,   output wire  S_AXI_ARREADY
    // Read data (issued by slave)
    ,   output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA
    // Read response. This signal indicates the status of the
        // read transfer.
    ,   output wire [1 : 0] S_AXI_RRESP
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    ,   output wire  S_AXI_RVALID
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    ,   input wire  S_AXI_RREADY

//----------------------------------------------------
// AXI-FULL master port
    // Global Clock Signal.
    ,   input wire  M_AXI_ACLK
    // Global Reset Singal. This Signal is Active Low
    ,   input wire  M_AXI_ARESETN

    //----------------Write Address Channel----------------//
    // Master Interface Write Address ID
    ,   output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID
    // Master Interface Write Address
    ,   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR
    // Burst length. The burst length gives the exact number of transfers in a burst
    ,   output wire [7 : 0] M_AXI_AWLEN
    // Burst size. This signal indicates the size of each transfer in the burst
    ,   output wire [2 : 0] M_AXI_AWSIZE
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    ,   output wire [1 : 0] M_AXI_AWBURST
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    ,   output wire  M_AXI_AWLOCK
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    ,   output wire [3 : 0] M_AXI_AWCACHE
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    ,   output wire [2 : 0] M_AXI_AWPROT
    // Quality of Service, QoS identifier sent for each write transaction.
    ,   output wire [3 : 0] M_AXI_AWQOS
    // Optional User-defined signal in the write address channel.
    ,   output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER
    // Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
    ,   output wire  M_AXI_AWVALID
    // Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
    ,   input wire  M_AXI_AWREADY

    //----------------Write Data Channel----------------//
    // Master Interface Write Data.
    ,   output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA
    // Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
    ,   output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB
    // Write last. This signal indicates the last transfer in a write burst.
    ,   output wire  M_AXI_WLAST
    // Optional User-defined signal in the write data channel.
    ,   output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER
    // Write valid. This signal indicates that valid write
    // data and strobes are available
    ,   output wire  M_AXI_WVALID
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    ,   input wire  M_AXI_WREADY

    //----------------Write Response Channel----------------//
    // Master Interface Write Response.
    ,   input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID
    // Write response. This signal indicates the status of the write transaction.
    ,   input wire [1 : 0] M_AXI_BRESP
    // Optional User-defined signal in the write response channel
    ,   input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER
    // Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
    ,   input wire  M_AXI_BVALID
    // Response ready. This signal indicates that the master
    // can accept a write response.
    ,   output wire  M_AXI_BREADY

    //----------------Read Address Channel----------------//
    // Master Interface Read Address.
    ,   output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID
    // Read address. This signal indicates the initial
    // address of a read burst transaction.
    ,   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR
    // Burst length. The burst length gives the exact number of transfers in a burst
    ,   output wire [7 : 0] M_AXI_ARLEN
    // Burst size. This signal indicates the size of each transfer in the burst
    ,   output wire [2 : 0] M_AXI_ARSIZE
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    ,   output wire [1 : 0] M_AXI_ARBURST
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    ,   output wire  M_AXI_ARLOCK
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    ,   output wire [3 : 0] M_AXI_ARCACHE
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    ,   output wire [2 : 0] M_AXI_ARPROT
    // Quality of Service, QoS identifier sent for each read transaction
    ,   output wire [3 : 0] M_AXI_ARQOS
    // Optional User-defined signal in the read address channel.
    ,   output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER
    // Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
    ,   output wire  M_AXI_ARVALID
    // Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
    ,   input wire  M_AXI_ARREADY

    //----------------Read Data Channel----------------//
    // Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
    ,   input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID
    // Master Read Data
    ,   input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA
    // Read response. This signal indicates the status of the read transfer
    ,   input wire [1 : 0] M_AXI_RRESP
    // Read last. This signal indicates the last transfer in a read burst
    ,   input wire  M_AXI_RLAST
    // Optional User-defined signal in the read address channel.
    ,   input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER
    // Read valid. This signal indicates that the channel
    // is signaling the required read data.
    ,   input wire  M_AXI_RVALID
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    ,   output wire  M_AXI_RREADY


);

tvip_axi_if AXI_FULL_IF(M_AXI_ACLK, M_AXI_ARESETN);
tvip_axi_if AXI_LITE_IF(S_AXI_ACLK, S_AXI_ARESETN);

//----------------------------------------------------
// AXI-FULL master port
    //----------------Write Address Channel----------------//
    assign  M_AXI_AWID                  =   AXI_FULL_IF.AXI_AWID        ;
    assign  M_AXI_AWADDR                =   AXI_FULL_IF.AXI_AWADDR      ;
    assign  M_AXI_AWLEN                 =   AXI_FULL_IF.AXI_AWLEN       ;
    assign  M_AXI_AWSIZE                =   AXI_FULL_IF.AXI_AWSIZE      ;
    assign  M_AXI_AWBURST               =   AXI_FULL_IF.AXI_AWBURST     ;
    assign  M_AXI_AWCACHE               =   AXI_FULL_IF.AXI_AWCACHE     ;
    assign  M_AXI_AWPROT                =   AXI_FULL_IF.AXI_AWPROT      ;
    assign  M_AXI_AWQOS                 =   AXI_FULL_IF.AXI_AWQOS       ;
    assign  M_AXI_AWVALID               =   AXI_FULL_IF.AXI_AWVALID     ;
    assign  AXI_FULL_IF.AXI_AWREADY     =   M_AXI_AWREADY               ;

    //----------------Write Data Channel----------------//
    assign  M_AXI_WDATA                 =   AXI_FULL_IF.AXI_WDATA       ;
    assign  M_AXI_WSTRB                 =   AXI_FULL_IF.AXI_WSTRB       ;
    assign  M_AXI_WLAST                 =   AXI_FULL_IF.AXI_WLAST       ;
    assign  M_AXI_WVALID                =   AXI_FULL_IF.AXI_WVALID      ;
    assign  AXI_FULL_IF.AXI_WREADY      =   M_AXI_WREADY                ;

    //----------------Write Response Channel----------------//
    assign  AXI_FULL_IF.AXI_BID         =   M_AXI_BID                   ;
    assign  AXI_FULL_IF.AXI_BRESP       =   M_AXI_BRESP                 ;
    assign  AXI_FULL_IF.AXI_BVALID      =   M_AXI_BVALID                ;
    assign  M_AXI_BREADY                =   AXI_FULL_IF.AXI_BREADY      ;

    //----------------Read Address Channel----------------//
    assign  M_AXI_ARID                  =   AXI_FULL_IF.AXI_ARID        ;
    assign  M_AXI_ARADDR                =   AXI_FULL_IF.AXI_ARADDR      ;
    assign  M_AXI_ARLEN                 =   AXI_FULL_IF.AXI_ARLEN       ;
    assign  M_AXI_ARSIZE                =   AXI_FULL_IF.AXI_ARSIZE      ;
    assign  M_AXI_ARBURST               =   AXI_FULL_IF.AXI_ARBURST     ;
    assign  M_AXI_ARCACHE               =   AXI_FULL_IF.AXI_ARCACHE     ;
    assign  M_AXI_ARPROT                =   AXI_FULL_IF.AXI_ARPROT      ;
    assign  M_AXI_ARQOS                 =   AXI_FULL_IF.AXI_ARQOS       ;
    assign  M_AXI_ARVALID               =   AXI_FULL_IF.AXI_ARVALID     ;
    assign  AXI_FULL_IF.AXI_ARREADY     =   M_AXI_ARREADY               ;

    //----------------Read Data Channel----------------//
    assign  AXI_FULL_IF.AXI_RID         =   M_AXI_RID                   ;
    assign  AXI_FULL_IF.AXI_RDATA       =   M_AXI_RDATA                 ;
    assign  AXI_FULL_IF.AXI_RRESP       =   M_AXI_RRESP                 ;
    assign  AXI_FULL_IF.AXI_RLAST       =   M_AXI_RLAST                 ;
    assign  AXI_FULL_IF.AXI_RVALID      =   M_AXI_RVALID                ;
    assign  M_AXI_RREADY                =   AXI_FULL_IF.AXI_RREADY      ;

//----------------------------------------------------
// AXI-LITE slave port
    assign  AXI_LITE_IF.AXI_AWADDR      =   S_AXI_AWADDR                ;
    assign  AXI_LITE_IF.AXI_AWPROT      =   S_AXI_AWPROT                ;
    assign  AXI_LITE_IF.AXI_AWVALID     =   S_AXI_AWVALID               ;
    assign  S_AXI_AWREADY               =   AXI_LITE_IF.AXI_AWREADY     ;

    assign  AXI_LITE_IF.AXI_WDATA       =   S_AXI_WDATA                 ;
    assign  AXI_LITE_IF.AXI_WSTRB       =   S_AXI_WSTRB                 ;
    assign  AXI_LITE_IF.AXI_WVALID      =   S_AXI_WVALID                ;
    assign  S_AXI_WREADY                =   AXI_LITE_IF.AXI_WREADY      ;

    assign  AXI_LITE_IF.AXI_BRESP       =   S_AXI_BRESP                 ;
    assign  AXI_LITE_IF.AXI_BVALID      =   S_AXI_BVALID                ;
    assign  S_AXI_BREADY                =   AXI_LITE_IF.AXI_BREADY      ;

    assign  AXI_LITE_IF.AXI_ARADDR      =   S_AXI_ARADDR                ;
    assign  AXI_LITE_IF.AXI_ARPROT      =   S_AXI_ARPROT                ;
    assign  AXI_LITE_IF.AXI_ARVALID     =   S_AXI_ARVALID               ;
    assign  S_AXI_ARREADY               =   AXI_LITE_IF.AXI_ARREADY     ;
    
    assign  S_AXI_RDATA                 =   AXI_LITE_IF.AXI_RDATA       ;
    assign  S_AXI_RRESP                 =   AXI_LITE_IF.AXI_RRESP       ;
    assign  S_AXI_RVALID                =   AXI_LITE_IF.AXI_RVALID      ;
    assign  AXI_LITE_IF.AXI_RREADY      =   S_AXI_RREADY                ;





paillier_axi_top#(
        .BLOCK_COUNT                (BLOCK_COUNT            )
	,	.K                          (K                      )
    ,   .N                          (N                      )
//----------------------------------------------------
// parameter of AXI-FULL slave port
        // Base address of targeted slave
	,   .TARGET_RD_ADDR             (TARGET_RD_ADDR         )
	,   .TARGET_WR_ADDR             (TARGET_WR_ADDR         )
)paillier_axi_top_inst(
//----------------------------------------------------
// AXI-FULL master port
        .M_AXI_ACLK                 (M_AXI_ACLK             )
    ,   .M_AXI_ARESETN              (M_AXI_ARESETN          )

    ,   .AXI_FULL_IF                (AXI_FULL_IF            )
//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK                 (S_AXI_ACLK             )
    ,   .S_AXI_ARESETN              (S_AXI_ARESETN          )

    ,   .AXI_LITE_IF                (AXI_LITE_IF            )
);




endmodule