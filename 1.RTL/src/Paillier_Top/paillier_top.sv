module paillier_top#(
        parameter MULT_METHOD   = "TRADITION"   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                                // "TRADITION" :MULT_LATENCY=9                
                                                // "VEDIC8"    :VEDIC MULT, MULT_LATENCY=8 
    ,   parameter ADD1_METHOD   = "3-2_PIPE1"   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                                // "3-2_PIPE2" :classic pipeline adder,stage 2,ADD1_LATENCY=2
                                                // "3-2_PIPE1" :classic pipeline adder,stage 1,ADD1_LATENCY=1
                                                // 
    ,   parameter ADD2_METHOD   = "3-2_DELAY2"  // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                                // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                                // 
    ,   parameter K             = 128
    ,   parameter N             = 32
)(
        input                   clk
    ,   input                   rst_n   

    ,   input       [1  :0]     task_cmd
    ,   input                   task_req
    ,   output  reg             task_end

    ,   input       [K-1:0]     enc_m_data
    ,   input                   enc_m_valid
    ,   input       [K-1:0]     enc_r_data
    ,   input                   enc_r_valid

    ,   input       [K-1:0]     dec_c_data
    ,   input                   dec_c_valid
    ,   input       [K-1:0]     dec_lambda_data
    ,   input                   dec_lambda_valid
    ,   input       [K-1:0]     dec_n_data
    ,   input                   dec_n_valid

    ,   input       [K-1:0]     homo_add_c1
    ,   input                   homo_add_c1_valid
    ,   input       [K-1:0]     homo_add_c2
    ,   input                   homo_add_c2_valid

    ,   input       [K-1:0]     scalar_mul_c1
    ,   input                   scalar_mul_c1_valid
    ,   input       [K-1:0]     scalar_mul_const
    ,   input                   scalar_mul_const_valid

    ,   output  reg [K-1:0]     enc_out_data
    ,   output  reg             enc_out_valid
);
wire    [K-1    :   0]     PAILLIER_N               [N-1:0];
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

reg                             me_start_0              ;
reg     [$clog2(N)-1    : 0]    me_addr                 ;
reg     [$clog2(N)-1    : 0]    me_addr_d1              ;
reg     [K-1            : 0]    me_x_0                  ;
reg                             me_x_valid_0            ;
reg     [K-1            : 0]    me_y_0                  ;
reg                             me_y_valid_0            ;
wire    [K-1            : 0]    me_result_0             ;
wire                            me_valid_0              ;

reg     [K-1            : 0]    me_result_0_storage     [N-1:0] ;
reg     [$clog2(N)-1    : 0]    me_result_0_cnt     =   0;


reg                             mm_start_0              ;
reg     [$clog2(N)-1    : 0]    mm_addr                 ;
reg     [$clog2(N)-1    : 0]    mm_addr_d1              ;
reg     [K-1            : 0]    mm_x_0                  ;
reg     [K-1            : 0]    mm_y_0                  ;
reg                             mm_x_valid_0            ;
reg                             mm_y_valid_0            ;
wire    [K-1            : 0]    mm_result_0             ;
wire                            mm_valid_0              ;

reg     [K-1            : 0]    mm_result_0_storage     [N-1:0] ;
reg     [$clog2(N)-1    : 0]    mm_result_0_cnt     =   0;

//could be optimized begin
reg     [K-1            : 0]    enc_tem_buf_for_m       [N-1:0] ;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(int i = 0; i < N; i = i + 1) begin
            enc_tem_buf_for_m[i]    <=  0;
        end
    end
    else if(enc_m_valid) begin
        enc_tem_buf_for_m[N-1]    <=  enc_m_data;
        for(int i = N-2; i >= 0; i = i - 1) begin
            enc_tem_buf_for_m[i]    <=  enc_tem_buf_for_m[i+1];
        end
    end
end
//could be optimized end

localparam  STA_IDLE                = 0,
            STA_ENCRYPTION_ME       = 1,
            STA_ENCRYPTION_MM_STEP0 = 2,
            STA_ENCRYPTION_MM_STEP1 = 3,
            STA_DECRYPTION_ME       = 4,
            STA_DECRYPTION_L        = 5,
            STA_DECRYPTION_MM       = 6,
            STA_HOMOMORPHIC_ADD     = 7,
            STA_SCALAR_MUL          = 8,
            STA_END                 = 9;

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
                    2'b00:     state_next = STA_ENCRYPTION_ME;
                    2'b01:     state_next = STA_DECRYPTION_ME;
                    2'b10:     state_next = STA_HOMOMORPHIC_ADD;
                    2'b11:     state_next = STA_SCALAR_MUL;
                    default:    state_next = STA_IDLE;
                endcase
            end
        end
        STA_ENCRYPTION_ME: begin
            if(me_result_0_cnt == N - 1) begin
                state_next  =   STA_ENCRYPTION_MM_STEP0;
            end
            else begin
                state_next  =   STA_ENCRYPTION_ME;
            end
        end
        STA_ENCRYPTION_MM_STEP0: begin
            if(mm_result_0_cnt == N - 1) begin
                state_next  =   STA_ENCRYPTION_MM_STEP1;
            end
            else begin
                state_next  =   STA_ENCRYPTION_MM_STEP0;
            end
        end
        STA_ENCRYPTION_MM_STEP1: begin
            if(mm_result_0_cnt == N - 1) begin
                state_next  =   STA_IDLE;
            end
            else begin
                state_next  =   STA_ENCRYPTION_MM_STEP1;
            end
        end
        STA_DECRYPTION_ME: begin
            if(me_result_0_cnt == N - 1) begin
                state_next  =   STA_DECRYPTION_L;
            end
        end
        STA_DECRYPTION_L: begin

        end
        STA_HOMOMORPHIC_ADD: begin
            if(mm_result_0_cnt == N - 1) begin
                state_next  =   STA_IDLE;
            end
            else begin
                state_next  =   STA_HOMOMORPHIC_ADD;
            end
        end
        STA_SCALAR_MUL: begin
            if(me_result_0_cnt == N - 1) begin
                state_next  =   STA_IDLE;
            end
            else begin
                state_next  =   STA_SCALAR_MUL;
            end
        end
        default: begin
            state_next = STA_IDLE;
        end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        me_addr             <=  0;
        me_addr_d1          <=  0;
        me_start_0          <=  0;
        me_x_0              <=  0;
        me_x_valid_0        <=  0;
        me_y_0              <=  0;
        me_y_valid_0        <=  0;
        me_result_0_cnt     <=  0;

        mm_addr             <=  0;
        mm_addr_d1          <=  0;
        mm_x_0              <=  0;
        mm_y_0              <=  0;
        mm_x_valid_0        <=  0;
        mm_y_valid_0        <=  0;
        mm_start_0          <=  0;
        mm_result_0_cnt     <=  0;

        enc_out_data        <=  0;
        enc_out_valid       <=  0;

        task_end            <=  0;
    end
    else begin
        mm_addr_d1          <=  mm_addr; 
        me_addr_d1          <=  me_addr;
        case(state_now)
            STA_IDLE: begin
                me_result_0_cnt     <=      0;
                mm_result_0_cnt     <=      0;
                enc_out_data        <=      0;
                enc_out_valid       <=      0;
                task_end            <=      0;
                mm_addr             <=      0;
                me_addr             <=      0;
                if(state_next == STA_ENCRYPTION_ME) begin
                    me_start_0          <=      1;
                end
                if((state_next == STA_SCALAR_MUL) | (state_next == STA_DECRYPTION_ME)) begin
                    me_start_0          <=      1;
                end
                if(state_next   ==  STA_HOMOMORPHIC_ADD) begin
                    mm_start_0          <=      1;
                end
            end
            STA_ENCRYPTION_ME: begin
                me_start_0          <=      0;
                me_addr             <=      me_addr < N - 1 ? me_addr + 1 : me_addr;
                me_x_0              <=      enc_r_data;
                me_x_valid_0        <=      enc_r_valid;
                if(me_addr_d1 < N - 1) begin
                    me_y_0              <=  PAILLIER_N[me_addr];
                    me_y_valid_0        <=  1;
                end
                else begin
                    me_y_0              <=  0;
                    me_y_valid_0        <=  0;
                end
                if(me_valid_0) begin
                    me_result_0_storage[me_result_0_cnt]    <=      me_result_0;
                    me_result_0_cnt                         <=      (me_result_0_cnt < N-1) ? (me_result_0_cnt + 1) : me_result_0_cnt;
                end

                if(state_next   ==  STA_ENCRYPTION_MM_STEP0) begin
                    mm_addr             <=  0;
                    mm_start_0          <=  1;
                end
            end
            STA_ENCRYPTION_MM_STEP0: begin
                mm_start_0          <=  0;
                mm_addr             <=  mm_addr < N - 1 ? mm_addr + 1 : mm_addr;
                if(mm_addr_d1 < N - 1) begin
                    mm_x_0              <=  PAILLIER_N[mm_addr];
                    mm_y_0              <=  enc_tem_buf_for_m[mm_addr];
                    mm_x_valid_0        <=  1;
                    mm_y_valid_0        <=  1;
                end
                else begin
                    mm_x_valid_0        <=  0;
                    mm_y_valid_0        <=  0;
                end
                if(mm_valid_0) begin
                    mm_result_0_cnt     <=  mm_result_0_cnt + 1;
                    //some problem here, if overflow, the result will be wrong.
                    mm_result_0_storage[mm_result_0_cnt]    <=      mm_result_0_cnt == 0 ? (mm_result_0 + 1) : mm_result_0;
                end

                if(state_next   ==  STA_ENCRYPTION_MM_STEP1) begin
                    mm_addr             <=  0;
                    mm_start_0          <=  1;
                end
            end
            STA_ENCRYPTION_MM_STEP1: begin
                mm_start_0          <=  0;
                if(!mm_start_0) begin//delay 1 cycle to clear mm_addr_d1
                    mm_addr             <=  mm_addr < N - 1 ? mm_addr + 1 : mm_addr;
                end
                if(mm_addr_d1 < N - 1) begin
                    mm_x_0              <=  me_result_0_storage[mm_addr];
                    mm_y_0              <=  mm_result_0_storage[mm_addr];
                    mm_x_valid_0        <=  1;
                    mm_y_valid_0        <=  1;
                end
                else begin
                    mm_x_valid_0        <=  0;
                    mm_y_valid_0        <=  0;
                end
                if(mm_valid_0) begin
                    mm_result_0_cnt     <=  mm_result_0_cnt + 1;
                end
                enc_out_data        <=  mm_result_0;
                enc_out_valid       <=  mm_valid_0;
                if(mm_result_0_cnt == N - 1) begin
                    task_end        <=  1;
                end
            end
            STA_DECRYPTION_ME: begin
                me_start_0          <=      0;
                me_x_0              <=      dec_c_data;
                me_x_valid_0        <=      dec_c_valid;
                me_y_0              <=      dec_lambda_data;
                me_y_valid_0        <=      dec_lambda_valid;
                if(me_valid_0) begin
                    me_result_0_storage[me_result_0_cnt]    <=      me_result_0;
                    me_result_0_cnt                         <=      (me_result_0_cnt < N-1) ? (me_result_0_cnt + 1) : me_result_0_cnt;
                end
            end
            STA_HOMOMORPHIC_ADD: begin
                mm_start_0          <=  0;
                mm_x_0              <=  homo_add_c1;
                mm_y_0              <=  homo_add_c2;
                mm_x_valid_0        <=  homo_add_c1_valid;
                mm_y_valid_0        <=  homo_add_c2_valid;
                if(mm_valid_0) begin
                    mm_result_0_cnt     <=  mm_result_0_cnt + 1;
                end
                enc_out_data        <=  mm_result_0;
                enc_out_valid       <=  mm_valid_0;
                if(mm_result_0_cnt == N - 1) begin
                    task_end        <=  1;
                end
            end
            STA_SCALAR_MUL: begin
                me_start_0          <=      0;
                me_x_0              <=      scalar_mul_c1;
                me_x_valid_0        <=      scalar_mul_c1_valid;
                me_y_0              <=      scalar_mul_const;
                me_y_valid_0        <=      scalar_mul_const_valid;
                if(me_valid_0) begin
                    me_result_0_cnt     <=      (me_result_0_cnt < N-1) ? (me_result_0_cnt + 1) : me_result_0_cnt;
                end
                enc_out_data        <=  me_result_0;
                enc_out_valid       <=  me_valid_0;
                if(me_result_0_cnt == N - 1) begin
                    task_end        <=  1;
                end
            end
            default: begin
            end
        endcase
    end
end

montgomery_iddmm_top #(
        .MULT_METHOD    (MULT_METHOD    )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD    (ADD1_METHOD    )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                            // 
    ,   .ADD2_METHOD    (ADD2_METHOD    )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 
    ,   .K              (K              )
    ,   .N              (N              )
)montgomery_iddmm_top(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .mm_start       (mm_start_0     )
    ,   .mm_x           (mm_x_0         )
    ,   .mm_x_valid     (mm_x_valid_0   )
    ,   .mm_y           (mm_y_0         )
    ,   .mm_y_valid     (mm_y_valid_0   )
    ,   .mm_result      (mm_result_0    )
    ,   .mm_valid       (mm_valid_0     )

    ,   .me_start       (me_start_0     )
    ,   .me_x           (me_x_0         )
    ,   .me_x_valid     (me_x_valid_0   )
    ,   .me_y           (me_y_0         )
    ,   .me_y_valid     (me_y_valid_0   )
    ,   .me_result      (me_result_0    )
    ,   .me_valid       (me_valid_0     )
);



endmodule