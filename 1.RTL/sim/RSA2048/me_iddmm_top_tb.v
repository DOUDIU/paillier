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
// Additional Comments:29b9edd90f2afd2bfe92014968e4396a
// 
//////////////////////////////////////////////////////////////////////////////////


module me_iddmm_top_tb();
integer                 i                   ;
parameter               K           = 128   ;
parameter               N           = 32    ;

reg     [K*N-1  : 0]    big_x       = 
4096'h7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0;
reg     [K*N-1  : 0]    big_y       = 4096'h9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a;
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

me_iddmm_top #(
        .K              (K              )
    ,   .N              (N              )
)u_me_iddmm_top(
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
    result      = {result[(K*N-K-1):0],me_result};
    for (i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        result      = {me_result,result[(K*N-1):K]};
    end
    $display("[mmp_iddmm_sp_tb.v]result_iddmm: \n0x%x\n",result);
    $stop;
end
endtask


initial begin
    rsa2048test;
end


endmodule
