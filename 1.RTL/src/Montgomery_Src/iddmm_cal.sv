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
    ,   input   [K-1        :0]     y_adv
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

    ,   input   [K-1        :0]     result_q_update
);
integer i,j,k;

wire    [127        :0]     u                       ;
wire    [128        :0]     c                       ;
reg                         carry                   ;
reg                         carry_last              ;

wire    [127        :0]     q                       ;

//pipe stage 0 ( 8 cycles )
wire    [255        :0]     result_x_mul_y          ;
wire    [255        :0]     result_q_mul_p          ;
reg     [K-1        :0]     x_reg                   ;
reg     [K-1        :0]     y_reg                   ;
reg     [K-1        :0]     p_reg                   ;
reg     [K-1        :0]     q_reg                   ;
reg     [127        :0]     p_stage_0_d     [0:8]   ;
reg     [127        :0]     a_stage_0_d     [0:8]   ;
reg     [ADDR_W-1   :0]     i_cnt_stage_0_d [0:8]   ;
reg     [ADDR_W     :0]     j_cnt_stage_0_d [0:8]   ;

always@(posedge clk) begin
    x_reg       <= x;
    y_reg       <= y;
    p_reg       <= p;
    if(j_cnt == 0)begin
        q_reg       <= result_q_update;
    end
end

iddmm_mul_128_to_256 iddmm_mul_0(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (x_reg          )
    ,   .y              (y_reg          )
    ,   .result         (result_x_mul_y )
);

iddmm_mul_128_to_256 iddmm_mul_1(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (q_reg          )
    ,   .y              (p_reg          )
    ,   .result         (result_q_mul_p )
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 9; i = i + 1)begin
            p_stage_0_d[i]      <= 0;
            i_cnt_stage_0_d[i]  <= 0;
            j_cnt_stage_0_d[i]  <= 0;
        end
    end
    else begin
        p_stage_0_d[0] <= p;
        i_cnt_stage_0_d[0] <= i_cnt;
        j_cnt_stage_0_d[0] <= j_cnt;
        for(i = 1; i < 9; i = i + 1)begin
            p_stage_0_d[i] <= p_stage_0_d[i - 1];
            i_cnt_stage_0_d[i] <= i_cnt_stage_0_d[i - 1];
            j_cnt_stage_0_d[i] <= j_cnt_stage_0_d[i - 1];
        end
    end
end

reg     [K-1        :0]     sum_a_carry                 ;
reg     [K-1        :0]     a_d1                        ;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_a_carry <= 0;
        a_d1 <= 0;
    end
    else begin
        sum_a_carry <= a + carry;
        a_d1 <= a;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 9; i = i + 1)begin
            a_stage_0_d[i]      <= 0;
        end
    end
    else begin
        a_stage_0_d[1] <= (j_cnt_stage_0_d[0] == N) ? sum_a_carry : a_d1;
        for(i = 2; i < 9; i = i + 1)begin
            a_stage_0_d[i] <= a_stage_0_d[i - 1];
        end
    end
end

//pipe stage 1 ( 1 cycles )
reg     [255        :0]     s                   ;
reg     [255        :0]     r                   ;
reg     [127        :0]     p_stage_1_d         ;
reg     [ADDR_W-1   :0]     i_cnt_stage_1_d     ;
reg     [ADDR_W     :0]     j_cnt_stage_1_d     ;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s <= 0;
    end
    else begin
        s <= result_x_mul_y + a_stage_0_d[6];
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r <= 0;
        p_stage_1_d <= 0;
        i_cnt_stage_1_d <= 0;
        j_cnt_stage_1_d <= 0;
    end
    else begin
        r <= result_q_mul_p;
        p_stage_1_d <= p_stage_0_d[6];
        i_cnt_stage_1_d <= i_cnt_stage_0_d[6];
        j_cnt_stage_1_d <= j_cnt_stage_0_d[6];
    end
end

//pipe stage 2 ( 1 cycles )
reg     [2*K        :0]     buf_tem             ;

reg     [K-1        :0]     p_stage_2_d         ;
reg     [ADDR_W-1   :0]     i_cnt_stage_2_d     ;
reg     [ADDR_W     :0]     j_cnt_stage_2_d     ;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buf_tem <=  0;
    end
    else begin
        buf_tem <=  r + s;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_2_d <=  0;
        i_cnt_stage_2_d <=  0;
        j_cnt_stage_2_d <=  0;
    end
    else begin
        p_stage_2_d <=  p_stage_1_d;
        i_cnt_stage_2_d <=  i_cnt_stage_1_d;
        j_cnt_stage_2_d <=  j_cnt_stage_1_d;
    end
end

//pipe stage 3 ( 1 cycle )
reg     [2*K        :0]     buf0;
reg     [K-1        :0]     p_stage_3_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_3_d;
reg     [ADDR_W     :0]     j_cnt_stage_3_d;
assign u = buf0[0  +:128];
assign c = buf0[128+:129];

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buf0 <= 0;
    end
    else begin
        buf0 <= buf_tem + buf0[128+:129];
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_3_d <= 0;
        i_cnt_stage_3_d <= 0;
        j_cnt_stage_3_d <= 0;
    end
    else begin
        p_stage_3_d <= p_stage_2_d;
        i_cnt_stage_3_d <= i_cnt_stage_2_d;
        j_cnt_stage_3_d <= j_cnt_stage_2_d;
    end
end

//pipe stage 4 ( 1 cycle )
reg     [K-1        :0]     p_stage_4_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_4_d;
reg     [ADDR_W     :0]     j_cnt_stage_4_d;

reg                         wr_a_en_reg;
reg     [ADDR_W     :0]     wr_a_addr_reg;
reg     [K-1        :0]     wr_a_data_reg;

assign  wr_a_en         =   wr_a_en_reg;
assign  wr_a_addr       =   wr_a_addr_reg;
assign  wr_a_data       =   i_cnt_stage_4_d == N - 1 ? 0 : wr_a_data_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        carry <= 0;
        carry_last <= 0;
    end
    else if((i_cnt_stage_3_d == 0) && (j_cnt_stage_3_d == 0)) begin
        carry <= 0;
        carry_last <= carry;
    end
    else if(j_cnt_stage_3_d == N) begin
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
    else if(j_cnt_stage_3_d != 0) begin
        wr_a_en_reg         <= 1;
        wr_a_addr_reg       <= j_cnt_stage_3_d - 1;
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
        p_stage_4_d <= 0;
        i_cnt_stage_4_d <= 0;
        j_cnt_stage_4_d <= 0;
    end
    else begin
        p_stage_4_d <= p_stage_3_d;
        i_cnt_stage_4_d <= i_cnt_stage_3_d;
        j_cnt_stage_4_d <= j_cnt_stage_3_d;
    end
end

//pipe stage 5 ( 1 cycle )
reg     [K-1        :0]     p_stage_5_d;
reg     [ADDR_W-1   :0]     i_cnt_stage_5_d;
reg     [ADDR_W     :0]     j_cnt_stage_5_d;

reg                         fifo_wr_en_a_reg;
reg     [K-1        :0]     fifo_wr_data_a_reg;

assign  fifo_wr_en_a    =   fifo_wr_en_a_reg;
assign  fifo_wr_data_a  =   fifo_wr_data_a_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_wr_en_a_reg        <= 0;
        fifo_wr_data_a_reg      <= 0;
    end
    else if(i_cnt_stage_4_d == N - 1) begin
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
        p_stage_5_d <= 0;
        i_cnt_stage_5_d <= 0;
        j_cnt_stage_5_d <= 0;
    end
    else begin
        p_stage_5_d <= p_stage_4_d;
        i_cnt_stage_5_d <= i_cnt_stage_4_d;
        j_cnt_stage_5_d <= j_cnt_stage_4_d;
    end
end

//pipe stage 6 ( 1 cycle )
wire                        borrow_bit;
wire    [K-1        :0]     sub_result;

reg     [ADDR_W-1   :0]     i_cnt_stage_6_d;
reg     [ADDR_W     :0]     j_cnt_stage_6_d;

iddmm_sub iddmm_sub(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .sub_addr       (wr_a_addr_reg  )
    ,   .sub_a          (wr_a_data_reg  )
    ,   .sub_b          (p_stage_5_d    )

    ,   .borrow_bit     (borrow_bit     )
    ,   .sub_result     (sub_result     )
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_cnt_stage_6_d <= 0;
        j_cnt_stage_6_d <= 0;
    end
    else begin
        i_cnt_stage_6_d <= i_cnt_stage_5_d;
        j_cnt_stage_6_d <= j_cnt_stage_5_d;
    end
end

//pipe stage 7 ( 1 cycle )
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
    else if((i_cnt_stage_6_d == N - 1) && (j_cnt_stage_6_d == N - 1)) begin
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
    else if((i_cnt_stage_6_d == N - 1) && (j_cnt_stage_6_d != N)) begin
        fifo_wr_en_sub_reg      <= 1;
        fifo_wr_data_sub_reg    <= sub_result;
    end
    else begin
        fifo_wr_en_sub_reg      <= 0;
        fifo_wr_data_sub_reg    <= 0;
    end
end


endmodule