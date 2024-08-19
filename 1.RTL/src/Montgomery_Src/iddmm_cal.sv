module iddmm_cal#(
        parameter K = 128                       // K bits in every group
    ,   parameter N = 32                        // Number of groups
    ,   parameter ADDR_W = $clog2(N)
)(
        input                       clk
    ,   input                       rst_n

    ,   input   [ADDR_W-1   :0]     i_cnt
    ,   input   [ADDR_W     :0]     j_cnt

    ,   input   [K-1        :0]     a
    ,   input   [K-1        :0]     x
    ,   input   [K-1        :0]     y
    ,   input   [K-1        :0]     p
    ,   input   [K-1        :0]     p1

    ,   output                      wr_a_en
    ,   output  [ADDR_W     :0]     wr_a_addr
    ,   output  [K-1        :0]     wr_a_data
);
integer i,j,k;

wire    [127    :0] u                       ;
wire    [127    :0] c                       ;
reg                 carry                   ;

//pipe stage 0 ( 9 cycles )
wire    [255        :0]     result_x_mul_y          ;
reg     [127        :0]     p_stage_0_d     [0:8]   ;
reg     [127        :0]     a_stage_0_d     [0:8]   ;
reg                         carry_stage_0_d [0:8]   ;
reg     [ADDR_W-1   :0]     i_cnt_stage_0_d [0:8]   ;
reg     [ADDR_W     :0]     j_cnt_stage_0_d [0:8]   ;

iddmm_mul_128_to_256 iddmm_mul_0(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .x              (x                  )
    ,   .y              (y                  )
    ,   .result         (result_x_mul_y     )
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 9; i = i + 1)begin
            p_stage_0_d[i]      <= 0;
            a_stage_0_d[i]      <= 0;
            carry_stage_0_d[i]  <= 0;
            i_cnt_stage_0_d[i]  <= 0;
            j_cnt_stage_0_d[i]  <= 0;
        end
    end
    else begin
        p_stage_0_d[0] <= p;
        a_stage_0_d[0] <= a;
        carry_stage_0_d[0] <= carry;
        i_cnt_stage_0_d[0] <= i_cnt;
        j_cnt_stage_0_d[0] <= j_cnt;
        for(i = 1; i < 9; i = i + 1)begin
            p_stage_0_d[i] <= p_stage_0_d[i - 1];
            a_stage_0_d[i] <= a_stage_0_d[i - 1];
            carry_stage_0_d[i] <= carry_stage_0_d[i - 1];
            i_cnt_stage_0_d[i] <= i_cnt_stage_0_d[i - 1];
            j_cnt_stage_0_d[i] <= j_cnt_stage_0_d[i - 1];
        end
    end
end

//pipe stage 1 ( 1 cycle )
reg     [255        :0]     s               ;
reg     [127        :0]     p_stage_1_d     ;
reg     [ADDR_W-1   :0]     i_cnt_stage_1_d ;
reg     [ADDR_W     :0]     j_cnt_stage_1_d ;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s <= 0;
    end
    else if(j_cnt_stage_0_d[8] == N)begin
        s <= result_x_mul_y + a_stage_0_d[8] + carry_stage_0_d[8];
    end
    else begin
        s <= result_x_mul_y + a_stage_0_d[8];
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_1_d <= 0;
        i_cnt_stage_1_d <= 0;
        j_cnt_stage_1_d <= 0;
    end
    else begin
        p_stage_1_d <= p_stage_0_d[8];
        i_cnt_stage_1_d <= i_cnt_stage_0_d[8];
        j_cnt_stage_1_d <= j_cnt_stage_0_d[8];
    end
end

//pipe stage 2 ( 6 cycles )
wire    [127        :0]     result_p1_mul_s         ;
reg     [127        :0]     p_stage_2_d     [0:5]   ;
reg     [ADDR_W-1   :0]     i_cnt_stage_2_d [0:5]   ;
reg     [ADDR_W     :0]     j_cnt_stage_2_d [0:5]   ;
reg     [255        :0]     s_stage_2_d     [0:5]   ;

iddmm_mul_128_to_128 iddmm_mul_1(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (p1             )
    ,   .y              (s              )
    ,   .result         (result_p1_mul_s)
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1)begin
            p_stage_2_d[i] <= 0;
            i_cnt_stage_2_d[i] <= 0;
            j_cnt_stage_2_d[i] <= 0;
            s_stage_2_d[i] <= 0;
        end
    end
    else begin
        p_stage_2_d[0] <= p_stage_1_d;
        i_cnt_stage_2_d[0] <= i_cnt_stage_1_d;
        j_cnt_stage_2_d[0] <= j_cnt_stage_1_d;
        s_stage_2_d[0] <= s;
        for(i = 1; i < 6; i = i + 1)begin
            p_stage_2_d[i] <= p_stage_2_d[i - 1];
            i_cnt_stage_2_d[i] <= i_cnt_stage_2_d[i - 1];
            j_cnt_stage_2_d[i] <= j_cnt_stage_2_d[i - 1];
            s_stage_2_d[i] <= s_stage_2_d[i - 1];
        end
    end
end


//pipe stage 3 ( 1 cycle )
reg     [127        :0]     q;
reg     [255        :0]     s_stage_3_d;
reg     [127        :0]     p_stage_3_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_3_d;
reg     [ADDR_W     :0]     j_cnt_stage_3_d;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        q <= 0;
    end
    else if(j_cnt_stage_2_d[5] == 0) begin
        q <= result_p1_mul_s;
    end
    else begin
        q <= q;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_stage_3_d <= 0;
        p_stage_3_d <= 0;
        i_cnt_stage_3_d <= 0;
        j_cnt_stage_3_d <= 0;
    end
    else begin
        s_stage_3_d <= s_stage_2_d[5];
        p_stage_3_d <= p_stage_2_d[5];
        i_cnt_stage_3_d <= i_cnt_stage_2_d[5];
        j_cnt_stage_3_d <= j_cnt_stage_2_d[5];
    end
end

//pipe stage 4 ( 9 cycles )
wire    [255        :0]     result_q_mul_p          ;
reg     [255        :0]     s_stage_4_d     [0:8]   ;
reg     [K-1        :0]     p_stage_4_d     [0:8]   ;
reg     [ADDR_W-1   :0]     i_cnt_stage_4_d [0:8]   ;
reg     [ADDR_W     :0]     j_cnt_stage_4_d [0:8]   ;

iddmm_mul_128_to_256 iddmm_mul_2(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .x              (q                  )
    ,   .y              (p_stage_3_d        )
    ,   .result         (result_q_mul_p     )
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 9; i = i + 1)begin
            s_stage_4_d[i] <= 0;
            p_stage_4_d[i] <= 0;
            i_cnt_stage_4_d[i] <= 0;
            j_cnt_stage_4_d[i] <= 0;
        end
    end
    else begin
        s_stage_4_d[0] <= s_stage_3_d;
        p_stage_4_d[0] <= p_stage_3_d;
        i_cnt_stage_4_d[0] <= i_cnt_stage_3_d;
        j_cnt_stage_4_d[0] <= j_cnt_stage_3_d;
        for(i = 1; i < 9; i = i + 1)begin
            s_stage_4_d[i] <= s_stage_4_d[i - 1];
            p_stage_4_d[i] <= p_stage_4_d[i - 1];
            i_cnt_stage_4_d[i] <= i_cnt_stage_4_d[i - 1];
            j_cnt_stage_4_d[i] <= j_cnt_stage_4_d[i - 1];
        end
    end
end

//pipe stage 5 ( 1 cycle )
reg     [256        :0]     buf0;
reg     [K-1        :0]     p_stage_5_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_5_d;
reg     [ADDR_W     :0]     j_cnt_stage_5_d;
assign u = buf0[0  +:128];
assign c = buf0[128+:129];

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buf0 <= 0;
    end
    else begin
        buf0 <= result_q_mul_p + s_stage_4_d[8] + buf0[128+:129];
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_5_d <= 0;
        i_cnt_stage_5_d <= 0;
        j_cnt_stage_5_d <= 0;
    end
    else begin
        p_stage_5_d <= p_stage_4_d[8];
        i_cnt_stage_5_d <= i_cnt_stage_4_d[8];
        j_cnt_stage_5_d <= j_cnt_stage_4_d[8];
    end
end

//pipe stage 6 ( 1 cycle )
reg     [K-1        :0]     p_stage_6_d;

reg                         wr_a_en_reg;
reg     [ADDR_W     :0]     wr_a_addr_reg;
reg     [K-1        :0]     wr_a_data_reg;

assign  wr_a_en         =   wr_a_en_reg;
assign  wr_a_addr       =   wr_a_addr_reg;
assign  wr_a_data       =   wr_a_data_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        carry <= 0;
    end
    else if(j_cnt_stage_5_d == N) begin
        carry <= c[0];
    end
end

//Actually advance by 2 cycles.
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_a_en_reg         <= 0;
        wr_a_addr_reg       <= 0;
        wr_a_data_reg       <= 0;
    end
    else if(j_cnt_stage_5_d != 0) begin
        wr_a_en_reg         <= 1;
        wr_a_addr_reg       <= j_cnt_stage_5_d - 1;
        wr_a_data_reg       <= u;
    end
    else begin
        wr_a_en_reg         <= 0;
        wr_a_addr_reg       <= 0;
        wr_a_data_reg       <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_6_d <= 0;
    end
    else begin
        p_stage_6_d <= p_stage_5_d;
    end
end

//pipe stage 7 ( 1 cycle )
reg    [K-1        :0]     p_stage_7_d;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_7_d <= 0;
    end
    else begin
        p_stage_7_d <= p_stage_6_d;
    end
end

//pipe stage 8 ( n cycle )





endmodule