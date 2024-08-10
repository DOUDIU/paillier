`timescale 1ns / 1ps

module paillier_axi_top_tb();

reg                                     M_AXI_ACLK              ;
reg                                     M_AXI_ARESETN           ;
wire                                    S_LITE_AXI_ACLK         ;
wire                                    S_LITE_AXI_ARESETN      ;

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

tvip_axi_if AXI_FULL_IF(M_AXI_ACLK, M_AXI_ARESETN);
tvip_axi_if AXI_LITE_IF(S_LITE_AXI_ACLK, S_LITE_AXI_ARESETN);

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
)paillier_axi_top_inst(
//----------------------------------------------------
// AXI-FULL master port
        .M_AXI_ACLK             (M_AXI_ACLK         )
    ,   .M_AXI_ARESETN          (M_AXI_ARESETN      )

    ,   .AXI_FULL_IF            (AXI_FULL_IF        )
//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK             (S_LITE_AXI_ACLK    )
    ,   .S_AXI_ARESETN          (S_LITE_AXI_ARESETN )

    ,   .AXI_LITE_IF            (AXI_LITE_IF        )
);

//Virtual AXI-FULL MEMORY 
Virtual_Axi_Full_Memory # ( 
        .PAILLIER_MODE          (PAILLIER_MODE      )
    ,   .TEST_TIMES             (TEST_TIMES         )
)Virtual_Axi_Full_Memory_Inst (
		.S_AXI_ACLK         	(M_AXI_ACLK         )
	,   .S_AXI_ARESETN      	(M_AXI_ARESETN      )

    ,   .AXI_FULL_IF           	(AXI_FULL_IF        )
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
