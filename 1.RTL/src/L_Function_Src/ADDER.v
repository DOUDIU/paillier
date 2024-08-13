`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 19:47:13
// Design Name: 
// Module Name: ADDER
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
module ADDER#(
parameter   N       =   4096,
parameter   Block   =   128,
parameter   max     =   N/Block
    
)(
            input                       clk,
            input                       rst_n,
            input  signed [N:0]             add_a,
            input  signed [N:0]             add_b,
            input                       cin,
            input                       sign_in,
            input                       vld_in,
            input                       mode,
            output reg [N+2:0]          sum,
            output reg                  sign,
            output reg                  cout,
            output reg                  vld_out
        );
     
     
    reg     [7:0]           i;
    reg   signed  [Block+1:0]     a,b;
    reg                     mod,vin;
    wire  signed  [Block+2:0]     s;
    wire                    co,vout,si; 
    
    wire ci=i==1? cin :s[Block];
       
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            a<=0;b<=0;mod<=0;vin<=0;
            cout<=0;
            i<=0;
        end
        else if(vld_in)begin
                a<={1'b0,add_a[i*128+:128]};
                b<={1'b0,add_b[i*128+:128]};
                mod<=mode;
                i<=i+1;
                vin<=1;
        end
        else if(i>0)begin
            if(i==max)begin
                cout<=s[Block];
                i<=0;
                vin<=0;
                a<=0;
                b<=0;
            end
            else if(i==max-1)begin
                a<={sign_in ,add_a[i*128+:129]};
                b<={1'b0,add_b[i*128+:128]};
                mod<=mode;
                i<=i+1;
                vin<=1;
            end
            else begin
                a<={1'b0,add_a[i*128+:128]};
                b<={1'b0,add_b[i*128+:128]};
                mod<=mode;
                i<=i+1;
                vin<=1;
            end 
            end  
     end
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            sum<=0;
        end
        else if(vout)begin
            if(i==0)
                sum<={s,sum[N-1:128]};
            else
                sum<={s[0+:128],sum[N-1:128]};
        end
     end 
    
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            vld_out<=0;
        end
        else if(!vin&&vout)begin
            vld_out<=1;
        end
        else begin
            vld_out<=0;
        end
     end 
      
     
adder_128  #(Block)
    inst(
    .clk(clk),    
    .rst_n(rst_n), 
    .add_a(a),  
    .add_b(b),  
    .cin(ci),    
    .mode(mod),  
    .sum(s),
    .vld_in(vin), 
    .vld_out(vout)
);
        
        
//        genvar i;
//        wire     vout[0:31];
//        wire     couti[0:31];
//        generate
//            for(i=0;i<32;i=i+1)begin:block_adder
//                if(i==0)
//                    adder_128 inst(.clk(clk),.rst_n(rst_n),.add_a(add_a[i*128+:128]),.add_b(add_b[i*128+:128]),.cin(cin),.mode(mode),.sum(sum[i*128+:128]),.cout(couti[i]),.vld_in(vld_in),.vld_out(vout[i]));
//                else if(i==31)
//                    adder_128 inst(.clk(clk),.rst_n(rst_n),.add_a(add_a[i*128+:128]),.add_b(add_b[i*128+:128]),.cin(couti[i-1]),.mode(mode),.sum(sum[i*128+:128]),.cout(cout),.vld_in(vout[i-1]),.vld_out(vld_out));
//                else
//                    adder_128 inst(.clk(clk),.rst_n(rst_n),.add_a(add_a[i*128+:128]),.add_b(add_b[i*128+:128]),.cin(couti[i-1]),.mode(mode),.sum(sum[i*128+:128]),.cout(couti[i]),.vld_in(vout[i-1]),.vld_out(vout[i]));
//            end
//        endgenerate

        
endmodule

module adder_128u#(
    parameter   WIDTH=128
)(
            input                   clk,
            input                   rst_n,
            input   [WIDTH-1:0]       add_a,
            input   [WIDTH-1:0]       add_b,
            input                   cin,
            input                   vld_in,
            input                   mode,
            output reg [WIDTH:0]       sum,
//            output reg                 cout,
            output reg                 vld_out
        );
        
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            sum<=0;
//            cout<=0;
            vld_out<=0;
        end
        else if(vld_in)begin
            case(mode)
                1:begin
                    sum <=    add_a+add_b+cin;
                    vld_out     <=1;
                end
                0:begin
                    sum <=    add_a-add_b-cin;
                    vld_out     <=1;
                end
            endcase
        end
        else begin
//            cout        <=0;
//            sum         <=0;
            vld_out     <=0;
        end
     end   
               
endmodule
module adder_128#(
    parameter   WIDTH=128
)(
            input                   clk,
            input                   rst_n,
            input  signed [WIDTH+1:0]       add_a,
            input  signed [WIDTH+1:0]       add_b,
            input                   cin,
            input                   vld_in,
            input                   mode,
            output reg  [WIDTH+2:0]       sum,
            output reg                 vld_out
        );
        
        
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            sum<=0;
            vld_out<=0;
        end
        else if(vld_in)begin
            vld_out     <=1;
            if(mode)    
                sum <=    add_a+add_b+cin;
            else        
                sum <=    add_a-add_b-cin;
//            case(mode)
//                1:begin
//                    sum <=    add_a+add_b+cin;
//                    vld_out     <=1;
//                end
//                0:begin
//                    sum <=    add_a-add_b-cin;
//                    vld_out     <=1;
//                end
//            endcase
        end
        else begin
            vld_out     <=0;
        end
     end   
               
endmodule
