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


module tb_nrdiv();
    parameter   N=4096,M=2048,Block=128;
    parameter   max=32'h0a347456;
    
    reg                     clk;
    reg                     rst_n;
    
    reg     [Block-1:0]         x;
    reg     [Block-1:0]         y;
    reg                     div_vld_in,valid_in;
    wire    [N-1:0]         q,r; 
    wire                    div_vld_out,valid_out;  
    wire    [N-1:0]         q_ref,r_ref;
    
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
        wait(div_vld_out)
        $display("%h",q_ref);
        $display("%h",q);
//        $display("%h",r_ref);
//        $display("%h",r);
        #2000
        $stop;
    end

   
NR_Div#(
    .N              (N),
    .M              (M),
    .Block          (Block)
)inst(
   .clk             (clk),
   .rst_n           (rst_n),
   .x               (x),
   .y               (y),
   .valid_in        (valid_in),
   .data_vld_in     (div_vld_in),
   .q               (q),
   .r               (r),
   .valid_out       (valid_out),
   .data_vld_out    (div_vld_out)
);

//    reg     [N-1:0]   add_a,add_b;
//    reg                 cin,mode,vld_in;
//    wire    [N-1:0]   sum;
//    wire                cout,vld_out; 
    
//    always #10  clk=~clk;
//    initial begin
//        clk=0;
//        rst_n=0;
//        div_vld_in=0;
//        x=0;
//        y=0;
//        add_a=0;
//        add_b=0;
//        vld_in=0;
//        #500
//        rst_n=1;
//        #30
//        mode=0;
////        vld_in=1;
//        repeat(16)@(posedge clk)begin
//            repeat(4)begin
//                x={x[95:0],$random};
//                y={y[95:0],$random};
//            end
//            n={n[N-1-128:0],x};
//            d={d[N-1-128:0],y};
//        end
//        repeat(16)@(posedge clk)begin
//            repeat(4)begin
//                x={x[95:0],$random};
//            end
//            n={n[N-1-128:0],x};
//        end 
//        d={2048'b0,d[2047:0]} ;
//        #20
//        add_a=n;
//        add_b=d;
//        cin=0;
//        vld_in=1;
//        #20
//        vld_in=0;
//        wait(vld_out)
//        #2000
//        $display("%h",sum);
//        $display("%h",q_ref);
//        $display("%h",r_ref);
////        $display("%h",r);
//        $stop;
//    end

   
//ADDER  #(N)
//inst(
//.clk(clk),    
//.rst_n(rst_n), 
//.add_a(add_a),  
//.add_b(add_b),  
//.cin(cin),    
//.mode(mode),   
//.sum(sum),
//.cout(cout),
//.vld_in(vld_in), 
//.vld_out(vld_out)
//);
   
endmodule
