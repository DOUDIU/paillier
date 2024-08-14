`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/14 09:15:51
// Design Name: 
// Module Name: tb_nr_div
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


module tb_nr_div(

    );
        
    parameter   N=4096,M=2048,Block=128;

    
    reg                         clk;
    reg                         rst_n;
    
    reg     [Block-1:0]         dividend_in;
    reg     [Block-1:0]         divisor_in;
    reg                         data_vld_in,valid_in;
    wire    [Block-1:0]         quotient_out; 
    wire                        data_vld_out,valid_out;  
    wire    [M-1:0]             q_ref,r_ref;
    reg     [M-1:0]             q_out;
    
    reg     [N-1:0]             n,d;
   

    assign  q_ref   =   n/d;
//    assign  r_ref = n%d;
    
    always #10  clk =   ~clk;
    initial begin
        clk=0;
        rst_n=0;
        data_vld_in=0;
        dividend_in=0;
        divisor_in=0;
        n=0;
        d=0;
        valid_in=0;
        q_out=0;
        #110
        rst_n=1;
        valid_in=1;
        #20
        valid_in=0;
        data_vld_in=1;
        repeat(16)@(posedge clk)begin
            repeat(4)begin
                dividend_in={dividend_in[95:0],$random};
                divisor_in={divisor_in[95:0],$random};
            end
            n={n[N-1-128:0],dividend_in};
            d={d[N-1-128:0],divisor_in};
        end
        repeat(16)@(posedge clk)begin
            repeat(4)begin
                dividend_in={dividend_in[95:0],$random};
            end
            n={n[N-1-128:0],dividend_in};
        end 
        d={2048'b0,d[2047:0]} ;
        #20
        data_vld_in=0;
        
        repeat(16)@(posedge data_vld_out)begin
            q_out={quotient_out,q_out[M-1:128]};
        end
        #20
//        $display("%h",q_ref);
        $display("%h",q_out);
        assert(q_out ==  q_ref)
            $display("Division result is correct!");
        else
            $display("Division result is wrong!");
            
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
   
   .dividend_in(dividend_in),
   .divisor_in(divisor_in),
   .valid_in(valid_in),
   .data_vld_in(data_vld_in),

   .quotient_out(quotient_out), 
//   .remainder_out(remainder_out),
   .valid_out(valid_out),
   .data_vld_out(data_vld_out)
   
    );
    
endmodule
