`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 11:56:33
// Design Name: 
// Module Name: tb_nrdiv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_nrdiv(

    );
    parameter   N=4096,M=2048,Block=128;
    parameter   max=32'h0a347456;
    
    reg                     clk;
    reg                     rst_n;
    
    reg     [Block-1:0]         x;
    reg     [Block-1:0]         y;
    reg                     div_vld_in,valid_in;
    wire    [Block-1:0]         q,r; 
    wire                    div_vld_out,valid_out;  
    wire    [M-1:0]         q_ref,r_ref;
    reg     [M-1:0]         quotient_out;
    reg     [7:0]           i;
    
    reg     [N-1:0]   n,d;
    wire    [N-1:0]   a,b;    

    assign  q_ref = n/d;
//    assign  r_ref = n%d;
    
    always #10  clk=~clk;
    initial begin
        clk=0;
        rst_n=0;
        div_vld_in=0;
        x=0;
        y=0;
        n=0;
        d=0;
        valid_in=0;
        i<=0;
        quotient_out<=0;
        #110
        rst_n=1;
        valid_in=1;
        #20
        valid_in=0;
        div_vld_in=1;
        repeat(16)@(posedge clk)begin
            repeat(4)begin
                x={x[95:0],$random};
                y={y[95:0],$random};
            end
            n={n[N-1-128:0],x};
            d={d[N-1-128:0],y};
        end
        repeat(16)@(posedge clk)begin
            repeat(4)begin
                x={x[95:0],$random};
            end
            n={n[N-1-128:0],x};
        end 
        d={2048'b0,d[2047:0]} ;
        #20
        div_vld_in=0;
        repeat(16)@(posedge div_vld_out)begin
            quotient_out<={q,quotient_out[M-1:128]};
        end
        #20
        if(quotient_out==q_ref[2047:0])
            $display("Division Correct");
        else
            $display("Division Error");
        

        #2000
        $stop;
    end

   
NR_Div 
#(  .N(N),
    .M(M),
    .Block(Block)
)inst(
   .clk(clk),
   .rst_n(rst_n),
   .dividend_in(x),
   .divisor_in(y),
   .valid_in(valid_in),
   .data_vld_in(div_vld_in),

    .quotient_out(q), 
   .remainder_out(r),

   .valid_out(valid_out),
   .data_vld_out(div_vld_out)
    );

   
endmodule
