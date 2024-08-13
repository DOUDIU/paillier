`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 09:36:01
// Design Name: 
// Module Name: NR_Div
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


module NR_Div#(
parameter   N       =   4096,
parameter   M       =   2048,
parameter   Block   =   128

)(
    input                       clk,
    input                       rst_n,
    input  [Block-1:0]          dividend_in,
    input  [Block-1:0]          divisor_in,
    input                       valid_in,
    input                       data_vld_in,
    output reg [Block-1:0]      quotient_out, 
    output reg [Block-1:0]      remainder_out,
    output reg                  valid_out,
    output reg                  data_vld_out
    );
    
    parameter   Ncnt    =   N/Block;
    parameter   Mcnt    =   M/Block;
    
    parameter       Idle    =   4'd0,
                     DIN     =   4'd1,
                     READ    =   4'd2,
                     Init    =   4'd3,
                     Work    =   4'd4,
                     Work_ext=   4'd5,
                     Post    =   4'd6,
                     Post2    =   4'd8,
                     Done    =   4'd7;
                     
    reg             [3:0]           state_c,state_n;
    
    reg             [M-1:0]         q1,q2;
    reg             [11:0]          shift;
    reg             [11:0]          cnt;
    reg             [5:0]           data_cnt;
    reg             [31:0]          h1;
    reg             [31:0]          h;
   
    reg  signed     [Block+1:0]     add_a;
    reg  signed     [Block+1:0]     add_b;
    reg                             cin;
    reg                             mode,vld_in;
    wire            [Block+2:0]     sum;
    wire                            vld_out;

    reg                             wea_n;        
    reg             [5 : 0]         addra_n ;     
    reg             [127 : 0]       dina_n;                                   
    reg             [5 : 0]         addrb_n; 
    reg                             enb_n;     
    wire            [127 : 0]       doutb_n ; 
                 
    reg                             wea_d;        
    reg             [5 : 0]         addra_d ;     
    reg             [127 : 0]       dina_d;                                   
    reg             [5 : 0]         addrb_d; 
    reg                             enb_d;     
    wire            [127 : 0]       doutb_d ;  
    
//    reg            wea_s;        
//    reg [5 : 0]    addra_s ;     
//    reg [127 : 0]  dina_s;                                   
//    reg [5 : 0]    addrb_s; 
//    reg             enb_s;     
//    wire [127 : 0]  doutb_s ; 
      
     


    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state_c <=  Idle;
        end else begin
            state_c <=  state_n;
        end
    end
    
    always@(*)begin
        case(state_c)
            Idle:begin
                if(valid_in)
                    state_n =   DIN;
                else 
                    state_n =   Idle;
            end
            DIN:begin
                if(!data_vld_in)
                    state_n     =   READ;
                else 
                    state_n     =   DIN;
            end
            READ:begin
                    state_n     =   Init;
            end
            Init:begin
                    state_n     =   Work;
            end
            Work:begin
                if(data_cnt==Ncnt)
                    state_n =   Work_ext;
                else 
                    state_n =   Init;
            end
            Work_ext:begin
                if(vld_out && cnt==N-M-1)
                    state_n =   Post;
                else if(addra_n==0)
                    state_n =   READ;
                else 
                    state_n =   Work_ext;
            end
            Post:begin
//                if( data_cnt==Mcnt)
//                    state_n     =   Done;
//                else 
                    state_n     =   Post2;
            end
            Post2:begin
                if( data_cnt==Mcnt)
                    state_n     =   Done;
                else 
                    state_n     =   Post;
            end
            Done:begin
                    state_n     =   Idle;
            end
            default:state_n =  Idle;
        endcase
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            shift           <=  0;
            q1              <=  0;
            q2              <=  0;
            cnt             <=  0;
            data_cnt        <=  0;
            add_a           <=  0;
            add_b           <=  0;
            cin             <=  0;
            mode            <=  0;
            vld_in          <=  0;
            remainder_out   <=  0;
            valid_out       <=  0;
            wea_n           <=  0;
            wea_d           <=  0;
            h               <=  0;
            h1              <=  0;            
        end else begin
            case(state_c)
                Idle:begin
                    data_cnt<=0;
                    addra_d<=0;
                    addra_n<=0;
                    add_a<=0;
                    add_b<=0;
                end
                DIN:begin
                    if(data_vld_in)begin
                        wea_n<=1;
                        wea_d<=1;
                        dina_n<=dividend_in;
                        addra_n<=addra_n+1;
                        addra_d<=addra_d+1;
                        data_cnt<=data_cnt+1;
                        h1<={dividend_in[127],h1[31:1]};
//                        h1[addra_n]<=dividend_in[127];
                        if(data_cnt<Mcnt)
                            dina_d     <=   divisor_in;
                        else
                            dina_d  <=128'b0;
                    end
                    else begin
                        wea_n<=0;
                        wea_d<=0;
                    end
                end
                READ:begin
                    data_cnt<=0;
                    shift<=M-cnt-1;
                    cin<=0;
                    if(cnt>0)begin
                        addra_n<=31;
                        if(sum[Block+1])
                            mode<=1;
                        else
                            mode<=0;
                    end
                    
                end
                Init:begin
                    if(data_cnt==0)begin
                        add_a<={2'b0,doutb_n[126:0],1'b0};
                        add_b<={2'b0,doutb_d};
                        data_cnt<=data_cnt+1;
                        cin<=0;
                        vld_in<=1;
                   end
                   else if(data_cnt>0)begin
                        if(data_cnt==Ncnt-1)begin
                           add_a<=cnt==0?{mode,doutb_n[127:0],h1[32-data_cnt]}:{mode,doutb_n[127:0],h[0]};
//                            add_a<=cnt==0?{mode,doutb_n[127:0],h[1]}:{mode,doutb_n[127:0],h[0]};
                           add_b<={2'b0,doutb_d};
                           data_cnt<=data_cnt+1;
                           vld_in<=1;
                       end
                       else begin
                           add_a<=cnt==0?{2'b0,doutb_n[126:0],h1[32-data_cnt]}:{2'b0,doutb_n[126:0],h[0]};
//                            add_a<=cnt==0?{2'b0,doutb_n[126:0],h[1]}:{2'b0,doutb_n[126:0],h[0]};
                           add_b<={2'b0,doutb_d};
                           data_cnt<=data_cnt+1;
                           vld_in<=1;
                       end 
                    end  
                    wea_n<=vld_out;
                    dina_n<=sum[Block-1:0];
                    addra_n<=32-data_cnt;
                    cin<=data_cnt>1?sum[Block]:cin;  
                    h<={sum[Block-1],h[31:1]};                 
                end
                Work:begin
                    vld_in<=0;
                    wea_n<=vld_out;
                    q2[shift]<=mode?1:0;
                    if(cnt==0)
                        q1[shift]<=1;
                    else
                        q1[shift]<=mode?0:1;                     
                end
                Work_ext:begin
                    cnt<=vld_out?cnt+1:cnt;
                    vld_in<=0;
                    wea_n<=vld_out;
                    dina_n<=sum[Block-1:0];
                    addra_n<=32-data_cnt; 
                    if(data_cnt==32)begin
                        data_cnt<=0;
                    end                   
                end
                Post:begin
                   mode<=0;
                   vld_in<=data_cnt=='d16 ? 0 : 1;
                   add_a<={2'b0,q1[data_cnt*128+:128]};
                   add_b<={2'b0,q2[data_cnt*128+:128]};
                   data_cnt<=data_cnt+1;
                   cin<=((sum[Block+1]||sum[Block]||sum[Block+2]) &&(data_cnt==0))? 1 :(sum[Block+1]||sum[Block]||sum[Block+2]);
                   valid_out<=data_cnt=='d1 ? 1 : 0;
                end
                Post2:begin
                    vld_in<=0;
//                    vld_in<=data_cnt=='d16 ? 0 : 1;
//                    add_a<={2'b0,q1[data_cnt*128+:128]};
//                    add_b<={2'b0,q2[data_cnt*128+:128]};
//                    data_cnt<=data_cnt+1;
//                    cin<=(sum[Block+1]||sum[Block]||sum[Block+2]);
//                    valid_out<=data_cnt=='d1 ? 1 : 0;
                end
                Done:begin
                    data_cnt<=0;
                end
                default:;
            endcase
        end
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            enb_n               <=  'd0;
            enb_d               <=  'd0;
            addrb_n             <=  'd0;
            addrb_d             <=  'd0;
        end else begin
            if(cnt==0&&state_n==READ)begin
                enb_n           <=  'd1;
                enb_d           <=  'd1;
                addrb_n         <=  'd32;
                addrb_d         <=  'd32;
            end
            else if(state_n==READ)begin
                enb_n           <=  'd1;
                enb_d           <=  'd1;
                addrb_n         <=  'd31;
                addrb_d         <=  'd32;
            end
            else if(state_n==Init)begin
                enb_n           <=  'd1;
                enb_d           <=  'd1;
                addrb_n         <=  addrb_n-1;
                addrb_d         <=  addrb_d-1;
            end
        end
    end
    

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            quotient_out    <=  0;
            data_vld_out    <=  0;
        end else begin
            if(cnt[11]&&vld_out)begin
                quotient_out    <=  sum[127:0];
                data_vld_out    <=  1;
            end
            else if(state_c==Idle)begin
                quotient_out    <=  0;
                data_vld_out    <=  0;
            end
            else begin
                quotient_out    <=  quotient_out;
                data_vld_out    <=  data_vld_out;
            end
        end
    end
    
    

blk_mem_gen_0 Dividend (
  .clka(clk),    // input wire clka
  .wea(wea_n),      // input wire [0 : 0] wea
  .addra(addra_n),  // input wire [5 : 0] addra
  .dina(dina_n),    // input wire [127 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(enb_n),      // input wire enb
  .addrb(addrb_n),  // input wire [5 : 0] addrb
  .doutb(doutb_n)  // output wire [127 : 0] doutb
);
blk_mem_gen_1 Divisor (
  .clka(clk),    // input wire clka
  .wea(wea_d),      // input wire [0 : 0] wea
  .addra(addra_d),  // input wire [5 : 0] addra
  .dina(dina_d),    // input wire [127 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(enb_d),      // input wire enb
  .addrb(addrb_d),  // input wire [5 : 0] addrb
  .doutb(doutb_d)  // output wire [127 : 0] doutb
);
//blk_mem_gen_2 Sum (
//  .clka(clk),    // input wire clka
//  .wea(wea_s),      // input wire [0 : 0] wea
//  .addra(addra_s),  // input wire [5 : 0] addra
//  .dina(dina_s),    // input wire [127 : 0] dina
//  .clkb(clk),    // input wire clkb
//  .enb(enb_s),      // input wire enb
//  .addrb(addrb_s),  // input wire [5 : 0] addrb
//  .doutb(doutb_s)  // output wire [127 : 0] doutb
//);
 
adder_128  #(Block)
    inst(
    .clk(clk),    
    .rst_n(rst_n), 
    .add_a(add_a),  
    .add_b(add_b),  
    .cin(cin),    
    .mode(mode),  
    .sum(sum),
    .vld_in(vld_in), 
    .vld_out(vld_out)
);
    
endmodule