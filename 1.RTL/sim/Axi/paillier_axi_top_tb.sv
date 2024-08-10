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
    reg                                     M_AXI_ACLK      ;
    reg                                     M_AXI_ARESETN   ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_AWID      ;
    wire [AXI_ADDR_WIDTH-1 : 0]             M_AXI_AWADDR    ;
    wire [7 : 0]                            M_AXI_AWLEN     ;
    wire [2 : 0]                            M_AXI_AWSIZE    ;
    wire [1 : 0]                            M_AXI_AWBURST   ;
    wire                                    M_AXI_AWLOCK    ;
    wire [3 : 0]                            M_AXI_AWCACHE   ;
    wire [2 : 0]                            M_AXI_AWPROT    ;
    wire [3 : 0]                            M_AXI_AWQOS     ;
    wire [3 : 0]                            S_AXI_AWREGION  ;
    wire [AXI_AWUSER_WIDTH-1 : 0]           M_AXI_AWUSER    ;
    wire                                    M_AXI_AWVALID   ;
    wire                                    M_AXI_AWREADY   ;

    wire [AXI_DATA_WIDTH-1 : 0]             M_AXI_WDATA     ;
    wire [(AXI_DATA_WIDTH/8)-1 : 0]         M_AXI_WSTRB     ;
    wire                                    M_AXI_WLAST     ;
    wire [AXI_WUSER_WIDTH-1 : 0]            M_AXI_WUSER     ;
    wire                                    M_AXI_WVALID    ;
    wire                                    M_AXI_WREADY    ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_BID       ;
    wire [1 : 0]                            M_AXI_BRESP     ;
    wire [AXI_BUSER_WIDTH-1 : 0]            M_AXI_BUSER     ;
    wire                                    M_AXI_BVALID    ;
    wire                                    M_AXI_BREADY    ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_ARID      ;
    wire [AXI_ADDR_WIDTH-1 : 0]             M_AXI_ARADDR    ;
    wire [7 : 0]                            M_AXI_ARLEN     ;
    wire [2 : 0]                            M_AXI_ARSIZE    ;
    wire [1 : 0]                            M_AXI_ARBURST   ;
    wire                                    M_AXI_ARLOCK    ;
    wire [3 : 0]                            M_AXI_ARCACHE   ;
    wire [2 : 0]                            M_AXI_ARPROT    ;
    wire [3 : 0]                            M_AXI_ARQOS     ;
    wire [3 : 0]                            S_AXI_ARREGION  ;
    wire [AXI_ARUSER_WIDTH-1 : 0]           M_AXI_ARUSER    ;
    wire                                    M_AXI_ARVALID   ;
    wire                                    M_AXI_ARREADY   ;

    wire [AXI_ID_WIDTH-1 : 0]               M_AXI_RID       ;
    wire [AXI_DATA_WIDTH-1 : 0]             M_AXI_RDATA     ;
    wire [1 : 0]                            M_AXI_RRESP     ;
    wire                                    M_AXI_RLAST     ;
    wire [AXI_RUSER_WIDTH-1 : 0]            M_AXI_RUSER     ;
    wire                                    M_AXI_RVALID    ;
    wire                                    M_AXI_RREADY    ;

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

reg             INIT_AXI_TXN;

initial begin
    INIT_AXI_TXN    <=  0;
    @(posedge M_AXI_ARESETN);
    #(_PERIOD_*4)
    INIT_AXI_TXN    <=  1;
    #_PERIOD_
    INIT_AXI_TXN    <=  0;
end

parameter   K                       = 128;
parameter   N                       = 32;

localparam  STA_ENCRYPTION          = 2'b00,
            STA_DECRYPTION          = 2'b01,
            STA_HOMOMORPHIC_ADD     = 2'b10,
            STA_SCALAR_MUL          = 2'b11;

parameter   PAILLIER_MODE           = STA_ENCRYPTION;
parameter   BLOCK_COUNT             = 1;
parameter   TEST_TIMES              = 1;


//To speed up the simulation, the parameter of the Montgomery module is all configured as "COMMON". The final outcome is as identical as others.
paillier_axi_top#(
        .BLOCK_COUNT                    (BLOCK_COUNT                )
    ,   .TEST_TIMES                     (TEST_TIMES                 )
	,	.K                              (K                          )
    ,   .N                              (N                          )
    ,   .MULT_METHOD                    ("COMMON"                   )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                                                        // "TRADITION" :MULT_LATENCY=9                
                                                                        // "VEDIC8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD                    ("COMMON"                   )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                                                        // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                                                        // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                                                        // 
    ,   .ADD2_METHOD                    ("COMMON"                   )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                                                        // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                                                        // 
//----------------------------------------------------
// parameter of AXI-FULL slave port
        // Base address of targeted slave
	,   .C_M_TARGET_SLAVE_BASE_RD_ADDR  (64'h0_0000_0000)
	,   .C_M_TARGET_SLAVE_BASE_WR_ADDR  (64'h0_0000_0000)
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
    ,   .M_AXI_AWID             (M_AXI_AWID    		)
    ,   .M_AXI_AWADDR           (M_AXI_AWADDR  		)
    ,   .M_AXI_AWLEN            (M_AXI_AWLEN   		)
    ,   .M_AXI_AWSIZE           (M_AXI_AWSIZE  		)
    ,   .M_AXI_AWBURST          (M_AXI_AWBURST 		)
    ,   .M_AXI_AWLOCK           (M_AXI_AWLOCK  		)
    ,   .M_AXI_AWCACHE          (M_AXI_AWCACHE 		)
    ,   .M_AXI_AWPROT           (M_AXI_AWPROT  		)
    ,   .M_AXI_AWQOS            (M_AXI_AWQOS   		)
    ,   .M_AXI_AWUSER           (M_AXI_AWUSER  		)
    ,   .M_AXI_AWVALID          (M_AXI_AWVALID 		)
    ,   .M_AXI_AWREADY          (M_AXI_AWREADY 		)

    //----------------Write Data Channel----------------//
    ,   .M_AXI_WDATA            (M_AXI_WDATA    	)
    ,   .M_AXI_WSTRB            (M_AXI_WSTRB    	)
    ,   .M_AXI_WLAST            (M_AXI_WLAST    	)
    ,   .M_AXI_WUSER            (M_AXI_WUSER    	)
    ,   .M_AXI_WVALID           (M_AXI_WVALID   	)
    ,   .M_AXI_WREADY           (M_AXI_WREADY   	)

    //----------------Write Response Channel----------------//
    ,   .M_AXI_BID              (M_AXI_BID      	)
    ,   .M_AXI_BRESP            (M_AXI_BRESP    	)
    ,   .M_AXI_BUSER            (M_AXI_BUSER    	)
    ,   .M_AXI_BVALID           (M_AXI_BVALID   	)
    ,   .M_AXI_BREADY           (M_AXI_BREADY   	)

    //----------------Read Address Channel----------------//
    ,   .M_AXI_ARID             (M_AXI_ARID    		)
    ,   .M_AXI_ARADDR           (M_AXI_ARADDR  		)
    ,   .M_AXI_ARLEN            (M_AXI_ARLEN   		)
    ,   .M_AXI_ARSIZE           (M_AXI_ARSIZE  		)
    ,   .M_AXI_ARBURST          (M_AXI_ARBURST 		)
    ,   .M_AXI_ARLOCK           (M_AXI_ARLOCK  		)
    ,   .M_AXI_ARCACHE          (M_AXI_ARCACHE 		)
    ,   .M_AXI_ARPROT           (M_AXI_ARPROT  		)
    ,   .M_AXI_ARQOS            (M_AXI_ARQOS   		)
    ,   .M_AXI_ARUSER           (M_AXI_ARUSER  		)
    ,   .M_AXI_ARVALID          (M_AXI_ARVALID 		)
    ,   .M_AXI_ARREADY          (M_AXI_ARREADY 		)

    //----------------Read Data Channel----------------//
    ,   .M_AXI_RID              (M_AXI_RID     		)
    ,   .M_AXI_RDATA            (M_AXI_RDATA   		)
    ,   .M_AXI_RRESP            (M_AXI_RRESP   		)
    ,   .M_AXI_RLAST            (M_AXI_RLAST   		)
    ,   .M_AXI_RUSER            (M_AXI_RUSER   		)
    ,   .M_AXI_RVALID           (M_AXI_RVALID  		)
    ,   .M_AXI_RREADY           (M_AXI_RREADY  		)
 
//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK             (S_LITE_AXI_ACLK    )
    ,   .S_AXI_ARESETN          (S_LITE_AXI_ARESETN )
    ,   .S_AXI_AWADDR           (S_LITE_AXI_AWADDR  )
    ,   .S_AXI_AWPROT           (S_LITE_AXI_AWPROT  )
    ,   .S_AXI_AWVALID          (S_LITE_AXI_AWVALID )
    ,   .S_AXI_AWREADY          (S_LITE_AXI_AWREADY )
    ,   .S_AXI_WDATA            (S_LITE_AXI_WDATA   )
    ,   .S_AXI_WSTRB            (S_LITE_AXI_WSTRB   )
    ,   .S_AXI_WVALID           (S_LITE_AXI_WVALID  )
    ,   .S_AXI_WREADY           (S_LITE_AXI_WREADY  )
    ,   .S_AXI_BRESP            (S_LITE_AXI_BRESP   )
    ,   .S_AXI_BVALID           (S_LITE_AXI_BVALID  )
    ,   .S_AXI_BREADY           (S_LITE_AXI_BREADY  )
    ,   .S_AXI_ARADDR           (S_LITE_AXI_ARADDR  )
    ,   .S_AXI_ARPROT           (S_LITE_AXI_ARPROT  )
    ,   .S_AXI_ARVALID          (S_LITE_AXI_ARVALID )
    ,   .S_AXI_ARREADY          (S_LITE_AXI_ARREADY )
    ,   .S_AXI_RDATA            (S_LITE_AXI_RDATA   )
    ,   .S_AXI_RRESP            (S_LITE_AXI_RRESP   )
    ,   .S_AXI_RVALID           (S_LITE_AXI_RVALID  )
    ,   .S_AXI_RREADY           (S_LITE_AXI_RREADY  )
);

//Virtual AXI-FULL MEMORY 
Virtual_Axi_Full_Memory # ( 
        .PAILLIER_MODE          (PAILLIER_MODE      )
    ,   .TEST_TIMES             (TEST_TIMES         )

	,   .C_S_AXI_ID_WIDTH    	(AXI_ID_WIDTH     	)
	,	.C_S_AXI_DATA_WIDTH  	(AXI_DATA_WIDTH   	)
	,	.C_S_AXI_ADDR_WIDTH  	(AXI_ADDR_WIDTH   	)
	,	.C_S_AXI_AWUSER_WIDTH	(AXI_AWUSER_WIDTH 	)
	,	.C_S_AXI_ARUSER_WIDTH	(AXI_ARUSER_WIDTH 	)
	,	.C_S_AXI_WUSER_WIDTH 	(AXI_WUSER_WIDTH  	)
	,	.C_S_AXI_RUSER_WIDTH 	(AXI_RUSER_WIDTH  	)
	,	.C_S_AXI_BUSER_WIDTH 	(AXI_BUSER_WIDTH  	)
)Virtual_Axi_Full_Memory_Inst (
		.S_AXI_ACLK         	(M_AXI_ACLK     	)
	,   .S_AXI_ARESETN      	(M_AXI_ARESETN  	)
	
	,   .S_AXI_AWID         	(M_AXI_AWID     	)
	,   .S_AXI_AWADDR       	(M_AXI_AWADDR   	)
	,   .S_AXI_AWLEN        	(M_AXI_AWLEN    	)
	,   .S_AXI_AWSIZE       	(M_AXI_AWSIZE   	)
	,   .S_AXI_AWBURST      	(M_AXI_AWBURST  	)
	,   .S_AXI_AWLOCK       	(M_AXI_AWLOCK   	)
	,   .S_AXI_AWCACHE      	(M_AXI_AWCACHE  	)
	,   .S_AXI_AWPROT       	(M_AXI_AWPROT   	)
	,   .S_AXI_AWQOS        	(M_AXI_AWQOS    	)
	,   .S_AXI_AWREGION     	(M_AXI_AWREGION 	)//unconnected
	,   .S_AXI_AWUSER       	(M_AXI_AWUSER   	)
	,   .S_AXI_AWVALID      	(M_AXI_AWVALID  	)
	,   .S_AXI_AWREADY      	(M_AXI_AWREADY  	)

	,   .S_AXI_WDATA        	(M_AXI_WDATA    	)
	,   .S_AXI_WSTRB        	(M_AXI_WSTRB    	)
	,   .S_AXI_WLAST        	(M_AXI_WLAST    	)
	,   .S_AXI_WUSER        	(M_AXI_WUSER    	)
	,   .S_AXI_WVALID       	(M_AXI_WVALID   	)
	,   .S_AXI_WREADY       	(M_AXI_WREADY   	)

	,   .S_AXI_BID          	(M_AXI_BID      	)
	,   .S_AXI_BRESP        	(M_AXI_BRESP    	)
	,   .S_AXI_BUSER        	(M_AXI_BUSER    	)
	,   .S_AXI_BVALID       	(M_AXI_BVALID   	)
	,   .S_AXI_BREADY       	(M_AXI_BREADY   	)

	,   .S_AXI_ARID         	(M_AXI_ARID     	)
	,   .S_AXI_ARADDR       	(M_AXI_ARADDR   	)
	,   .S_AXI_ARLEN        	(M_AXI_ARLEN    	)
	,   .S_AXI_ARSIZE       	(M_AXI_ARSIZE   	)
	,   .S_AXI_ARBURST      	(M_AXI_ARBURST  	)
	,   .S_AXI_ARLOCK       	(M_AXI_ARLOCK   	)
	,   .S_AXI_ARCACHE      	(M_AXI_ARCACHE  	)
	,   .S_AXI_ARPROT       	(M_AXI_ARPROT   	)
	,   .S_AXI_ARQOS        	(M_AXI_ARQOS    	)
	,   .S_AXI_ARREGION     	(M_AXI_ARREGION 	)//unconnected
	,   .S_AXI_ARUSER       	(M_AXI_ARUSER   	)
	,   .S_AXI_ARVALID      	(M_AXI_ARVALID  	)
	,   .S_AXI_ARREADY      	(M_AXI_ARREADY  	)

	,   .S_AXI_RID          	(M_AXI_RID      	)
	,   .S_AXI_RDATA        	(M_AXI_RDATA    	)
	,   .S_AXI_RRESP        	(M_AXI_RRESP    	)
	,   .S_AXI_RLAST        	(M_AXI_RLAST    	)
	,   .S_AXI_RUSER        	(M_AXI_RUSER    	)
	,   .S_AXI_RVALID       	(M_AXI_RVALID   	)
	,   .S_AXI_RREADY       	(M_AXI_RREADY   	)
);


Virtual_Axi_Lite_Stimulation #(
        .PAILLIER_MODE              (PAILLIER_MODE          )
    ,   .C_M_START_DATA_VALUE       ()
    ,   .C_M_TARGET_SLAVE_BASE_ADDR (32'h00000000           )
    ,   .C_M_AXI_ADDR_WIDTH         (C_S_AXI_ADDR_WIDTH     )
    ,   .C_M_AXI_DATA_WIDTH         (C_S_AXI_DATA_WIDTH     )
    ,   .C_M_TRANSACTIONS_NUM       (1)
)Virtual_Axi_Lite_Stimulation_inst(
        .INIT_AXI_TXN               (INIT_AXI_TXN           )
    ,   .ERROR                      ()
    ,   .TXN_DONE                   ()
    ,   .M_AXI_ACLK                 (S_LITE_AXI_ACLK        )
    ,   .M_AXI_ARESETN              (S_LITE_AXI_ARESETN     )
    ,   .M_AXI_AWADDR               (S_LITE_AXI_AWADDR      )
    ,   .M_AXI_AWPROT               (S_LITE_AXI_AWPROT      )
    ,   .M_AXI_AWVALID              (S_LITE_AXI_AWVALID     )
    ,   .M_AXI_AWREADY              (S_LITE_AXI_AWREADY     )
    ,   .M_AXI_WDATA                (S_LITE_AXI_WDATA       )
    ,   .M_AXI_WSTRB                (S_LITE_AXI_WSTRB       )
    ,   .M_AXI_WVALID               (S_LITE_AXI_WVALID      )
    ,   .M_AXI_WREADY               (S_LITE_AXI_WREADY      )
    ,   .M_AXI_BRESP                (S_LITE_AXI_BRESP       )
    ,   .M_AXI_BVALID               (S_LITE_AXI_BVALID      )
    ,   .M_AXI_BREADY               (S_LITE_AXI_BREADY      )
    ,   .M_AXI_ARADDR               (S_LITE_AXI_ARADDR      )
    ,   .M_AXI_ARPROT               (S_LITE_AXI_ARPROT      )
    ,   .M_AXI_ARVALID              (S_LITE_AXI_ARVALID     )
    ,   .M_AXI_ARREADY              (S_LITE_AXI_ARREADY     )
    ,   .M_AXI_RDATA                (S_LITE_AXI_RDATA       )
    ,   .M_AXI_RRESP                (S_LITE_AXI_RRESP       )
    ,   .M_AXI_RVALID               (S_LITE_AXI_RVALID      )
    ,   .M_AXI_RREADY               (S_LITE_AXI_RREADY      )
);


endmodule
