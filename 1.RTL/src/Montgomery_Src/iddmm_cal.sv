module iddmm_cal#(
        parameter K = 256                       // K bits in every group
    ,   parameter N = 16                        // Number of groups
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

    ,   output                      fifo_wr_en_a
    ,   output  [K-1        :0]     fifo_wr_data_a
    ,   output                      fifo_wr_en_sub
    ,   output  [K-1        :0]     fifo_wr_data_sub

    ,   output                      cal_done
    ,   output                      cal_sign
);
integer i,j,k;

wire    [K-1    :0] u                       ;
wire    [K      :0] c                       ;
reg                 carry                   ;
reg                 carry_last              ;

//pipe stage 0 ( 8 cycles )
wire    [2*K-1      :0]     result_x_mul_y          ;
reg     [K-1        :0]     x_d1                    ;
reg     [K-1        :0]     y_d1                    ;
reg     [K-1        :0]     p1_d1                   ;
wire    [K-1        :0]     x_d1_reg                ;
wire    [K-1        :0]     y_d1_reg                ;
reg     [K-1        :0]     x_d2                    ;
reg     [K-1        :0]     y_d2                    ;
reg     [K-1        :0]     p_stage_0_d     [0:8]   ;
reg     [K-1        :0]     a_stage_0_d     [0:8]   ;
reg                         carry_stage_0_d [0:8]   ;
reg     [ADDR_W-1   :0]     i_cnt_stage_0_d [0:8]   ;
reg     [ADDR_W     :0]     j_cnt_stage_0_d [0:8]   ;

always@(posedge clk or negedge rst_n) begin//The delay operation is used to optimize the timing.
    if(!rst_n) begin
        p1_d1 <= 0;
    end
    else begin
        p1_d1 <= p1;
    end
end

always@(posedge clk or negedge rst_n) begin//The delay operation is used to optimize the timing.
    if(!rst_n) begin
        x_d1 <= 0;
        y_d1 <= 0;
    end
    else begin
        x_d1 <= x;
        y_d1 <= y;
    end
end

assign  x_d1_reg    = ((i_cnt == 0) && (j_cnt == 0)) ? 0 : x_d1;
assign  y_d1_reg    = ((i_cnt == 0) && (j_cnt == 0)) ? 0 : y_d1;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x_d2 <= 0;
        y_d2 <= 0;
    end
    else begin
        x_d2 <= x_d1_reg;
        y_d2 <= y_d1_reg;
    end
end

iddmm_mul_128_to_256 iddmm_mul_0(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .x              (x_d2               )
    ,   .y              (y_d2               )
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

//pipe stage 1 ( 2 cycles )
reg     [255        :0]     s                   ;
reg     [127        :0]     p_stage_1_d     [0:1];
reg     [ADDR_W-1   :0]     i_cnt_stage_1_d [0:1];
reg     [ADDR_W     :0]     j_cnt_stage_1_d [0:1];

iddmm_adder1 iddmm_adder1(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .j_cnt          (j_cnt_stage_0_d[7] )
    ,   .adder_a        (result_x_mul_y     )
    ,   .adder_b        (a_stage_0_d[7]     )
    ,   .carry_in       (carry_stage_0_d[7] )
    ,   .adder_result   (s                  )
);


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 2; i = i + 1)begin
            p_stage_1_d[i] <= 0;
            i_cnt_stage_1_d[i] <= 0;
            j_cnt_stage_1_d[i] <= 0;
        end
    end
    else begin
        p_stage_1_d[0] <= p_stage_0_d[7];
        i_cnt_stage_1_d[0] <= i_cnt_stage_0_d[7];
        j_cnt_stage_1_d[0] <= j_cnt_stage_0_d[7];
        for(i = 1; i < 2; i = i + 1)begin
            p_stage_1_d[i] <= p_stage_1_d[i - 1];
            i_cnt_stage_1_d[i] <= i_cnt_stage_1_d[i - 1];
            j_cnt_stage_1_d[i] <= j_cnt_stage_1_d[i - 1];
        end
    end
end

//pipe stage 2 ( 5 cycles )
wire    [127        :0]     result_p1_mul_s         ;
reg     [127        :0]     p_stage_2_d     [0:5]   ;
reg     [ADDR_W-1   :0]     i_cnt_stage_2_d [0:5]   ;
reg     [ADDR_W     :0]     j_cnt_stage_2_d [0:5]   ;
reg     [255        :0]     s_stage_2_d     [0:5]   ;

iddmm_mul_128_to_128 iddmm_mul_1(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (p1_d1          )
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
        p_stage_2_d[0] <= p_stage_1_d[1];
        i_cnt_stage_2_d[0] <= i_cnt_stage_1_d[1];
        j_cnt_stage_2_d[0] <= j_cnt_stage_1_d[1];
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
    else if(j_cnt_stage_2_d[4] == 0) begin
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
        s_stage_3_d <= s_stage_2_d[4];
        p_stage_3_d <= p_stage_2_d[4];
        i_cnt_stage_3_d <= i_cnt_stage_2_d[4];
        j_cnt_stage_3_d <= j_cnt_stage_2_d[4];
    end
end

//pipe stage 4 ( 6 cycles )
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
        buf0 <= result_q_mul_p + s_stage_4_d[5] + buf0[128+:129];
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_5_d <= 0;
        i_cnt_stage_5_d <= 0;
        j_cnt_stage_5_d <= 0;
    end
    else begin
        p_stage_5_d <= p_stage_4_d[5];
        i_cnt_stage_5_d <= i_cnt_stage_4_d[5];
        j_cnt_stage_5_d <= j_cnt_stage_4_d[5];
    end
end

//pipe stage 6 ( 1 cycle )
reg     [K-1        :0]     p_stage_6_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_6_d;
reg     [ADDR_W     :0]     j_cnt_stage_6_d;

reg                         wr_a_en_reg;
reg     [ADDR_W     :0]     wr_a_addr_reg;
reg     [K-1        :0]     wr_a_data_reg;

assign  wr_a_en         =   wr_a_en_reg;
assign  wr_a_addr       =   wr_a_addr_reg;
assign  wr_a_data       =   i_cnt_stage_6_d == N - 1 ? 0 : wr_a_data_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        carry <= 0;
        carry_last <= 0;
    end
    else if((i_cnt_stage_5_d == 0) && (j_cnt_stage_5_d == 0)) begin
        carry <= 0;
        carry_last <= carry;
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
        i_cnt_stage_6_d <= 0;
        j_cnt_stage_6_d <= 0;
    end
    else begin
        p_stage_6_d <= p_stage_5_d;
        i_cnt_stage_6_d <= i_cnt_stage_5_d;
        j_cnt_stage_6_d <= j_cnt_stage_5_d;
    end
end

//pipe stage 7 ( 1 cycle )
reg     [K-1        :0]     p_stage_7_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_7_d;
reg     [ADDR_W     :0]     j_cnt_stage_7_d;

reg                         fifo_wr_en_a_reg;
reg     [K-1        :0]     fifo_wr_data_a_reg;

assign  fifo_wr_en_a    =   fifo_wr_en_a_reg;
assign  fifo_wr_data_a  =   fifo_wr_data_a_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_wr_en_a_reg        <= 0;
        fifo_wr_data_a_reg      <= 0;
    end
    else if(i_cnt_stage_6_d == N - 1) begin
        fifo_wr_en_a_reg        <= wr_a_en_reg;
        fifo_wr_data_a_reg      <= wr_a_data_reg;
    end
    else begin
        fifo_wr_en_a_reg        <= 0;
        fifo_wr_data_a_reg      <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_7_d <= 0;
        i_cnt_stage_7_d <= 0;
        j_cnt_stage_7_d <= 0;
    end
    else begin
        p_stage_7_d <= p_stage_6_d;
        i_cnt_stage_7_d <= i_cnt_stage_6_d;
        j_cnt_stage_7_d <= j_cnt_stage_6_d;
    end
end

//pipe stage 8 ( 1 cycle )
wire                        borrow_bit;
wire    [K-1        :0]     sub_result;

reg     [ADDR_W-1   :0]     i_cnt_stage_8_d;
reg     [ADDR_W     :0]     j_cnt_stage_8_d;

iddmm_sub iddmm_sub(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .sub_addr       (wr_a_addr_reg  )
    ,   .sub_a          (wr_a_data_reg  )
    ,   .sub_b          (p_stage_7_d    )

    ,   .borrow_bit     (borrow_bit     )
    ,   .sub_result     (sub_result     )
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_cnt_stage_8_d <= 0;
        j_cnt_stage_8_d <= 0;
    end
    else begin
        i_cnt_stage_8_d <= i_cnt_stage_7_d;
        j_cnt_stage_8_d <= j_cnt_stage_7_d;
    end
end

//pipe stage 9 ( 1 cycle )
reg                         cal_done_reg;
reg                         cal_sign_reg;
reg                         fifo_wr_en_sub_reg;
reg     [K-1        :0]     fifo_wr_data_sub_reg;

assign  cal_done        =   cal_done_reg;
assign  cal_sign        =   cal_sign_reg;
assign  fifo_wr_en_sub  =   fifo_wr_en_sub_reg;
assign  fifo_wr_data_sub=   fifo_wr_data_sub_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cal_done_reg <= 0;
        cal_sign_reg <= 0;
    end
    else if((i_cnt_stage_8_d == N - 1) && (j_cnt_stage_8_d == N - 1)) begin
        cal_done_reg <= 1;
        cal_sign_reg <= !((!carry_last) & borrow_bit);
    end
    else begin
        cal_done_reg <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_wr_en_sub_reg      <= 0;
        fifo_wr_data_sub_reg    <= 0;
    end
    else if((i_cnt_stage_8_d == N - 1) && (j_cnt_stage_8_d != N)) begin
        fifo_wr_en_sub_reg      <= 1;
        fifo_wr_data_sub_reg    <= sub_result;
    end
    else begin
        fifo_wr_en_sub_reg      <= 0;
        fifo_wr_data_sub_reg    <= 0;
    end
end


endmodule