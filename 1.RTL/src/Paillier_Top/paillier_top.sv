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
localparam ADDR_W   =   $clog2(N);

dual_port_ram#(
    `ifndef Modelsim_Sim
        .filename       ("../../../../../1.RTL/data/ram_lamda.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_lamda.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_lamda(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (me_addr            )
    ,   .rd_data        (ram_lamda_rd_data  )
);

dual_port_ram#(
    `ifndef Modelsim_Sim
        .filename       ("../../../../../1.RTL/data/ram_mu.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mu.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mu(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (mm_addr            )
    ,   .rd_data        (ram_mu_rd_data     )
);

dual_port_ram#(
    `ifndef Modelsim_Sim
        .filename       ("../../../../../1.RTL/data/ram_N.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_N.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_N(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (ram_N_rd_addr      )
    ,   .rd_data        (ram_N_rd_data      )
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_y(
        .clk            (clk                )
    ,   .wr_en          (ram_y_wr_en        )
    ,   .wr_addr        (ram_y_wr_addr      )
    ,   .wr_data        (ram_y_wr_data      )
    ,   .rd_en          (1                  )
    ,   .rd_addr        (mm_addr            )
    ,   .rd_data        (ram_y_rd_data      )
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_me_result(
        .clk            (clk                )
    ,   .wr_en          (me_valid_0         )
    ,   .wr_addr        (me_result_0_cnt    )
    ,   .wr_data        (me_result_0        )
    ,   .rd_en          (1                  )
    ,   .rd_addr        (ram_me_rd_addr     )
    ,   .rd_data        (ram_me_rd_data     )
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_result(
        .clk            (clk                )
    ,   .wr_en          (mm_valid_0         )
    ,   .wr_addr        (mm_result_0_cnt    )
    ,   .wr_data        (mm_result_0        )
    ,   .rd_en          (1                  )
    ,   .rd_addr        (ram_mm_rd_addr     )
    ,   .rd_data        (ram_mm_rd_data     )
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_L_result(
        .clk            (clk                )
    ,   .wr_en          (L_valid            )
    ,   .wr_addr        (L_result_cnt       )
    ,   .wr_data        (L_result           )
    ,   .rd_en          (1                  )
    ,   .rd_addr        (mm_addr            )
    ,   .rd_data        (ram_L_rd_data      )
);

reg     [ADDR_W-1       : 0]    ram_N_rd_addr           ;
wire    [K-1            : 0]    ram_N_rd_data           ;


wire    [K-1            : 0]    ram_lamda_rd_data       ;

wire    [K-1            : 0]    ram_mu_rd_data          ;

reg                             ram_y_wr_en             ;
reg     [ADDR_W-1       : 0]    ram_y_wr_addr           ;
reg     [K-1            : 0]    ram_y_wr_data           ;
wire    [K-1            : 0]    ram_y_rd_data           ;

reg     [ADDR_W-1       : 0]    ram_me_rd_addr          ;
wire    [K-1            : 0]    ram_me_rd_data          ;

reg     [ADDR_W-1       : 0]    ram_mm_rd_addr          ;
wire    [K-1            : 0]    ram_mm_rd_data          ;

wire    [K-1            : 0]    ram_L_rd_data           ;



reg     [K-1            : 0]    me_x_reg                ;
reg     [K-1            : 0]    me_y_reg                ;
reg                             me_start_0              ;
reg     [$clog2(N)-1    : 0]    me_addr                 ;
reg     [$clog2(N)-1    : 0]    me_addr_d1              ;
reg     [K-1            : 0]    me_x_0                  ;
reg                             me_x_valid_0            ;
reg     [K-1            : 0]    me_y_0                  ;
reg                             me_y_valid_0            ;
wire    [K-1            : 0]    me_result_0             ;
wire                            me_valid_0              ;
reg     [$clog2(N)-1    : 0]    me_result_0_cnt     =   0;


reg     [K-1            : 0]    mm_x_reg                ;
reg     [K-1            : 0]    mm_y_reg                ;
reg                             mm_start_0              ;
reg     [$clog2(N)-1    : 0]    mm_addr                 ;
reg     [$clog2(N)-1    : 0]    mm_addr_d1              ;
reg     [K-1            : 0]    mm_x_0                  ;
reg     [K-1            : 0]    mm_y_0                  ;
reg                             mm_x_valid_0            ;
reg                             mm_y_valid_0            ;
wire    [K-1            : 0]    mm_result_0             ;
wire                            mm_valid_0              ;
reg     [$clog2(N)-1    : 0]    mm_result_0_cnt     =   0;

reg                             L_start                 ;
reg     [$clog2(N)-1    : 0]    L_addr                  ;
reg     [$clog2(N)-1    : 0]    L_addr_d1               ;
reg     [K-1            : 0]    L_x                     ;
reg     [K-1            : 0]    L_y                     ;
reg                             L_data_valid            ;
wire    [K-1            : 0]    L_result                ;
wire                            L_valid                 ;

reg     [$clog2(N)-1    : 0]    L_result_cnt        =   0;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n | task_req)begin
        ram_y_wr_en         <=  0;
        ram_y_wr_addr       <=  0-1;
        ram_y_wr_data       <=  0;
    end
    else if(enc_m_valid) begin
        ram_y_wr_en         <=  1;
        ram_y_wr_addr       <=  ram_y_wr_addr + 1;
        ram_y_wr_data       <=  enc_m_data;
    end
    else begin
        ram_y_wr_en         <=  0;
        ram_y_wr_addr       <=  0-1;
        ram_y_wr_data       <=  0;
    end
end

//---------------------------------------------------------------//
always@(*) begin
    case(state_now)
        STA_ENCRYPTION_ME: begin
            ram_N_rd_addr   =   me_addr;
        end
        STA_ENCRYPTION_MM_STEP0: begin
            ram_N_rd_addr   =   mm_addr;
        end
        STA_DECRYPTION_L: begin
            ram_N_rd_addr   =   L_addr;
        end
        default: begin
            ram_N_rd_addr   =   0;
        end
    endcase
end

always@(*) begin
    case(state_now)
        STA_ENCRYPTION_MM_STEP1: begin
            ram_me_rd_addr  =   mm_addr;
        end
        STA_DECRYPTION_L: begin
            ram_me_rd_addr  =   L_addr;
        end
        default: begin
            ram_me_rd_addr  =   0;
        end
    endcase
end

always@(*) begin
    case(state_now)
        STA_ENCRYPTION_MM_STEP1: begin
            ram_mm_rd_addr  =   mm_addr;
        end
        default: begin
            ram_mm_rd_addr  =   0;
        end
    endcase
end

always@(*) begin
    case(state_now)
        STA_ENCRYPTION_ME: begin
            me_x_reg    =   me_x_0;
            me_y_reg    =   ram_N_rd_data;
        end
        STA_DECRYPTION_ME: begin
            me_x_reg    =   me_x_0;
            me_y_reg    =   ram_lamda_rd_data;
        end
        default: begin
            me_x_reg    =   me_x_0;
            me_y_reg    =   me_y_0;
        end
    endcase
end

always@(*) begin
    case(state_now) 
        STA_ENCRYPTION_MM_STEP0: begin
            mm_x_reg    =   ram_N_rd_data;
            mm_y_reg    =   ram_y_rd_data;
        end
        STA_ENCRYPTION_MM_STEP1: begin
            mm_x_reg    =   ram_me_rd_data;
            mm_y_reg    =   (mm_addr_d1 == 0) ? (ram_mm_rd_data + 1) : ram_mm_rd_data;//some problem here, if overflow, the result will be wrong.
        end
        STA_DECRYPTION_MM: begin
            mm_x_reg    =   ram_L_rd_data;
            mm_y_reg    =   ram_mu_rd_data;
        end
        default: begin
            mm_x_reg    =   mm_x_0;
            mm_y_reg    =   mm_y_0;
        end
    endcase
end

always@(*) begin
    L_x         =       (L_addr_d1 == 0) ? (ram_me_rd_data - 1) : ram_me_rd_data;//some problem here, if overflow, the result will be wrong.
    L_y         =       ram_N_rd_data;
end


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
            else begin
                state_next  =   STA_DECRYPTION_ME;
            end
        end
        STA_DECRYPTION_L: begin
            if(L_result_cnt == N - 1) begin
                state_next  =   STA_DECRYPTION_MM;
            end
            else begin
                state_next  =   STA_DECRYPTION_L;
            end
        end
        STA_DECRYPTION_MM: begin
            if(mm_result_0_cnt == N - 1) begin
                state_next  =   STA_IDLE;
            end
            else begin
                state_next  =   STA_DECRYPTION_MM;
            end
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
        mm_start_0          <=  0;
        mm_x_0              <=  0;
        mm_y_0              <=  0;
        mm_x_valid_0        <=  0;
        mm_y_valid_0        <=  0;
        mm_result_0_cnt     <=  0;


        L_addr              <=  0;
        L_addr_d1           <=  0;
        L_start             <=  0;
        L_data_valid        <=  0;
        L_result_cnt        <=  0;

        enc_out_data        <=  0;
        enc_out_valid       <=  0;

        task_end            <=  0;
    end
    else begin
        mm_addr_d1          <=  mm_addr; 
        me_addr_d1          <=  me_addr;
        L_addr_d1           <=  L_addr;
        case(state_now)
            STA_IDLE: begin
                me_result_0_cnt     <=      0;
                mm_result_0_cnt     <=      0;
                L_result_cnt        <=      0;
                mm_addr             <=      0;
                me_addr             <=      0;
                L_addr              <=      0;
                task_end            <=      0;
                enc_out_data        <=      0;
                enc_out_valid       <=      0;
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
                    me_y_valid_0        <=  1;
                end
                else begin
                    me_y_0              <=  0;
                    me_y_valid_0        <=  0;
                end
                if(me_valid_0) begin
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
                me_addr             <=      me_addr < N - 1 ? me_addr + 1 : me_addr;
                me_x_0              <=      dec_c_data;
                me_x_valid_0        <=      dec_c_valid;
                if(me_addr_d1 < N - 1) begin
                    me_y_valid_0        <=  1;
                end
                else begin
                    me_y_0              <=  0;
                    me_y_valid_0        <=  0;
                end
                if(me_valid_0) begin
                    me_result_0_cnt                         <=      (me_result_0_cnt < N-1) ? (me_result_0_cnt + 1) : me_result_0_cnt;
                end

                if(state_next   ==  STA_DECRYPTION_L) begin
                    L_addr              <=  0;
                    L_start             <=  1;
                end
            end
            STA_DECRYPTION_L: begin
                L_start             <=  0;
                L_addr              <=  L_addr < N - 1 ? L_addr + 1 : L_addr;
                if(L_addr_d1 < N - 1) begin
                    L_data_valid        <=  1;
                end
                else begin
                    L_data_valid        <=  0;
                end

                if(L_valid) begin
                    L_result_cnt                        <=  L_result_cnt + 1;
                end

                if(state_next   ==  STA_DECRYPTION_MM) begin
                    mm_addr             <=  0;
                    mm_start_0          <=  1;
                end
            end
            STA_DECRYPTION_MM: begin
                mm_start_0          <=  0;
                if(!mm_start_0) begin//delay 1 cycle to clear mm_addr_d1
                    mm_addr             <=  mm_addr < N - 1 ? mm_addr + 1 : mm_addr;
                end
                if(mm_addr_d1 < N - 1) begin
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

NR_Div L_Func(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .valid_in       (L_start        )

    ,   .x              (L_x            )
    ,   .y              (L_y            )
    ,   .data_vld_in    (L_data_valid   )

    ,   .qblock         (L_result       )
    ,   .data_vld_out   (L_valid        )
);

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
)montgomery_iddmm_top_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .mm_start       (mm_start_0     )
    ,   .mm_x           (mm_x_reg       )
    ,   .mm_x_valid     (mm_x_valid_0   )
    ,   .mm_y           (mm_y_reg       )
    ,   .mm_y_valid     (mm_y_valid_0   )
    ,   .mm_result      (mm_result_0    )
    ,   .mm_valid       (mm_valid_0     )

    ,   .me_start       (me_start_0     )
    ,   .me_x           (me_x_reg       )
    ,   .me_x_valid     (me_x_valid_0   )
    ,   .me_y           (me_y_reg       )
    ,   .me_y_valid     (me_y_valid_0   )
    ,   .me_result      (me_result_0    )
    ,   .me_valid       (me_valid_0     )
);



endmodule