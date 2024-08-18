module iddmm_cal#(
        parameter K = 128                       // K bits in every group
    ,   parameter N = 32                        // Number of groups
    ,   parameter ADDR_W = $clog2(N)
)(
        input                   clk
    ,   input                   rst_n

    ,   input   [ADDR_W :0]     j_cnt

    ,   input   [K-1    :0]     a
    ,   input   [K-1    :0]     x
    ,   input   [K-1    :0]     y
    ,   input   [K-1    :0]     p
    ,   input   [K-1    :0]     p1

    // ,   output  [255    :0]     s_reg
);
integer i,j,k;

wire [127:0]    c;

//pipe stage 0 ( 9 cycles )
wire    [255    :0] result_x_mul_y          ;
reg     [127    :0] p_stage_0_d     [0:8]   ;
reg     [127    :0] a_stage_0_d     [0:8]   ;
reg                 carry_stage_0_d [0:8]   ;
reg     [ADDR_W :0] j_cnt_stage_0_d [0:8]   ;

iddmm_mul_128_to_256 iddmm_mul_128_to_256_inst(
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
            j_cnt_stage_0_d[i]  <= 0;
        end
    end
    else begin
        p_stage_0_d[0] <= p;
        a_stage_0_d[0] <= a;
        carry_stage_0_d[0] <= c;
        j_cnt_stage_0_d[0] <= j_cnt;
        for(i = 1; i < 9; i = i + 1)begin
            p_stage_0_d[i] <= p_stage_0_d[i - 1];
            a_stage_0_d[i] <= a_stage_0_d[i - 1];
            carry_stage_0_d[i] <= carry_stage_0_d[i - 1];
            j_cnt_stage_0_d[i] <= j_cnt_stage_0_d[i - 1];
        end
    end
end

//pipe stage 1 ( 1 cycle )
reg     [255    :0] s               ;
reg     [127    :0] p_stage_1_d     ;
reg     [ADDR_W :0] j_cnt_stage_1_d ;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s <= 0;
    end
    else begin
        s <= result_x_mul_y + a_stage_0_d[8] + (j_cnt_stage_0_d[i] == N ? carry_stage_0_d[8] : 0);
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_stage_1_d <= 0;
        j_cnt_stage_1_d <= 0;
    end
    else begin
        p_stage_1_d <= p_stage_0_d[8];
        j_cnt_stage_1_d <= j_cnt_stage_0_d[8];
    end
end

//pipe stage 2 ( 6 cycle )
wire    [127    :0] result_p1_mul_s;
reg     [ADDR_W :0] j_cnt_stage_2_d [0:5];
reg     [255    :0] s_stage_2_d     [0:5];

iddmm_mul_128_to_128 iddmm_mul_128_to_128_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (p1             )
    ,   .y              (s              )
    ,   .result         (result_p1_mul_s)
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1)begin
            j_cnt_stage_2_d[i] <= 0;
            s_stage_2_d[i] <= 0;
        end
    end
    else begin
        j_cnt_stage_2_d[0] <= j_cnt_stage_1_d;
        s_stage_2_d[0] <= s;
        for(i = 1; i < 6; i = i + 1)begin
            j_cnt_stage_2_d[i] <= j_cnt_stage_2_d[i - 1];
            s_stage_2_d[i] <= s_stage_2_d[i - 1];
        end
    end
end


//pipe stage 3 ( 1 cycle )
reg     [127    :0] q;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        q <= 0;
    end
    else if(j_cnt_stage_2_d[5]) begin
        q <= result_p1_mul_s;
    end
    else begin
        q <= q;
    end
end




















endmodule