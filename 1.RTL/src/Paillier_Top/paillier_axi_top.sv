module paillier_axi_top#(
// Users to add parameters here
        parameter BLOCK_COUNT   = 18
    ,   parameter TEST_TIMES    = 18
	,	parameter K             = 128
    ,   parameter N             = 32
    ,   parameter MULT_METHOD   = "TRADITION"   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                                // "TRADITION" :MULT_LATENCY=9                
                                                // "VEDIC8"    :VEDIC MULT, MULT_LATENCY=8 
    ,   parameter ADD1_METHOD   = "3-2_PIPE1"   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                                // "3-2_PIPE2" :classic pipeline adder,stage 2,ADD1_LATENCY=2
                                                // "3-2_PIPE1" :classic pipeline adder,stage 1,ADD1_LATENCY=1
                                                // 
    ,   parameter ADD2_METHOD   = "COMMON"      // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                                // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                                // 
//----------------------------------------------------
// parameter of AXI-FULL slave port
		// Base address of targeted slave
	,   parameter  C_M_TARGET_RD_ADDR = 64'h0_0000_0000
	,   parameter  C_M_TARGET_WR_ADDR = 64'h1_0000_0000
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
    genvar o;

//----------------------------------------------------
// wire definition

    wire                        rd_rdy                  [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             rd_dout                 [0 : BLOCK_COUNT - 1]   ;
    wire    [$clog2(N):0]       rd_cnt                  [0 : BLOCK_COUNT - 1]   ;

    wire    		            paillier_start                                  ;
    wire    [1:0]	            paillier_mode                                   ;
    wire    			        paillier_finished                               ;

    wire    [1  :0]             task_cmd                [0 : BLOCK_COUNT - 1]   ;
    wire                        task_req                [0 : BLOCK_COUNT - 1]   ;
    wire                        task_end                [0 : BLOCK_COUNT - 1]   ;

    wire    [K-1:0]             enc_m_data              [0 : BLOCK_COUNT - 1]   ;
    wire                        enc_m_valid             [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             enc_r_data              [0 : BLOCK_COUNT - 1]   ;
    wire                        enc_r_valid             [0 : BLOCK_COUNT - 1]   ;

    wire    [K-1:0]             dec_c_data              [0 : BLOCK_COUNT - 1]   ;
    wire                        dec_c_valid             [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             dec_lambda_data         [0 : BLOCK_COUNT - 1]   ;
    wire                        dec_lambda_valid        [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             dec_n_data              [0 : BLOCK_COUNT - 1]   ;
    wire                        dec_n_valid             [0 : BLOCK_COUNT - 1]   ;

    wire    [K-1:0]             homo_add_c1             [0 : BLOCK_COUNT - 1]   ;
    wire                        homo_add_c1_valid       [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             homo_add_c2             [0 : BLOCK_COUNT - 1]   ;
    wire                        homo_add_c2_valid       [0 : BLOCK_COUNT - 1]   ;

    wire    [K-1:0]             scalar_mul_c1           [0 : BLOCK_COUNT - 1]   ;
    wire                        scalar_mul_c1_valid     [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             scalar_mul_const        [0 : BLOCK_COUNT - 1]   ;
    wire                        scalar_mul_const_valid  [0 : BLOCK_COUNT - 1]   ;

    wire    [K-1:0]             enc_out_data            [0 : BLOCK_COUNT - 1]   ;
    wire                        enc_out_valid           [0 : BLOCK_COUNT - 1]   ;

//---------------------------------------------------
// FIFO TO AXI FULL
axi_full_core #(
    //----------------------------------------------------
    // FIFO parameters
	 	.BLOCK_COUNT            (BLOCK_COUNT            )
	,	.K                      (K                      )
    ,   .N                      (N                      )
    ,   .TEST_TIMES             (TEST_TIMES             )

    //----------------------------------------------------
    // AXI-FULL parameters
	,   .C_M_TARGET_WR_ADDR     (C_M_TARGET_WR_ADDR     )   
	,   .C_M_TARGET_RD_ADDR     (C_M_TARGET_RD_ADDR     )   
	,   .C_M_AXI_BURST_LEN	    (C_M_AXI_BURST_LEN	    )      
	,   .C_M_AXI_ID_WIDTH	    (C_M_AXI_ID_WIDTH	    )   
	,   .C_M_AXI_ADDR_WIDTH	    (C_M_AXI_ADDR_WIDTH	    )   
	,   .C_M_AXI_DATA_WIDTH	    (C_M_AXI_DATA_WIDTH	    )   
	,   .C_M_AXI_AWUSER_WIDTH   (C_M_AXI_AWUSER_WIDTH   )   
	,   .C_M_AXI_ARUSER_WIDTH   (C_M_AXI_ARUSER_WIDTH   )   
	,   .C_M_AXI_WUSER_WIDTH    (C_M_AXI_WUSER_WIDTH    )   
	,   .C_M_AXI_RUSER_WIDTH    (C_M_AXI_RUSER_WIDTH    )   
	,   .C_M_AXI_BUSER_WIDTH    (C_M_AXI_BUSER_WIDTH    )   
)u_axi_full_core(
//----------------------------------------------------
// paillier control interface
        .paillier_start         (paillier_start         )
    ,   .paillier_mode          (paillier_mode          )
    ,   .paillier_finished      (paillier_finished      )

//----------------------------------------------------
// backward fifo read interface
    ,   .rd_rdy                 (rd_rdy                 )
    ,   .rd_dout                (rd_dout                )
    ,   .rd_cnt                 (rd_cnt                 )

//----------------------------------------------------
// paillier accelerator interface
    ,   .task_cmd				(task_cmd               )
    ,   .task_req				(task_req               )
    ,   .task_end				(task_end               )

    ,   .enc_m_data				(enc_m_data             )
    ,   .enc_m_valid			(enc_m_valid            )
    ,   .enc_r_data				(enc_r_data             )
    ,   .enc_r_valid			(enc_r_valid            )

    ,   .dec_c_data				(dec_c_data             )
    ,   .dec_c_valid			(dec_c_valid            )
    ,   .dec_lambda_data		(dec_lambda_data        )
    ,   .dec_lambda_valid		(dec_lambda_valid       )
    ,   .dec_n_data				(dec_n_data             )
    ,   .dec_n_valid			(dec_n_valid            )

    ,   .homo_add_c1			(homo_add_c1            )
    ,   .homo_add_c1_valid		(homo_add_c1_valid      )
    ,   .homo_add_c2			(homo_add_c2            )
    ,   .homo_add_c2_valid		(homo_add_c2_valid      )

    ,   .scalar_mul_c1			(scalar_mul_c1          )
    ,   .scalar_mul_c1_valid	(scalar_mul_c1_valid    )
    ,   .scalar_mul_const		(scalar_mul_const       )
    ,   .scalar_mul_const_valid	(scalar_mul_const_valid )
    
//----------------------------------------------------
// AXI-FULL master port
    ,   .M_AXI_ACLK             (M_AXI_ACLK             )
    ,   .M_AXI_ARESETN          (M_AXI_ARESETN          )

    //----------------Write Address Channel-------------//
    ,   .M_AXI_AWID             (M_AXI_AWID             )
    ,   .M_AXI_AWADDR           (M_AXI_AWADDR           )
    ,   .M_AXI_AWLEN            (M_AXI_AWLEN            )
    ,   .M_AXI_AWSIZE           (M_AXI_AWSIZE           )
    ,   .M_AXI_AWBURST          (M_AXI_AWBURST          )
    ,   .M_AXI_AWLOCK           (M_AXI_AWLOCK           )
    ,   .M_AXI_AWCACHE          (M_AXI_AWCACHE          )
    ,   .M_AXI_AWPROT           (M_AXI_AWPROT           )
    ,   .M_AXI_AWQOS            (M_AXI_AWQOS            )
    ,   .M_AXI_AWUSER           (M_AXI_AWUSER           )
    ,   .M_AXI_AWVALID          (M_AXI_AWVALID          )
    ,   .M_AXI_AWREADY          (M_AXI_AWREADY          )

    //----------------Write Data Channel----------------//
    ,   .M_AXI_WDATA            (M_AXI_WDATA            )
    ,   .M_AXI_WSTRB            (M_AXI_WSTRB            )
    ,   .M_AXI_WLAST            (M_AXI_WLAST            )
    ,   .M_AXI_WUSER            (M_AXI_WUSER            )
    ,   .M_AXI_WVALID           (M_AXI_WVALID           )
    ,   .M_AXI_WREADY           (M_AXI_WREADY           )

    //----------------Write Response Channel------------//
    ,   .M_AXI_BID              (M_AXI_BID              )
    ,   .M_AXI_BRESP            (M_AXI_BRESP            )
    ,   .M_AXI_BUSER            (M_AXI_BUSER            )
    ,   .M_AXI_BVALID           (M_AXI_BVALID           )
    ,   .M_AXI_BREADY           (M_AXI_BREADY           )

    //----------------Read Address Channel--------------//
    ,   .M_AXI_ARID             (M_AXI_ARID             )
    ,   .M_AXI_ARADDR           (M_AXI_ARADDR           )
    ,   .M_AXI_ARLEN            (M_AXI_ARLEN            )
    ,   .M_AXI_ARSIZE           (M_AXI_ARSIZE           )
    ,   .M_AXI_ARBURST          (M_AXI_ARBURST          )
    ,   .M_AXI_ARLOCK           (M_AXI_ARLOCK           )
    ,   .M_AXI_ARCACHE          (M_AXI_ARCACHE          )
    ,   .M_AXI_ARPROT           (M_AXI_ARPROT           )
    ,   .M_AXI_ARQOS            (M_AXI_ARQOS            )
    ,   .M_AXI_ARUSER           (M_AXI_ARUSER           )
    ,   .M_AXI_ARVALID          (M_AXI_ARVALID          )
    ,   .M_AXI_ARREADY          (M_AXI_ARREADY          )

    //----------------Read Data Channel-----------------//
    ,   .M_AXI_RID              (M_AXI_RID              )
    ,   .M_AXI_RDATA            (M_AXI_RDATA            )
    ,   .M_AXI_RRESP            (M_AXI_RRESP            )
    ,   .M_AXI_RLAST            (M_AXI_RLAST            )
    ,   .M_AXI_RUSER            (M_AXI_RUSER            )
    ,   .M_AXI_RVALID           (M_AXI_RVALID           )
    ,   .M_AXI_RREADY           (M_AXI_RREADY           )
);


saxi_lite_core #(
    // Width of S_AXI data bus
        .C_S_AXI_DATA_WIDTH	    ( C_S_AXI_DATA_WIDTH    )
    // Width of S_AXI address bus
    ,   .C_S_AXI_ADDR_WIDTH	    ( C_S_AXI_ADDR_WIDTH    )
)u_saxi_lite_core(
//----------------------------------------------------
// paillier control interface
        .paillier_start         (paillier_start         )
    ,   .paillier_mode          (paillier_mode          )
    ,   .paillier_finished      (paillier_finished      )

//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK             (S_AXI_ACLK             )
    ,   .S_AXI_ARESETN          (S_AXI_ARESETN          )
    ,   .S_AXI_AWADDR           (S_AXI_AWADDR           )
    ,   .S_AXI_AWPROT           (S_AXI_AWPROT           )
    ,   .S_AXI_AWVALID          (S_AXI_AWVALID          )
    ,   .S_AXI_AWREADY          (S_AXI_AWREADY          )
    ,   .S_AXI_WDATA            (S_AXI_WDATA            )
    ,   .S_AXI_WSTRB            (S_AXI_WSTRB            )
    ,   .S_AXI_WVALID           (S_AXI_WVALID           )
    ,   .S_AXI_WREADY           (S_AXI_WREADY           )
    ,   .S_AXI_BRESP            (S_AXI_BRESP            )
    ,   .S_AXI_BVALID           (S_AXI_BVALID           )
    ,   .S_AXI_BREADY           (S_AXI_BREADY           )
    ,   .S_AXI_ARADDR           (S_AXI_ARADDR           )
    ,   .S_AXI_ARPROT           (S_AXI_ARPROT           )
    ,   .S_AXI_ARVALID          (S_AXI_ARVALID          )
    ,   .S_AXI_ARREADY          (S_AXI_ARREADY          )
    ,   .S_AXI_RDATA            (S_AXI_RDATA            )
    ,   .S_AXI_RRESP            (S_AXI_RRESP            )
    ,   .S_AXI_RVALID           (S_AXI_RVALID           )
    ,   .S_AXI_RREADY           (S_AXI_RREADY           )
);

generate 
    for(o = 0; o < BLOCK_COUNT; o = o + 1) begin
        paillier_top #( 
                .MULT_METHOD                (MULT_METHOD                )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                                                            // "TRADITION" :MULT_LATENCY=9                
                                                                            // "VEDIC8"  :VEDIC MULT, MULT_LATENCY=8 
            ,   .ADD1_METHOD                (ADD1_METHOD                )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                                                            // 
            ,   .ADD2_METHOD                (ADD2_METHOD                )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                                                            // 
            ,   .K                          (K                          )
            ,   .N                          (N                          )
        )paillier_top_inst(
                .clk                        (M_AXI_ACLK                 )
            ,   .rst_n                      (M_AXI_ARESETN              )

            ,   .task_cmd                   (task_cmd               [o] )
            ,   .task_req                   (task_req               [o] )
            ,   .task_end                   (task_end               [o] ) 

            ,   .enc_m_data                 (enc_m_data             [o] )
            ,   .enc_m_valid                (enc_m_valid            [o] )
            ,   .enc_r_data                 (enc_r_data             [o] )
            ,   .enc_r_valid                (enc_r_valid            [o] )

            ,   .dec_c_data                 (dec_c_data             [o] )
            ,   .dec_c_valid                (dec_c_valid            [o] )
            ,   .dec_lambda_data            (dec_lambda_data        [o] )
            ,   .dec_lambda_valid           (dec_lambda_valid       [o] )
            ,   .dec_n_data                 (dec_n_data             [o] )
            ,   .dec_n_valid                (dec_n_valid            [o] )

            ,   .homo_add_c1                (homo_add_c1            [o] )
            ,   .homo_add_c1_valid          (homo_add_c1_valid      [o] )
            ,   .homo_add_c2                (homo_add_c2            [o] )
            ,   .homo_add_c2_valid          (homo_add_c2_valid      [o] )

            ,   .scalar_mul_c1              (scalar_mul_c1          [o] )
            ,   .scalar_mul_c1_valid        (scalar_mul_c1_valid    [o] ) 
            ,   .scalar_mul_const           (scalar_mul_const       [o] )
            ,   .scalar_mul_const_valid     (scalar_mul_const_valid [o] ) 

            ,   .enc_out_data               (enc_out_data           [o] )
            ,   .enc_out_valid              (enc_out_valid          [o] )
        );
    end
endgenerate


generate 
    for(o = 0; o < BLOCK_COUNT; o = o + 1) begin
        fifo #(
                .FDW            (K                          )// data width
            ,   .FAW            ($clog2(N<<1)               )// The FIFO depth is twice the value of the output data.
            ,   .ULN            ()// lookahead-full
        )fifo_inst(
                .clk            (M_AXI_ACLK                 )
            ,   .rst            (!M_AXI_ARESETN             )// asynchronous reset (active high)
            ,   .clr            ()// synchronous reset (active high)
            ,   .wr_rdy         ()
            ,   .wr_vld         (enc_out_valid          [o] )
            ,   .wr_din         (enc_out_data           [o] )
            ,   .rd_rdy         (rd_rdy                 [o] )
            ,   .rd_vld         ()
            ,   .rd_dout        (rd_dout                [o] )
            ,   .full           ()
            ,   .empty          ()
            ,   .fullN          ()// lookahead full: there are only N rooms in the FIFO
            ,   .emptyN         ()// lookahead empty: there are only N items in the FIFO
            ,   .rd_cnt         (rd_cnt                 [o] )// num of elements in the FIFO to be read
            ,   .wr_cnt         ()// num of rooms in the FIFO to be written
        );
    end
endgenerate

endmodule