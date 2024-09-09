
//q_calculation
module iddmm_q_update#(
        parameter K = 128                       // K bits in every group
    ,   parameter N = 32                        // Number of groups
    ,   parameter ADDR_W = $clog2(N)
)(
        input                       clk
    ,   input                       rst_n

    ,   input   [2          :0]     wr_ena
    ,   input   [ADDR_W-1   :0]     wr_addr
    ,   input   [K-1        :0]     wr_x
    ,   input   [K-1        :0]     wr_y

    ,   input   [ADDR_W-1   :0]     i_cnt
    ,   input   [ADDR_W     :0]     j_cnt
    ,   input   [K-1        :0]     x
    ,   input   [K-1        :0]     y_adv

    ,   input                       wr_a_en
    ,   input   [ADDR_W     :0]     wr_a_addr
    ,   input   [K-1        :0]     wr_a_data

    ,   input   [K-1        :0]     p1

    ,   output  [K-1        :0]     result_q_update
);
reg     [K-1        :0]     s                   ;
reg     [K-1        :0]     mux_mul_x           ;
reg     [K-1        :0]     mux_mul_y           ;
reg     [K-1        :0]     mux_mul_x_reg       ;
reg     [K-1        :0]     mux_mul_y_reg       ;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s   <=  0;
    end
    else begin
        s   <=  wr_a_data + result_q_update;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mux_mul_x <= 0;
        mux_mul_y <= 0;
    end
    else if(wr_ena & (wr_addr == 0)) begin // update the first q step 0
        mux_mul_x <= wr_x;
        mux_mul_y <= wr_y;
    end
    else if(wr_ena & (wr_addr == 9)) begin
        mux_mul_x <= result_q_update;
        mux_mul_y <= p1;
    end
    else if(j_cnt == 0) begin
        mux_mul_x <= x;
        mux_mul_y <= y_adv;
    end
    else if(wr_a_en & (wr_a_addr == 1))begin
        mux_mul_x <= s;
        mux_mul_y <= p1;
    end
end

always@(posedge clk) begin
    mux_mul_x_reg <= mux_mul_x;
    mux_mul_y_reg <= mux_mul_y;
end

iddmm_mul_128_to_128 iddmm_mul_q_update(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .x              (mux_mul_x_reg      )
    ,   .y              (mux_mul_y_reg      )
    ,   .result         (result_q_update    )
);

endmodule