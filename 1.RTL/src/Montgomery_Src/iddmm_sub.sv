module iddmm_sub#(
        parameter K = 128
    ,   parameter N = 32
    ,   parameter ADDR_W = $clog2(N)
)(
        input                           clk
    ,   input                           rst_n

    ,   input       [ADDR_W-1:0]        sub_addr
    ,   input       [127:0]             sub_a
    ,   input       [127:0]             sub_b

    ,   output                          borrow_bit
    ,   output      [127:0]             sub_result 
);

//pipe stage 0
wire    [128:0]         sub_tem_result;
reg                     borrow_bit_reg;
reg     [127:0]         sub_result_reg;
reg                     signed_reg;
reg     [ADDR_W-1:0]    sub_addr_d1;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sub_addr_d1 <= 0;
    end
    else begin
        sub_addr_d1 <= sub_addr;
    end
end

assign sub_tem_result = {1'b1, sub_a} - {1'b0, sub_b} - borrow_bit_reg;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        borrow_bit_reg  <= 0;
    end
    else if((sub_addr_d1 == N - 1) && (sub_addr == 0)) begin
        borrow_bit_reg  <= 0;
    end
    else begin
        borrow_bit_reg  <= !sub_tem_result[128];
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sub_result_reg  <= 0;
    end
    else begin
        sub_result_reg  <= sub_tem_result[0+:128];
    end
end

assign borrow_bit = borrow_bit_reg;
assign sub_result = sub_result_reg;


endmodule