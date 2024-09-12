module paillier_axi_top#(
// Users to add parameters here
        parameter BLOCK_COUNT   = 29
	,	parameter K             = 128
    ,   parameter N             = 32
//----------------------------------------------------
// parameter of AXI-FULL slave port
		// Base address of targeted slave
	,   parameter  TARGET_RD_ADDR   = 64'h0_0000_0000
	,   parameter  TARGET_WR_ADDR   = 64'h1_0000_0000
)(
//----------------------------------------------------
// AXI-LITE slave port
        input           S_AXI_ACLK
    ,   input           S_AXI_ARESETN
    ,   tvip_axi_if     AXI_LITE_IF

//----------------------------------------------------
// AXI-FULL master port
    ,   input           M_AXI_ACLK
    ,   input           M_AXI_ARESETN
    ,   tvip_axi_if     AXI_FULL_IF
);
    genvar o;

//----------------------------------------------------
// wire definition

    wire                        rd_rdy                  [0 : BLOCK_COUNT - 1]   ;
    wire    [K-1:0]             rd_dout                 [0 : BLOCK_COUNT - 1]   ;
    wire    [$clog2(N):0]       rd_cnt                  [0 : BLOCK_COUNT - 1]   ;

    wire    		            paillier_start                                  ;
    wire    [1:0]	            paillier_mode                                   ;
    wire    [31:0]	            paillier_counts                                 ;
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

    //----------------------------------------------------
    // AXI-FULL parameters
	,   .TARGET_WR_ADDR         (TARGET_WR_ADDR         )
	,   .TARGET_RD_ADDR         (TARGET_RD_ADDR         )
)u_axi_full_core(
//----------------------------------------------------
// paillier control interface
        .paillier_start         (paillier_start         )
    ,   .paillier_mode          (paillier_mode          )
    ,   .paillier_counts        (paillier_counts        )
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

    ,   .AXI_FULL_IF            (AXI_FULL_IF            )
);


saxi_lite_core u_saxi_lite_core(
//----------------------------------------------------
// paillier control interface
        .paillier_start         (paillier_start         )
    ,   .paillier_mode          (paillier_mode          )
    ,   .paillier_counts        (paillier_counts        )
    ,   .paillier_finished      (paillier_finished      )

//----------------------------------------------------
// AXI-LITE slave port
    ,   .S_AXI_ACLK             (S_AXI_ACLK             )
    ,   .S_AXI_ARESETN          (S_AXI_ARESETN          )
    
    ,   .AXI_LITE_IF            (AXI_LITE_IF            )
);

generate 
    for(o = 0; o < BLOCK_COUNT; o = o + 1) begin
        paillier_top #( 
                .K                          (K                          )
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
        fifo_ram # (
                .DATA_WIDTH (K                      )
            ,   .DATA_DEPTH (N                      )
        )fifo_inst (
                .clk        (M_AXI_ACLK             )

            ,   .wr_en      (enc_out_valid  [o]     )
            ,   .wr_data    (enc_out_data   [o]     )
            ,   .wr_full    ()

            ,   .rd_en      (rd_rdy         [o]     )
            ,   .rd_data    (rd_dout        [o]     )
            ,   .rd_empty   ()
            ,   .rd_cnt     (rd_cnt         [o]     )
        );
    end
endgenerate

endmodule