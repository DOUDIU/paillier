module iddmm_adder1#(
        parameter K = 128
    ,   parameter N = 32
    ,   parameter ADDR_W = $clog2(N)
)(
        input                   clk
    ,   input                   rst_n

    ,   input   [ADDR_W :0]     j_cnt

    ,   input   [255    :0]     adder_a
    ,   input   [127    :0]     adder_b
    ,   input                   carry_in

    ,   output  [255    :0]     adder_result
);

reg     [255    :0]     adder_a_d1;
reg     [128    :0]     add_b_carry;

//pipe 0
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        add_b_carry <= 0;
    end
    else if(j_cnt == N)begin
        add_b_carry <= adder_b + carry_in;
    end
    else begin
        add_b_carry <= adder_b;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        adder_a_d1 <= 0;
    end
    else begin
        adder_a_d1 <= adder_a;
    end
end

//pipe 1
reg [255    :0]     adder_result_reg;
assign adder_result = adder_result_reg;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        adder_result_reg <= 0;
    end
    else begin
        adder_result_reg <= adder_a_d1 + add_b_carry;
    end
end










endmodule