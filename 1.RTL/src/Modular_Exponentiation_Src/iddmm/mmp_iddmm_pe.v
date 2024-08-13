/*
*   License:MIT
*   Copyright (C)  2020, HDU E-M-T GROUP 
*
*   Permission is hereby granted, free of charge, to any person obtaining 
*   a copy of this software and associated documentation files (the "Software"), 
*   to deal in the Software without restriction, including without limitation 
*   the rights to use, copy, modify, merge, publish, distribute, sublicense, 
*   and/or sell copies of the Software, and to permit persons to whom the 
*   Software is furnished to do so, subject to the following conditions:
*　
*　 The above copyright notice and this permission notice shall be included 
*   in all copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
*   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
*   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
*   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
*   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
*   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
*   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*   Name        :IDDMM algorithm,mm pipeline process element
*   Description :
*   Orirgin     :20200717
*                20200721
*   Author      :helrori2011@gmail.com
*   Timing      :mmp_review.xlsx
*/
module mmp_iddmm_pe #(
    parameter L1 = 0     ,// First mul128 latency
    parameter L2 = 0     ,// First add latency
    parameter L3 = 0     ,// m1*s latency
    parameter L4 = 0     ,// mj*q latency
    // parameter MULT_METHOD = "COMMON",
    // parameter ADD1_METHOD = "COMMON",
    // parameter ADD2_METHOD = "COMMON",
    parameter MULT_METHOD  = "TRADITION",   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8"    :VEDIC MULT, MULT_LATENCY=8 
    parameter ADD1_METHOD  = "3-2_PIPE1",   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,stage 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,stage 1,ADD1_LATENCY=1
                                            // 
    parameter ADD2_METHOD  = "3-2_DELAY2",  // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 

    parameter D5 = 0     ,// if ADD2_METHOD=="3-2_DELAY2" D5 should be 1,else 0
    parameter K  = 128   ,// K bits in every group,fixed do not modify!
    parameter N  = 32     // Number of groups,fixed do not modify!
)(
    input   wire                    clk           ,
    input   wire                    rst_n         ,

    // Data
    input   wire [K-1          :0]  xj            ,
    input   wire [K-1          :0]  yi            ,
    input   wire [K-1          :0]  mj            ,
    input   wire [K-1          :0]  m1            ,
    input   wire [K-1          :0]  aj            ,

    // Timing ctrl
    input   wire                    ctl_carry_clr ,// (j==0 && i==0);
    input   wire                    ctl_carry_ena ,// (j==N);
    input   wire                    ctl_carry_sel ,// (j==N);
    input   wire                    ctl_c_pre_clr ,// (j==0 && j00);
    input   wire                    ctl_c_pre_ena ,// (jref);will be used if D5==1
    input   wire                    ctl_q_ena     ,// (j==0 && j00);

    // Result
    output  reg                     carry         ,
    output  wire [K-1          :0]  uj  
);
//-------------------------------------------------------------------------------
reg  [K-1   :0]     q;
reg  [K     :0]     c_pre;
wire [K     :0]     c;
wire [2*K-1 :0]     s,s_;
wire [2*K-1 :0]     r;

wire [2*K-1 :0]     xy  ;//x*y
wire [K-1   :0]     m1s;//m1*s%beta
wire [2*K   :0]     u_c;//s+r+c
//-------------------------------------------------------------------------------
wire [K-1   :0]     mj_;
wire [K-1   :0]     aj_;
wire                ctl_carry_clr_;
wire                ctl_carry_ena_;
wire                ctl_carry_sel_;
wire                ctl_c_pre_clr_;
wire                ctl_c_pre_ena_;
wire                ctl_q_ena_;
wire [127   :0]     __;
wire                cena;
//-------------------------------------------------------------------------------
//pipeline stage 0
/*
    s = a[j]+x_[j]*y_[i]
    s = mm(s,2*k)
    if j==n:
        s = s+carry
*/
mmp_iddmm_shift#(
    .LATENCY ( L1+L2+L3+L4+D5),
    .WD      ( 1             )
)shift_ctl_carry_clr(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( ctl_carry_clr ),
    .b_out   ( ctl_carry_clr_)      
);
mmp_iddmm_shift#(
    .LATENCY ( L1+L2+L3+L4+0 ),
    .WD      ( 1             )
)shift_ctl_carry_ena(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( ctl_carry_ena ),
    .b_out   ( ctl_carry_ena_)      
);
mmp_iddmm_shift#(
    .LATENCY ( L1            ),
    .WD      ( 1             )
)shift_ctl_carry_sel(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( ctl_carry_sel ),
    .b_out   ( ctl_carry_sel_)      
);
mmp_iddmm_shift#( //这里使用对Aj延时。对Aj延时等效于对j延时
    .LATENCY ( L1            ),
    .WD      ( K             )
)shift_Aj(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( aj            ),
    .b_out   ( aj_           )      
);
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        carry <= 1'd0;
    end 
    else if(ctl_carry_clr_)begin
        carry <= 1'd0;
    end 
    else if(ctl_carry_ena_)begin
        carry <= c[0];
    end
end
mmp_iddmm_mul128#(
    .LATENCY  ( L1             ),
    .METHOD   ( MULT_METHOD    )   
)mmp_iddmm_mul128xy(
    .clk      ( clk            ),
    .rst_n    ( rst_n          ),
    .a_in     ( xj     [127:0] ),//128
    .b_in     ( yi     [127:0] ),//128
    .c_out    ( xy     [255:0] ) //256
);
mmp_iddmm_addfirst #(
    .LATENCY  ( L2             ),
    .METHOD   ( ADD1_METHOD    )
)mmp_iddmm_addfirst(
    .clk      ( clk            ),
    .rst_n    ( rst_n          ),
    .a_in     ( xy    [255:0]  ),//256
    .b_in     ( aj_   [127:0]  ),//128
    .c_in     ( ctl_carry_sel_?carry:1'd0),//1
    .d_out    ( s     [255:0]  )
);
//-------------------------------------------------------------------------------
//pipeline stage 1
/*
    if j==0:
        q = mm(s,k)*mm(p1,k)%beta
*/
mmp_iddmm_mul128#(
    .LATENCY  ( L3             ),
    .METHOD   ( MULT_METHOD    )      
)mmp_iddmm_mul128m1s(
    .clk      ( clk            ),
    .rst_n    ( rst_n          ),
    .a_in     ( m1    [127:0]  ),//128
    .b_in     ( s     [127:0]  ),//128
    .c_out    ( {__,m1s}       ) //256 use LSW 128bits
);
//-------------------------------------------------------------------------------
//pipeline stage 2
/*
    r   = q*p_[j]
*/
mmp_iddmm_shift#(//这里使用对Mj延时。对Mj延时等效于对j延时
    .LATENCY ( L1+L2+L3      ),
    .WD      ( K             )
)shift_Mj(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( mj            ),
    .b_out   ( mj_           )      
);
mmp_iddmm_shift#(
    .LATENCY ( L1+L2+L3      ),
    .WD      ( 1             )
)shift_ctl_q_ena(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( ctl_q_ena     ),
    .b_out   ( ctl_q_ena_    )      
);
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        q <= {(K){1'd0}};
    end 
    else if(ctl_q_ena_)begin
        q <= m1s;
    end
end
mmp_iddmm_mul128#(
    .LATENCY  ( L4             ),
    .METHOD   ( MULT_METHOD    )      
)mmp_iddmm_mul128r(
    .clk      ( clk           ),
    .rst_n    ( rst_n         ),
    .a_in     ( mj_   [127:0] ),//128
    .b_in     ( q     [127:0] ),//128
    .c_out    ( r     [255:0] ) //256
);
//-------------------------------------------------------------------------------
//pipeline stage 3
/*
    buf0= s+r+c            
    u   =  mm(buf0,k)
    c   = (buf0>>k)
*/
mmp_iddmm_shift#(
    .LATENCY ( L1+L2+L3+L4   ),
    .WD      ( 1             )
)shift_ctl_c_pre_ena(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( ctl_c_pre_ena ),
    .b_out   ( ctl_c_pre_ena_)
);
assign cena=(D5==0)?1'd1          :
          (D5==1)?ctl_c_pre_ena_:
          1'd1;
mmp_iddmm_shift#(
    .LATENCY ( L1+L2+L3+L4   ),
    .WD      ( 1             )
)shift_ctl_c_pre_clr(
    .clk     ( clk           ),
    .rst_n   ( rst_n         ),
    .a_in    ( ctl_c_pre_clr ),
    .b_out   ( ctl_c_pre_clr_)
);
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        c_pre <= {(K+1){1'd0}};
    end 
    else if(ctl_c_pre_clr_)begin
        c_pre <= {(K+1){1'd0}};
    end 
    else if(cena)begin
        c_pre <= c;
    end
end
mmp_iddmm_shift#(
    .LATENCY  ( L3+L4         ),
    .WD       ( 2*K           )
)shift_S(
    .clk      ( clk           ),
    .rst_n    ( rst_n         ),
    .a_in     ( s             ),
    .b_out    ( s_            )
);
mmp_iddmm_addend #(
    .LATENCY  ( D5            ),
    .METHOD   ( ADD2_METHOD   )
)mmp_iddmm_addend(
    .clk      ( clk           ),
    .rst_n    ( rst_n         ),
    .a_in     ( c_pre  [128:0]),//129
    .b_in     ( r      [255:0]),//256
    .c_in     ( s_     [255:0]),//256
    .d_out    ( u_c    [256:0]) //257
);
assign  c  = u_c[2*K+1-1:K];
assign  uj = u_c[K-1    :0];

endmodule