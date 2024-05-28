module paillier_top#(
        parameter K       = 128
    ,   parameter N       = 32
)(
        input                   clk
    ,   input                   rst_n   

    ,   input       [2:0]       task_cmd
    ,   input                   task_req

    ,   input       [K-1:0]     enc_g_data
    ,   input                   enc_g_valid
    ,   input       [K-1:0]     enc_m_data
    ,   input                   enc_m_valid
    ,   input       [K-1:0]     enc_r_data
    ,   input                   enc_r_valid
    ,   input       [K-1:0]     enc_n_data
    ,   input                   enc_n_valid

    ,   output  reg [K-1:0]     enc_out_data
    ,   output  reg             enc_out_valid
);

reg                     me_start_0      ;
reg     [K-1    : 0]    me_x_0          ;
reg                     me_x_valid_0    ;
reg     [K-1    : 0]    me_y_0          ;
reg                     me_y_valid_0    ;
wire    [K-1    : 0]    me_result_0     ;
wire                    me_valid_0      ;

reg                     me_start_1      ;
reg     [K-1    : 0]    me_x_1          ;
reg                     me_x_valid_1    ;
reg     [K-1    : 0]    me_y_1          ;
reg                     me_y_valid_1    ;
wire    [K-1    : 0]    me_result_1     ;
wire                    me_valid_1      ;

reg     [K-1            : 0]    me_result_0_storage     [N-1:0] ;
reg     [K-1            : 0]    me_result_1_storage     [N-1:0] ;
reg     [$clog2(N)-1    : 0]    me_result_0_cnt         =   0;
reg     [$clog2(N)-1    : 0]    me_result_1_cnt         =   0;


reg                             mm_ena_x                ;
reg                             mm_ena_y                ;
reg                             mm_ena_m                ;
wire    [2              : 0]    mm_ena                  ;
reg     [$clog2(N)-1    : 0]    mm_addr                 ;
reg     [$clog2(N)-1    : 0]    mm_addr_d1              ;
reg     [K-1            : 0]    mm_x                    ;
reg     [K-1            : 0]    mm_y                    ;
reg     [K-1            : 0]    mm_m                    ;
wire    [K-1            : 0]    mm_m1                   ;
wire    [K-1            : 0]    n_square    [N-1:0]     ;

reg                             mm_req                  ;
wire                            mm_end                  ;
wire                            mm_grant                ;
wire    [K-1            : 0]    mm_res                  ;


assign  mm_ena      =   {mm_ena_m,mm_ena_y,mm_ena_x};
assign  mm_m1       =   128'hb885007f9c90c3f3beb79b92378fe7f;//m1=(-1*(mod_inv(m,2**K)))%2**K
assign  n_square    =   '{
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

localparam  STA_IDLE                = 0,
            STA_ENCRYPTION_ME       = 1,
            STA_ENCRYPTION_MM       = 2,
            STA_DECRYPTION_ME       = 3,
            STA_DECRYPTION_L        = 4,
            STA_DECRYPTION_MM       = 5,
            STA_END                 = 7;

reg         [3:0]        state_now;
reg         [3:0]        state_next;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_now <= STA_IDLE;
    end
    else begin
        state_now <= state_next;
    end
end

always@(*) begin
    state_next = STA_IDLE;
    case(state_now)
        STA_IDLE: begin
            if(task_req) begin
                case(task_cmd)
                    3'b000:     state_next = STA_ENCRYPTION_ME;
                    3'b001:     state_next = STA_DECRYPTION_ME;
                    default:    state_next = STA_IDLE;
                endcase
            end
        end
        STA_ENCRYPTION_ME: begin
            if((me_result_0_cnt == N - 1) && (me_result_1_cnt == N - 1)) begin
                state_next  =   STA_ENCRYPTION_MM;
            end
            else begin
                state_next  =   STA_ENCRYPTION_ME;
            end
        end
        STA_ENCRYPTION_MM: begin
            if(mm_end) begin
                state_next  =   STA_IDLE;
            end
            else begin
                state_next  =   STA_ENCRYPTION_MM;
            end
        end
        default: begin
            state_next = STA_IDLE;
        end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        me_start_0          <=  0;
        me_x_0              <=  0;
        me_x_valid_0        <=  0;
        me_y_0              <=  0;
        me_y_valid_0        <=  0;
        me_start_1          <=  0;
        me_x_1              <=  0;
        me_x_valid_1        <=  0;
        me_y_1              <=  0;
        me_y_valid_1        <=  0;
        me_result_0_cnt     <=  0;
        me_result_1_cnt     <=  0;

        mm_addr             <=  0;
        mm_addr_d1          <=  0;
        mm_x                <=  0;
        mm_y                <=  0;
        mm_m                <=  0;
        mm_ena_x            <=  0;
        mm_ena_y            <=  0;
        mm_ena_m            <=  0;

        mm_req              <=  0;

        enc_out_data        <=  0;
        enc_out_valid       <=  0;
    end
    else begin
        mm_addr_d1          <=  mm_addr; 
        case(state_now)
            STA_IDLE: begin
                me_result_0_cnt         <=      0;
                me_result_1_cnt         <=      0;
                enc_out_data            <=      0;
                enc_out_valid           <=      0;
                mm_addr                 <=      0;
                if(state_next == STA_ENCRYPTION_ME) begin
                    me_start_0              <=      1;
                    me_start_1              <=      1;
                end
            end
            STA_ENCRYPTION_ME: begin
                me_start_0          <=      0;
                me_start_1          <=      0;
                me_x_0              <=      enc_g_data;
                me_x_valid_0        <=      enc_g_valid;
                me_y_0              <=      enc_m_data;
                me_y_valid_0        <=      enc_m_valid;
                me_x_1              <=      enc_r_data;
                me_x_valid_1        <=      enc_r_valid;
                me_y_1              <=      enc_n_data;
                me_y_valid_1        <=      enc_n_valid;
                if(me_valid_0) begin
                    me_result_0_storage[me_result_0_cnt]    <=      me_result_0;
                    me_result_0_cnt                         <=      (me_result_0_cnt < N-1) ? (me_result_0_cnt + 1) : me_result_0_cnt;
                end
                if(me_valid_1) begin
                    me_result_1_storage[me_result_1_cnt]    <=      me_result_1;
                    me_result_1_cnt                         <=      (me_result_1_cnt < N-1) ? (me_result_1_cnt + 1) : me_result_1_cnt;
                end
            end
            STA_ENCRYPTION_MM: begin
                mm_addr     <=  mm_addr < N - 1 ? mm_addr + 1 : mm_addr;
                if(mm_addr_d1 < N - 1) begin
                    mm_x        <=  me_result_0_storage[mm_addr];
                    mm_y        <=  me_result_1_storage[mm_addr];
                    mm_m        <=  n_square[mm_addr];
                    mm_ena_x    <=  1;
                    mm_ena_y    <=  1;
                    mm_ena_m    <=  1;
                    mm_req      <=  0;
                end
                else begin
                    mm_req      <=  1;
                    mm_ena_x    <=  0;
                    mm_ena_y    <=  0;
                    mm_ena_m    <=  0;
                end
                enc_out_data        <=  mm_res;
                enc_out_valid       <=  mm_grant;
            end
            default: begin
            end
        endcase
    end
end









me_iddmm_top #(
        .K              (K              )
    ,   .N              (N              )
)me_4096_inst_0(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .me_start       (me_start_0     )
    ,   .me_x           (me_x_0         )
    ,   .me_x_valid     (me_x_valid_0   )
    ,   .me_y           (me_y_0         )
    ,   .me_y_valid     (me_y_valid_0   )
    ,   .me_result      (me_result_0    )
    ,   .me_valid       (me_valid_0     )
);

me_iddmm_top #(
        .K              (K              )
    ,   .N              (N              )
)me_4096_inst_1(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .me_start       (me_start_1     )
    ,   .me_x           (me_x_1         )
    ,   .me_x_valid     (me_x_valid_1   )
    ,   .me_y           (me_y_1         )
    ,   .me_y_valid     (me_y_valid_1   )
    ,   .me_result      (me_result_1    )
    ,   .me_valid       (me_valid_1     )
);

mmp_iddmm_sp #(
        .MULT_METHOD    ("COMMON"       )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD    ("COMMON"       )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                            // 
    ,   .ADD2_METHOD    ("COMMON"       )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 
    ,   .MULT_LATENCY   (0              )
    ,   .ADD1_LATENCY   (0              )
    ,   .K              (K              )   // K bits in every group
    ,   .N              (N              )   // Number of groups
)mm_4096_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .wr_ena         (mm_ena         )
    ,   .wr_addr        (mm_addr_d1     )
    ,   .wr_x           (mm_x           )   //low words first
    ,   .wr_y           (mm_y           )   //low words first
    ,   .wr_m           (mm_m           )   //low words first
    ,   .wr_m1          (mm_m1          )

    ,   .task_req       (mm_req         )
    ,   .task_end       (mm_end         )
    ,   .task_grant     (mm_grant       )
    ,   .task_res       (mm_res         )    
);

// mmp_iddmm_sp #(
//         .MULT_METHOD    ("COMMON"       )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
//                                             // "TRADITION" :MULT_LATENCY=9                
//                                             // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
//     ,   .ADD1_METHOD    ("COMMON"       )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
//                                             // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
//                                             // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
//                                             // 
//     ,   .ADD2_METHOD    ("COMMON"       )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
//                                             // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
//                                             // 
//     ,   .MULT_LATENCY   (0              )
//     ,   .ADD1_LATENCY   (0              )
//     ,   .K              (K              )   // K bits in every group
//     ,   .N              (N              )   // Number of groups
// )mm_2048_inst(
//         .clk            (clk            )
//     ,   .rst_n          (rst_n          )

//     ,   .wr_ena         ()
//     ,   .wr_addr        ()
//     ,   .wr_x           ()   //low words first
//     ,   .wr_y           ()   //low words first
//     ,   .wr_m           ()   //low words first
//     ,   .wr_m1          ()

//     ,   .task_req       ()
//     ,   .task_end       ()
//     ,   .task_grant     ()
//     ,   .task_res       ()    
// );

// single_port_ram#(
//         .WIDTH_DATA     ( 1         )  
//     ,   .DEPTH          ( 0         )  
//     ,   .FILENAME       ( "none"    )
// )single_port_ram_n(
//         .clk            ()
//     ,   .wen            ()
//     ,   .addr           ()
//     ,   .wr_data        ()
//     ,   .rd_data        ()
// );

endmodule