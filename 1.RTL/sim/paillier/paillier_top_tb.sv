module paillier_top_tb();


parameter K       = 128 ;
parameter N       = 32  ;

reg     clk = 0;
reg     rst_n = 0;

always #5 clk = ~clk;
initial #100 rst_n = 1;



wire    [K-1    :   0]     PAILLIER_N               [N-1:0];
wire    [K-1    :   0]     PAILLIER_N_SQUARE        [N-1:0];
wire    [K-1    :   0]     PAILLIER_G               [N-1:0];
wire    [K-1    :   0]     PAILLIER_M               [N-1:0];
wire    [K-1    :   0]     PAILLIER_R               [N-1:0];

assign  PAILLIER_N          =       {
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'hc1df05419c6057e26ebad2d3abd7123c,
    128'hdd612c4cf0c09d1881f83b3ea46ad2f1,
    128'h239e21d0a3a778cfbfa9f4f46a0f355c,
    128'h3c57d0305706482133aa5b0aa7d96179,
    128'h8442d0c0a2d7fd48359690c361c66fa0,
    128'hdc7131e9dcf83e11cab3812b22861546,
    128'ha5be250c5ab7d671d5e6129b0ef708e1,
    128'h5d2d0ed5bde948bf5c4339c0d7e45b9,
    128'hc3ac4ef3c50af15fbd37492f126c5a51,
    128'h8af725228255ab1b6ecab2f668149e3f,
    128'hf74e3cd371e7fadf3edb24476ca0632f,
    128'ha53d0af0840ed39b736a5f08339a21e3,
    128'h5a53aa612f73dabd6864bf2dc85b296b,
    128'h4e2a2bddcdabdae21b8c938d1c95d327,
    128'h8213cc126746497a511d8d29aea5ac13,
    128'hd2c5de79b62fb1a1a8e12114c110a8bf
};
assign  PAILLIER_N_SQUARE   =       {
    128'h92d20837163355491353a40bfbed6aff,
    128'hfb000939ca99e2dcb7e96c94d9e6ff1b,
    128'h54db47d62fa87283db4ef47e8119e2cb,
    128'hd126f44ef110cd64d6493014fbee11f,
    128'hce25ad01515ed88bef11f595cc5b107a,
    128'hed44c3aecf42318a0e9dc2431934703c,
    128'h219abc2ee926037fbd46e2b2465b19b3,
    128'h110e3ccdbdfbe0daadefe22a725ef38b,
    128'hc2371fdc5e9cfb439ea6ac84b3e424e7,
    128'h1cc3a263dc8cb4642042d01abe4e5441,
    128'h6d821fae3e588950e16d5bdc76fc0629,
    128'hb4829eabad9ad1535fc322dc0ad791ca,
    128'h8a353157ab771cc0eafb621a07b0ce09,
    128'h98a65541754ffeedb756ff3ca3b606de,
    128'ha2b63fa2483a5dda07c17496f556f441,
    128'he4c09fbb079cbbb8279c01fca24b56bf,
    128'h32e9902603d670439cee8a4f9730281c,
    128'ha7e736783300f69b64cce28fb565b995,
    128'h99758f8c8e5d58ce03af202cfe8d8809,
    128'h2884f15b5a76578db8bf6a32cf7e2d78,
    128'ha758c60de9e6cf037bd2a6c7d22c670b,
    128'h8b384722fef18a9870588c1368f3c1f8,
    128'h2caa709eff78cfdb2a3594bce3977875,
    128'hc0c30e464a5fc136225c7e206ba599b1,
    128'h4ec856a9a230bca081331c969774eb11,
    128'h2295c0670d4cb20723ceaa02e0ff4879,
    128'ha508052dad14c59f1787572686d68c51,
    128'heb3ce8f505e141803ec18bc77c4986a7,
    128'hea1dd24c13c7bb976496361ad38078e2,
    128'hdaaf39f049a489793e2b46643b3eb3f1,
    128'h68a3ad29eb4accb4ca422e7dd70e809f,
    128'h4ad5ed15d295f6765773bb5d851b3e81
};
assign  PAILLIER_M          =       {
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h1000000019091
};
assign  PAILLIER_R          =       {
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h100000000000007b
};

generate
    for(genvar i = 1; i < N; i = i + 1) begin
        assign PAILLIER_G[i] = PAILLIER_N[i];
    end
endgenerate
assign PAILLIER_G[0] = PAILLIER_N[0] + 1; 







reg     [2  :0]     task_cmd        ;
reg                 task_req        ;

reg     [K-1:0]     enc_g_data      ;
reg                 enc_g_valid     ;
reg     [K-1:0]     enc_m_data      ;
reg                 enc_m_valid     ;
reg     [K-1:0]     enc_r_data      ;
reg                 enc_r_valid     ;
reg     [K-1:0]     enc_n_data      ;
reg                 enc_n_valid     ;

wire    [K-1:0]     enc_out_data    ;
wire                enc_out_valid   ;

reg     [K*N-1  :   0]     PAILLIER_ENC_RESULT;

paillier_top #(
        .K                  (128                )
    ,   .N                  (32                 )
)paillier_top_inst(
        .clk                (clk                )
    ,   .rst_n              (rst_n              )
    ,   .task_cmd           (task_cmd           )
    ,   .task_req           (task_req           )
    ,   .enc_g_data         (enc_g_data         )
    ,   .enc_g_valid        (enc_g_valid        )
    ,   .enc_m_data         (enc_m_data         )
    ,   .enc_m_valid        (enc_m_valid        )
    ,   .enc_r_data         (enc_r_data         )
    ,   .enc_r_valid        (enc_r_valid        )
    ,   .enc_n_data         (enc_n_data         )
    ,   .enc_n_valid        (enc_n_valid        )
    ,   .enc_out_data       (enc_out_data       )
    ,   .enc_out_valid      (enc_out_valid      )
);



initial begin
    task_cmd    <=  3'b000;
    task_req    <=  0;
    enc_g_data  <=  0;
    enc_m_data  <=  0;
    enc_r_data  <=  0;
    enc_n_data  <=  0;
    enc_g_valid <=  0;
    enc_m_valid <=  0;
    enc_r_valid <=  0;
    enc_n_valid <=  0;

    @(posedge rst_n);
    #40
    @(posedge clk);
    task_req    <=  1;
    @(posedge clk);
    task_req    <=  0;
    for(integer i = 0; i < 32; i = i + 1) begin
        @(posedge clk);
        enc_g_data  <=  PAILLIER_G[i];
        enc_m_data  <=  PAILLIER_M[i];
        enc_r_data  <=  PAILLIER_R[i];
        enc_n_data  <=  PAILLIER_N[i];
        enc_g_valid <=  1;
        enc_m_valid <=  1;
        enc_r_valid <=  1;
        enc_n_valid <=  1;
    end
    @(posedge clk);
    enc_g_valid <=  0;
    enc_m_valid <=  0;
    enc_r_valid <=  0;
    enc_n_valid <=  0;
    wait(enc_out_valid);
    PAILLIER_ENC_RESULT      = {PAILLIER_ENC_RESULT[(K*N-K-1):0],enc_out_data};
    for (integer i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        PAILLIER_ENC_RESULT      = {enc_out_data,PAILLIER_ENC_RESULT[(K*N-1):K]};
    end
    $display("paillier encoder result: \n0x%x\n",PAILLIER_ENC_RESULT);
    #100;
    $stop;

end




















endmodule