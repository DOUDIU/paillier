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

    ,   input                           carry_in

    ,   output                          unsigned_out
    ,   output      [127:0]             sub_result 
);

//pipe stage 0
wire    [128:0]     sub_tem_result;
reg                 borrow_bit;
reg     [127:0]     sub_result_reg;
reg                 signed_reg;

assign sub_tem_result = {1'b1, sub_a} - {1'b0, sub_b} - borrow_bit;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        borrow_bit  <= 0;
    end
    else if(sub_addr == N - 1) begin
        borrow_bit  <= 0;
    end
    else begin
        borrow_bit  <= !sub_tem_result[128];
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

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        signed_reg      <= 0;
    end
    else if(sub_addr == N - 1) begin
        signed_reg      <= !carry_in & borrow_bit;
    end
end

assign sub_result = sub_result_reg;
assign unsigned_out = !signed_reg;



endmodule