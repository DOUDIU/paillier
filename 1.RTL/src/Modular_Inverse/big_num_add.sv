




module big_num_add#(
		parameter	K 	= 	128
	,	parameter	N 	= 	32
)(
        input                   clk
    ,   input                   rst_n

    ,   input                   start
    ,   input                   input_valid
    ,   input       [K-1:0]     a
    ,   input       [K-1:0]     b

    ,   output                  sum_valid
    ,   output                  carry
    ,   output      [K-1:0]     sum
);



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        
    end
    else begin

    end
end













endmodule