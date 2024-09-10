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

// reg     [K*N-1  : 0]    big_x       = 
// 4096'h7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0;
// reg     [K*N-1  : 0]    big_y       = 4096'h9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a;
// reg     [K*N-1  : 0]    result_confirmed =        4096'h20bd63e2a5df74863f6d6bd1728d730b96f08dda603b5a292cfeb83d5e0d809bdb05763eb1ff69f16bd9a273c13db84a5a214f39e8722f98fbce6edebb5f639092e38a6c7fc0f2144ee7f18cc76f5f8f121edd1ccd4b9cf34687b0cb59faf1eae62eb7f84c0df3148ed46e252544680e4119430ecd112080224dddd8b44e03516ccb1724f1f51c4f9ace5a16dd5ecd35aa6bfea8b352e5ba6d4426ceafff58facd5d8e9e4f785f67272a8c8ed6d8ea273d3a2733ce185f0f5d09d11da80e9581b3c56ff285abec4c00e094f37059b17331855dd184e7e66fd6c0ad0457a8fa2a29dfa9568d7d4f1f85be1c5a01eb240e7906630f9cc63b66284b1a678260ef0cb86997a3a59541f681cb7325f71e9f470cc1a7580bc0d81478359b9ca20bd35527521ee4e02093e5dcd8580f9db5251dcb95c89c3e5d76a6df0b897033dc38008daa1502367d919ea7126c3d6631ddac5528278f2c64a88b1bf8ed628f71af7970bd5b6d2ee0c47eeed3d2a63dba9d15cb9c14cbeb76cdc6199d0d49fe7c91ad188baf077c710179534b70a8437badac400af62c651b7edb63b45bea8fd4829e052e1c2f27ff8d5fc10a67f2f41de89106a7b996c88c75178449475c76185b896b886de6d00640ddb5da77ea61757b9a7b56294a502e2270de3388d4374c9ec087ab45fc7680027497c86463f027011a8d773c94912d51698c66d05769e2ff5c;

reg     [K*N-1  : 0]    big_x       = 
4096'h62473723121fa1413366979bab6cc11848075252b92b3ba6392b18c5dac4bb3bbb03952a4b1ffb72e3b42d816e95cdbc795190d7136ef06893e9e0edcf68e60908a64a985ce4543f532db8680aef25a08fe25cff8f16ef461c39dd3f3770f3c0eb3f117148346e81bb675dfddeed6cdc44728af1f65a183497fa5778bace682a4615f6d8ceaf04d9deae0cc36471f5d8c2c58f918c13f6caefe5180bddbea1bb88a34d4228209dee02373aa70ee7b823038f754ebbf1c6ff21ffc2762947cfc3e30d11a86700f24acc498db5f6ae9d8722c14c1110e2abcbb3236432b273c96b1e61bc294c6e6ac50a8da36e8518371c5b3d2a3c3ae45ab1257391618070be8787424474c82d75ce19589589045491530d5a6ffedeef9f936385c23e95e78172a889a8cd876bba43b1cba429296abac9ffbd75ca32e5025f52c694a4b726333b93441ee022dc10406fc8d535fbffd6ae67006c33c6b2d146a30242a3556f3a097273a680017415c2144dd107d3d22501835d2c677cbf0d5761adcea720bf30f53a26d908d0adc18ac8f055810f8aebc94858b8b7bce242223817bb92cd14bf5435be247bc802c59f144a6f47178e0de255f3ec0de028cd430102c1d17d8b11198242a0017121481a7be0118b2e3c6148678d359b8d7696e06745f97c1c1eddcba38c87f0db56426fac65bd91fbf351580f91ba4485f3996feb21510c6471ad24;
reg     [K*N-1  : 0]    big_y       = 4096'h11401bc48162751614fac47d1fac04c9195777f3a01f5da7aa3524c22db5f72c98bb07fa84b723bb05c0c31facd31202088adbcf8bc9126f8b823cb2c0badf10baf9f085a090db04cd4562520c0d9920c19cdec00e6971c9546545205d13acf70029be900c569d7c1b53be7459cea2d73b855f0e825fb421ef85d3709a651a8a;
reg     [K*N-1  : 0]    result_confirmed =        4096'h7f6fa78ae2840394ee397a24bab21a453df5f2f8ce92cd46d26507448514ce6351d8152e2cfba339df17841599189cd97965af0e86b623e212771c8d608417b80b0e3fb2c2c85e8cdfd75b2d3af15a86bd204d5662616f44f5bb6a6a19f120b0ebfb4e4958bc0d970fcb2c339987a162c2762cfed24e0d420c078c78dc554a6f421719fe093fccb661034b9b6499671860d85741853ec1577dcb0cf48ff57bc29edc6ac834ca63ba83f61694000ead423c2ad71ab54965d76f508b7ef180a480f793466c039e4edebce56dbf88320d065662dec9fd6c555801caa3be78b0189eb0aa6c38dacb8602aba3a885d475c54c5bf8c3b324e6ca2e6a309d84f3175225d750fd52e9e94a5d9b6189ab4f48fff567f69638adf3fc82ac89c4f3a851d1ed43277a6b0718f16c0cec1c7d90b37b32d26a037ba40de2c03b84b2f0c7dc146a7c20727d7b47aedbcd3872341753c378df7b5e58699fde4ae3262d2b10aa3bafdc1939e5d1e452daaac3d4d4c33c8adce811fe6a76a68c7e13e2ce831e17232642f421b3eb97be3a70fe4311dbf92ca65e7512c4564e4049410786f0c4d44402116bd9f93795b854b1faf16473ca2fcdde45a1a6aebefab4a83f153aabea595243f1b9d384795fa062df9dbc8b9b84e93a783c9aa4cd34352bca7aa1b6953d7fa5efd89ea2a9c3c912d1b23885fe34f449a1f8ca9ab08679fbe2acf7144db623;
reg     [K*N-1  : 0]    result      =   0   ;
reg                     clk         =   0   ;
reg                     rst_n       =   0   ;
reg                     me_start    =   0   ;
reg     [K-1    : 0]    me_x        =   0   ;
reg                     me_x_valid  =   0   ;
reg     [K-1    : 0]    me_y        =   0   ;
reg                     me_y_valid  =   0   ;
wire    [K-1    : 0]    me_result           ;
wire                    me_valid            ;

parameter               PERIOD      =   4   ;
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

task me_4096_test; begin
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
    #100;
    assert(result ==  result_confirmed)
        $display("result is correct!");
    else
        $display("result is wrong!");
    $stop;
end
endtask


initial begin
    me_4096_test;
end


endmodule
