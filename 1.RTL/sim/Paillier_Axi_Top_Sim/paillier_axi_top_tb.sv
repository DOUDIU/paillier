`timescale 1ns / 1ps

module paillier_axi_top_tb();

reg                 M_AXI_ACLK          ;
reg                 M_AXI_ARESETN       ;
wire                S_LITE_AXI_ACLK     ;
wire                S_LITE_AXI_ARESETN  ;
reg                 INIT_AXI_TXN        ;

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

parameter   PAILLIER_MODE           = STA_SCALAR_MUL;
parameter   BLOCK_COUNT             = 1;
parameter   TEST_TIMES              = 1;

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
)paillier_axi_top_inst(
//----------------------------------------------------
// AXI-FULL master port
        .M_AXI_ACLK                 (M_AXI_ACLK             )
    ,   .M_AXI_ARESETN              (M_AXI_ARESETN          )

    ,   .AXI_FULL_IF                (AXI_FULL_IF            )
//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK                 (S_LITE_AXI_ACLK        )
    ,   .S_AXI_ARESETN              (S_LITE_AXI_ARESETN     )

    ,   .AXI_LITE_IF                (AXI_LITE_IF            )
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
