`timescale 1ns / 1ps

module paillier_axi_top_tb();
//AXI-FULL parameter definition
    parameter integer AXI_ID_WIDTH	        = 1     ;
    parameter integer AXI_DATA_WIDTH	    = 128   ;
    parameter integer AXI_ADDR_WIDTH	    = 64    ;
    parameter integer AXI_AWUSER_WIDTH	    = 0     ;
    parameter integer AXI_ARUSER_WIDTH	    = 0     ;
    parameter integer AXI_WUSER_WIDTH	    = 0     ;
    parameter integer AXI_RUSER_WIDTH	    = 0     ;
    parameter integer AXI_BUSER_WIDTH	    = 0     ;

//AXI-LITE  parameter definition
    parameter integer C_S_AXI_DATA_WIDTH	= 32    ;
    parameter integer C_S_AXI_ADDR_WIDTH	= 4     ;

//AXI-LITE interface
    wire                                    S_LITE_AXI_ACLK         ;
    wire                                    S_LITE_AXI_ARESETN      ;

    wire [C_S_AXI_ADDR_WIDTH-1 : 0]         S_LITE_AXI_AWADDR       ;
    wire [2 : 0]                            S_LITE_AXI_AWPROT       ;
    wire                                    S_LITE_AXI_AWVALID      ;
    wire                                    S_LITE_AXI_AWREADY      ;
    wire [C_S_AXI_DATA_WIDTH-1 : 0]         S_LITE_AXI_WDATA        ;
    wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]     S_LITE_AXI_WSTRB        ;
    wire                                    S_LITE_AXI_WVALID       ;
    wire                                    S_LITE_AXI_WREADY       ;
    wire [1 : 0]                            S_LITE_AXI_BRESP        ;
    wire                                    S_LITE_AXI_BVALID       ;
    wire                                    S_LITE_AXI_BREADY       ;
    wire [C_S_AXI_ADDR_WIDTH-1 : 0]         S_LITE_AXI_ARADDR       ;
    wire [2 : 0]                            S_LITE_AXI_ARPROT       ;
    wire                                    S_LITE_AXI_ARVALID      ;
    wire                                    S_LITE_AXI_ARREADY      ;
    wire [C_S_AXI_DATA_WIDTH-1 : 0]         S_LITE_AXI_RDATA        ;
    wire [1 : 0]                            S_LITE_AXI_RRESP        ;
    wire                                    S_LITE_AXI_RVALID       ;
    wire                                    S_LITE_AXI_RREADY       ;

//AXI-FULL interface
    reg                                     M_AXI_ACLK              ;
    reg                                     M_AXI_ARESETN           ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_AWID              ;
    wire [AXI_ADDR_WIDTH-1 : 0]             M_AXI_AWADDR            ;
    wire [7 : 0]                            M_AXI_AWLEN             ;
    wire [2 : 0]                            M_AXI_AWSIZE            ;
    wire [1 : 0]                            M_AXI_AWBURST           ;
    wire                                    M_AXI_AWLOCK            ;
    wire [3 : 0]                            M_AXI_AWCACHE           ;
    wire [2 : 0]                            M_AXI_AWPROT            ;
    wire [3 : 0]                            M_AXI_AWQOS             ;
    wire [3 : 0]                            S_AXI_AWREGION          ;
    wire [AXI_AWUSER_WIDTH-1 : 0]           M_AXI_AWUSER            ;
    wire                                    M_AXI_AWVALID           ;
    wire                                    M_AXI_AWREADY           ;

    wire [AXI_DATA_WIDTH-1 : 0]             M_AXI_WDATA             ;
    wire [(AXI_DATA_WIDTH/8)-1 : 0]         M_AXI_WSTRB             ;
    wire                                    M_AXI_WLAST             ;
    wire [AXI_WUSER_WIDTH-1 : 0]            M_AXI_WUSER             ;
    wire                                    M_AXI_WVALID            ;
    wire                                    M_AXI_WREADY            ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_BID               ;
    wire [1 : 0]                            M_AXI_BRESP             ;
    wire [AXI_BUSER_WIDTH-1 : 0]            M_AXI_BUSER             ;
    wire                                    M_AXI_BVALID            ;
    wire                                    M_AXI_BREADY            ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_ARID              ;
    wire [AXI_ADDR_WIDTH-1 : 0]             M_AXI_ARADDR            ;
    wire [7 : 0]                            M_AXI_ARLEN             ;
    wire [2 : 0]                            M_AXI_ARSIZE            ;
    wire [1 : 0]                            M_AXI_ARBURST           ;
    wire                                    M_AXI_ARLOCK            ;
    wire [3 : 0]                            M_AXI_ARCACHE           ;
    wire [2 : 0]                            M_AXI_ARPROT            ;
    wire [3 : 0]                            M_AXI_ARQOS             ;
    wire [3 : 0]                            S_AXI_ARREGION          ;
    wire [AXI_ARUSER_WIDTH-1 : 0]           M_AXI_ARUSER            ;
    wire                                    M_AXI_ARVALID           ;
    wire                                    M_AXI_ARREADY           ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_RID               ;
    wire [AXI_DATA_WIDTH-1 : 0]             M_AXI_RDATA             ;
    wire [1 : 0]                            M_AXI_RRESP             ;
    wire                                    M_AXI_RLAST             ;
    wire [AXI_RUSER_WIDTH-1 : 0]            M_AXI_RUSER             ;
    wire                                    M_AXI_RVALID            ;
    wire                                    M_AXI_RREADY            ;

    reg                                     INIT_AXI_TXN            ;

tvip_axi_if AXI_FULL_IF(M_AXI_ACLK, M_AXI_ARESETN);
tvip_axi_if AXI_LITE_IF(S_LITE_AXI_ACLK, S_LITE_AXI_ARESETN);

localparam _DATA_WIDTH_ = 32;
localparam _PERIOD_ = 5;
initial begin
    M_AXI_ACLK      <=  0;
    M_AXI_ARESETN   <=  0;
end
always #(_PERIOD_/2) M_AXI_ACLK = ~M_AXI_ACLK;
initial begin
    #(_PERIOD_*10);
    M_AXI_ARESETN = 1'b1;
end

assign  S_LITE_AXI_ACLK     =   M_AXI_ACLK;
assign  S_LITE_AXI_ARESETN  =   M_AXI_ARESETN;

parameter   K                       = 128;
parameter   N                       = 32;

localparam  STA_ENCRYPTION          = 2'b00,
            STA_DECRYPTION          = 2'b01,
            STA_HOMOMORPHIC_ADD     = 2'b10,
            STA_SCALAR_MUL          = 2'b11;

parameter   PAILLIER_MODE           = STA_ENCRYPTION;
parameter   BLOCK_COUNT             = 5;
parameter   TEST_TIMES              = 3;

initial begin
    @(posedge S_LITE_AXI_ARESETN);
    @(posedge S_LITE_AXI_ACLK);
    paillier_axi_top.u_saxi_lite_core.slv_reg3 = TEST_TIMES >> 32;
    paillier_axi_top.u_saxi_lite_core.slv_reg2 = TEST_TIMES & 32'hFFFFFFFF;
end

initial begin
    INIT_AXI_TXN    <=  0;
    @(posedge M_AXI_ARESETN);
    #(_PERIOD_*4)
    INIT_AXI_TXN    <=  1;
    #_PERIOD_
    INIT_AXI_TXN    <=  0;
end

paillier_axi_top#(
        .BLOCK_COUNT                (BLOCK_COUNT            )
	,	.K                          (K                      )
    ,   .N                          (N                      )
//----------------------------------------------------
// parameter of AXI-FULL slave port
        // Base address of targeted slave
	,   .TARGET_RD_ADDR             (64'h0_0000_0000        )
	,   .TARGET_WR_ADDR             (64'h0_0000_0000        )
//----------------------------------------------------
// parameter of AXI-FULL slave port
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	,   .C_M_AXI_BURST_LEN	            ( 32 )
		// Thread ID Width
	,   .C_M_AXI_ID_WIDTH	            ( 1 )
		// Width of Address Bus
	,   .C_M_AXI_ADDR_WIDTH	            ( AXI_ADDR_WIDTH )
		// Width of Data Bus
	,   .C_M_AXI_DATA_WIDTH	            ( AXI_DATA_WIDTH )
		// Width of User Write Address Bus
	,   .C_M_AXI_AWUSER_WIDTH	        ( 0 )
		// Width of User Read Address Bus
	,   .C_M_AXI_ARUSER_WIDTH	        ( 0 )
		// Width of User Write Data Bus
	,   .C_M_AXI_WUSER_WIDTH	        ( 0 )
		// Width of User Read Data Bus
	,   .C_M_AXI_RUSER_WIDTH	        ( 0 )
	    // Width of User Response Bus
	,   .C_M_AXI_BUSER_WIDTH	        ( 0 )
//----------------------------------------------------
// parameter of AXI-LITE slave port
		// Width of S_AXI data bus
	,   .C_S_AXI_DATA_WIDTH	            ( C_S_AXI_DATA_WIDTH )
		// Width of S_AXI address bus
	,	.C_S_AXI_ADDR_WIDTH             ( C_S_AXI_ADDR_WIDTH )
)paillier_axi_top_inst(
//----------------------------------------------------
// AXI-FULL master port
        .M_AXI_ACLK             (M_AXI_ACLK     	)
    ,   .M_AXI_ARESETN          (M_AXI_ARESETN  	)

    //----------------Write Address Channel----------------//
    ,   .M_AXI_AWID             (AXI_FULL_IF.AXI_AWID    		)
    ,   .M_AXI_AWADDR           (AXI_FULL_IF.AXI_AWADDR  		)
    ,   .M_AXI_AWLEN            (AXI_FULL_IF.AXI_AWLEN   		)
    ,   .M_AXI_AWSIZE           (AXI_FULL_IF.AXI_AWSIZE  		)
    ,   .M_AXI_AWBURST          (AXI_FULL_IF.AXI_AWBURST 		)
    // ,   .M_AXI_AWLOCK           (AXI_FULL_IF.AXI_AWLOCK  		)
    ,   .M_AXI_AWCACHE          (AXI_FULL_IF.AXI_AWCACHE 		)
    ,   .M_AXI_AWPROT           (AXI_FULL_IF.AXI_AWPROT  		)
    ,   .M_AXI_AWQOS            (AXI_FULL_IF.AXI_AWQOS   		)
    // ,   .M_AXI_AWUSER           (AXI_FULL_IF.AXI_AWUSER  		)
    ,   .M_AXI_AWVALID          (AXI_FULL_IF.AXI_AWVALID 		)
    ,   .M_AXI_AWREADY          (AXI_FULL_IF.AXI_AWREADY 		)

    //----------------Write Data Channel----------------//
    ,   .M_AXI_WDATA            (AXI_FULL_IF.AXI_WDATA    	)
    ,   .M_AXI_WSTRB            (AXI_FULL_IF.AXI_WSTRB    	)
    ,   .M_AXI_WLAST            (AXI_FULL_IF.AXI_WLAST    	)
    // ,   .M_AXI_WUSER            (AXI_FULL_IF.M_AXI_WUSER    	)
    ,   .M_AXI_WVALID           (AXI_FULL_IF.AXI_WVALID   	)
    ,   .M_AXI_WREADY           (AXI_FULL_IF.AXI_WREADY   	)

    //----------------Write Response Channel----------------//
    ,   .M_AXI_BID              (AXI_FULL_IF.AXI_BID      	)
    ,   .M_AXI_BRESP            (AXI_FULL_IF.AXI_BRESP    	)
    // ,   .M_AXI_BUSER            (AXI_FULL_IF.M_AXI_BUSER    	)
    ,   .M_AXI_BVALID           (AXI_FULL_IF.AXI_BVALID   	)
    ,   .M_AXI_BREADY           (AXI_FULL_IF.AXI_BREADY   	)

    //----------------Read Address Channel----------------//
    ,   .M_AXI_ARID             (AXI_FULL_IF.AXI_ARID    		)
    ,   .M_AXI_ARADDR           (AXI_FULL_IF.AXI_ARADDR  		)
    ,   .M_AXI_ARLEN            (AXI_FULL_IF.AXI_ARLEN   		)
    ,   .M_AXI_ARSIZE           (AXI_FULL_IF.AXI_ARSIZE  		)
    ,   .M_AXI_ARBURST          (AXI_FULL_IF.AXI_ARBURST 		)
    // ,   .M_AXI_ARLOCK           (AXI_FULL_IF.M_AXI_ARLOCK  		)
    ,   .M_AXI_ARCACHE          (AXI_FULL_IF.AXI_ARCACHE 		)
    ,   .M_AXI_ARPROT           (AXI_FULL_IF.AXI_ARPROT  		)
    ,   .M_AXI_ARQOS            (AXI_FULL_IF.AXI_ARQOS   		)
    // ,   .M_AXI_ARUSER           (AXI_FULL_IF.M_AXI_ARUSER  		)
    ,   .M_AXI_ARVALID          (AXI_FULL_IF.AXI_ARVALID 		)
    ,   .M_AXI_ARREADY          (AXI_FULL_IF.AXI_ARREADY 		)

    //----------------Read Data Channel----------------//
    ,   .M_AXI_RID              (AXI_FULL_IF.AXI_RID     		)
    ,   .M_AXI_RDATA            (AXI_FULL_IF.AXI_RDATA   		)
    ,   .M_AXI_RRESP            (AXI_FULL_IF.AXI_RRESP   		)
    ,   .M_AXI_RLAST            (AXI_FULL_IF.AXI_RLAST   		)
    // ,   .M_AXI_RUSER            (AXI_FULL_IF.M_AXI_RUSER   		)
    ,   .M_AXI_RVALID           (AXI_FULL_IF.AXI_RVALID  		)
    ,   .M_AXI_RREADY           (AXI_FULL_IF.AXI_RREADY  		)
 
//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK             (S_LITE_AXI_ACLK                )
    ,   .S_AXI_ARESETN          (S_LITE_AXI_ARESETN             )

    ,   .S_AXI_AWADDR           (AXI_LITE_IF.AXI_AWADDR         )
    ,   .S_AXI_AWPROT           (AXI_LITE_IF.AXI_AWPROT         )
    ,   .S_AXI_AWVALID          (AXI_LITE_IF.AXI_AWVALID        )
    ,   .S_AXI_AWREADY          (AXI_LITE_IF.AXI_AWREADY        )
    ,   .S_AXI_WDATA            (AXI_LITE_IF.AXI_WDATA          )
    ,   .S_AXI_WSTRB            (AXI_LITE_IF.AXI_WSTRB          )
    ,   .S_AXI_WVALID           (AXI_LITE_IF.AXI_WVALID         )
    ,   .S_AXI_WREADY           (AXI_LITE_IF.AXI_WREADY         )
    ,   .S_AXI_BRESP            (AXI_LITE_IF.AXI_BRESP          )
    ,   .S_AXI_BVALID           (AXI_LITE_IF.AXI_BVALID         )
    ,   .S_AXI_BREADY           (AXI_LITE_IF.AXI_BREADY         )
    ,   .S_AXI_ARADDR           (AXI_LITE_IF.AXI_ARADDR         )
    ,   .S_AXI_ARPROT           (AXI_LITE_IF.AXI_ARPROT         )
    ,   .S_AXI_ARVALID          (AXI_LITE_IF.AXI_ARVALID        )
    ,   .S_AXI_ARREADY          (AXI_LITE_IF.AXI_ARREADY        )
    ,   .S_AXI_RDATA            (AXI_LITE_IF.AXI_RDATA          )
    ,   .S_AXI_RRESP            (AXI_LITE_IF.AXI_RRESP          )
    ,   .S_AXI_RVALID           (AXI_LITE_IF.AXI_RVALID         )
    ,   .S_AXI_RREADY           (AXI_LITE_IF.AXI_RREADY         )
);

//Virtual AXI-FULL MEMORY 
Virtual_Axi_Full_Memory # ( 
        .PAILLIER_MODE              (PAILLIER_MODE          )
    ,   .TEST_TIMES                 (TEST_TIMES             )
)Virtual_Axi_Full_Memory_Inst ( 
		.S_AXI_ACLK         	    (M_AXI_ACLK             )
	,   .S_AXI_ARESETN      	    (M_AXI_ARESETN          )

    ,   .AXI_FULL_IF           	    (AXI_FULL_IF            )
);


Virtual_Axi_Lite_Stimulation #(
        .PAILLIER_MODE              (PAILLIER_MODE          )
    ,   .C_M_START_DATA_VALUE       ()
    ,   .C_M_TARGET_SLAVE_BASE_ADDR (32'h00000000           )
    ,   .C_M_TRANSACTIONS_NUM       (1)
)Virtual_Axi_Lite_Stimulation_inst(
        .INIT_AXI_TXN               (INIT_AXI_TXN           )

    ,   .M_AXI_ACLK                 (S_LITE_AXI_ACLK        )
    ,   .M_AXI_ARESETN              (S_LITE_AXI_ARESETN     )
    
    ,   .AXI_LITE_IF                (AXI_LITE_IF            )
);


endmodule
