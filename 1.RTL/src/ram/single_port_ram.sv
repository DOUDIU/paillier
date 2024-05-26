
module single_port_ram#(
        parameter WIDTH_DATA    =   1
    ,   parameter DEPTH         =   0
    ,   parameter FILENAME      =   "none"
)(
        input                               clk
    ,   input                               wen
    ,   input       [$clog2(DEPTH)-1:0]     addr
    ,   input       [WIDTH_DATA-1   :0]     wr_data
    ,   output reg  [WIDTH_DATA-1   :0]     rd_data
);

(* ram_style = "block" *) reg [WIDTH_DATA-1:0] mem [0:DEPTH-1];

initial begin
    $readmemh(FILENAME,mem);
end

always @(posedge clk) begin
    if(wen) begin
        mem[addr] <= wr_data;
    end
end

always @(posedge clk) begin
    if(!wen) begin
        rd_data <= mem[addr];
    end
end

endmodule
