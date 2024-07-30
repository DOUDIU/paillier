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
    input  [Block-1:0]          x,
    input  [Block-1:0]          y,
    input                       valid_in,
    input                       data_vld_in,
    output reg [Block-1:0]      qblock, 
    output reg [N-1:0]          q,
    output reg [N-1:0]          r,
    output reg [Block-1:0]      rblock,
    output                      valid_out,
    output reg                  data_vld_out
);
    
    parameter   Ncnt    =   N/Block;
    parameter   Mcnt    =   M/Block;
    
    parameter       Idle    =   4'd0,
                     DIN     =   4'd1,
                     READ    =   4'd8,
                     Init    =   4'd2,
                     Work    =   4'd3,
                     Work_ext=   4'd4,
                     Post    =   4'd5,
                     Post2   =   4'd6,
                     Done    =   4'd7;
                     
    reg     [3:0]       state_c,state_n;
    
    reg [M-1:0]          q1,q2;
    // reg [M-1:0]          q,r;
    reg     [15:0]     shift;
    
    reg     [15:0]      cnt;
    
    reg     [7:0]       data_cnt;
    wire                 sign;
    reg     sign_in;
    
    reg  signed   [Block+1:0]      add_a;
    reg  signed   [Block+1:0]       add_b;
    reg                         cin,ci;
    reg                         mode,vld_in;
    reg     vld_inq;
    wire    [Block+2:0]       sum;
    wire                cout,vld_out;
    wire            vld_outq;
    wire    [M-1:0] sumq;
    reg  flag;
    
    reg     h1[0:31];
    reg  [31:0] h;

     
    reg            wea_n;        
    reg [5 : 0]    addra_n ;     
    reg [127 : 0]  dina_n;                                   
    reg [5 : 0]    addrb_n; 
    reg             enb_n;     
    wire [127 : 0]  doutb_n ; 
                 
    reg            wea_d;        
    reg [5 : 0]    addra_d ;     
    reg [127 : 0]  dina_d;                                   
    reg [5 : 0]    addrb_d; 
    reg             enb_d;     
    wire [127 : 0]  doutb_d ;  
    
    reg            wea_s;        
    reg [5 : 0]    addra_s ;     
    reg [127 : 0]  dina_s;                                   
    reg [5 : 0]    addrb_s; 
    reg             enb_s;     
    wire [127 : 0]  doutb_s ; 
               
     


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
                    state_n     =   Post2;
            end
            Post2:begin
                if(vld_outq)
                    state_n     =   Done;
                else 
                    state_n     =   Post2;
            end
            Done:begin
                if(data_cnt==31)
                    state_n     =   Idle;
                else 
                    state_n     =   Done;
            end
            default:state_n =  Idle;
        endcase
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            data_vld_out     <=  0;
            shift           <=  0;
            q               <=  0;
            q1<=0;
            q2<=0;
            cnt               <=  0;
            data_cnt<=0;
            add_a<=0;add_b<=0;
            cin<=0;mode<=0;vld_in<=0;
            sign_in<=0;
            qblock<=0;
            rblock<=0;

                ci<=0;
                        wea_n<=0;
                        wea_d<=0;
  
                        h<=0;
                        
        end else begin
            case(state_c)
                Idle:begin
                    data_cnt<=0;
                    data_vld_out<=0;
                    qblock<=0;
                    addra_d<=0;
                    addra_n<=0;
                end
                DIN:begin
                    if(data_vld_in)begin
                        wea_n<=1;
                        wea_d<=1;
                        dina_n<=x;
                        addra_n<=addra_n+1;
                        addra_d<=addra_d+1;
                        data_cnt<=data_cnt+1;
                        h1[addra_n]<=x[127];
                        if(data_cnt<Mcnt)
                            dina_d     <=   y;
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
                        sign_in<=sum[Block+1];
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
                           add_b<={2'b0,doutb_d};
                           data_cnt<=data_cnt+1;
                           vld_in<=1;
                       end
                       else begin
                           add_a<=cnt==0?{2'b0,doutb_n[126:0],h1[32-data_cnt]}:{2'b0,doutb_n[126:0],h[0]};
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
                    
                    if(cnt==0)
                        q1[shift]<=1;
                    else
                        q1[shift]<=mode?0:1; 
                    q2[shift]<=mode?1:0;
                end
                Work_ext:begin
                    cnt<=vld_out?cnt+1:cnt;
                    vld_in<=0;
                    wea_n<=vld_out;
                    dina_n<=sum[Block-1:0];
                    addra_n<=32-data_cnt;                    
                end
                Post:begin
                   data_cnt<=0;
                   vld_inq<=1;
                   ci<=(sum[Block+1]||sum[Block]) ? 1 : 0;
                end
                Post2:begin
                vld_inq<=0;
                    if(vld_outq)begin
                       q<=sumq;
                    end 
                end
                Done:begin
                    if(data_cnt<32)begin
                        qblock<=q[data_cnt*128+:128];
                        rblock<=r[data_cnt*128+:128];
                        data_vld_out<=1;
                        data_cnt<=data_cnt+1;
                    end
                            
                end
                default:;
            endcase
        end
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            enb_n<=0;
            enb_d<=0;
            addrb_n<=0;
            addrb_d<=0;
        end else begin
            if(cnt==0&&state_n==READ)begin
                enb_n<=1;
                enb_d<=1;
                addrb_n<=32;
                addrb_d<=32;
            end
            else if(state_n==READ)begin
                enb_n<=1;
                enb_d<=1;
                addrb_n<=31;
                addrb_d<=32;
            end
            else if(state_n==Init)begin
                enb_n<=1;
                enb_d<=1;
                addrb_n<=addrb_n-1;
                addrb_d<=addrb_d-1;
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
ADDER  #(M)
instq(
.clk(clk),    
.rst_n(rst_n), 
.add_a({3'b0,q1}),  
.add_b({3'b0,q2}),  
.cin(ci),
.sign_in(0),    
.mode(0),   
.sum(sumq),
.vld_in(vld_inq), 
.vld_out(vld_outq)
);
    
endmodule