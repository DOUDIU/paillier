`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 22:03:08
// Design Name: 
// Module Name: me_iddmm_top_tb
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


module me_iddmm_top_tb();
integer                 i                   ;
parameter               K           = 128   ;
parameter               N           = 16    ;

reg     [K*N-1  : 0]    big_x       = 
2048'hABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744;
reg     [K*N-1  : 0]    big_y       = 2048'hD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9;
reg     [K*N-1  : 0]    result      =   0   ;
parameter               PERIOD      =   10  ;
reg                     clk         =   0   ;
reg                     rst_n       =   0   ;
reg                     me_start    =   0   ;
reg     [K-1    : 0]    me_x        =   0   ;
reg                     me_x_valid  =   0   ;
reg     [K-1    : 0]    me_y        =   0   ;
reg                     me_y_valid  =   0   ;
wire    [K-1    : 0]    me_result           ;
wire                    me_valid            ;

initial begin
    forever #(PERIOD/2)  clk=~clk;
end
initial begin
    #(PERIOD*2) rst_n  =  1;
end

me_iddmm_top u_me_iddmm_top(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .me_start       (me_start       )

    ,   .me_x           (me_x           )
    ,   .me_x_valid     (me_x_valid     )

    ,   .me_y           (me_y           )
    ,   .me_y_valid     (me_y_valid     )

    ,   .me_result      (me_result      )
    ,   .me_valid       (me_valid       )
);

task rsa2048test; begin
    #(PERIOD*100)
    me_start = 1;
    #(PERIOD)
    me_start = 0;
    #(PERIOD*10)
    for (i = 0; i <= N; i = i + 1) begin
        @(posedge clk)
        me_x        =   big_x >> (K*i);
        me_x_valid  =   1;
        me_y        =   big_y >> (K*i);
        me_y_valid  =   1;
    end
    me_x        =   0;
    me_x_valid  =   0;
    me_y_valid  =   0;
    wait(me_valid);
    result      = {result[(K*N-128-1):0],me_result};
    for (i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        result      = {me_result,result[(K*N-1):128]};
    end
    $display("[mmp_iddmm_sp_tb.v]result_iddmm: \n0x%x\n",result);
    $stop;
end
endtask


initial begin
    rsa2048test;
end


endmodule
