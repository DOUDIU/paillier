module iddmm_top_tb();

parameter   K       =   128         ;// K bits in every group
parameter   N       =   32          ;// Number of groups
parameter   ADDR_W  =   $clog2(N)   ;

reg [K-1  :0]   wr_m1_= 128'hecd18b11b6a41b9bb3ef4fcae3ba221f;//m1=(-1*(mod_inv(m,2**K)))%2**K 
reg [K*N-1:0]   big_m = 4096'hff5f4906fd176bc241535c78955d02f4d0acf376d736ae280077887200c758b7781b4432fa8baca2a81ad6fb0817051a00fccf8e15c63048681bcf8342b56433abd550affa489b289cd4f0482adce321c8cf4374ce15267692dfc8b0da108f4bb0e922d4a28402ef785c2516f6296486f8505ac3df05c0f953acce65e2dc5f1e59965ded73fa18ffb482ad1a2e5433d4df8211de12a3e7a71a1a084fed671fb11eeaf76f640c4fd549ea307b6622f798f027786e79232206de1507281d84c719209d408bc85f9ed2e1b82ecf72ff805a45221dc712c45a8dbc375e9b64227ec6b659a75fc5b5e051e776bcd9f4f6d82ebaff89a48c8494d6ed072372b846156af229994baab390ec57c00130255acc2cdf975783df4678153f0ca51b854425b1568b5b8b53239f50dd39fc53c3d41827a0687c435f6de5e98843def3fb7b0f7e701cdfb51517d6628392bd9291c16282556f5581766dd6a0a426a35312237399f93ad69502592c0f6d1864ba0b75600ee04cb406bcb833bc98527a0ac1249c6a918456b06f24611770c1708426b4d9041f7fe83be68fbc7018e461951d234ebf00227b4301911e24055c745203c888276f4db0c05f66514ae4e6b4bf4c8914e36c4a94bf57bf807dd40c7572d1a99c27d9f58af0877bb217c081d750d5edbe3c45eafc3ea6786560fa819873452cc8bffc7ab998ab70496b77fdadffb7ef2621;
reg [K*N-1:0]   big_x = 4096'h7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0;
reg [K*N-1:0]   big_y = 4096'h9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a;
reg [K*N-1:0]   iddmm_result_confirm = 4096'h47a205a79ebd89394649f7942601cf1ea095b448c7c5054237b6657725c08e56a4edc79ccc6c9f83c801b2098246b1f3eb991a4634cd993b221dbd3b9b0fecacf4ffd56189592bd5c668399022496765705a0c9dcfb5da9d79c0e001f14ef78f2c895ab0bbf9b5ea5021fc316a0aa7b17b4b2c8ef8723f2ac3698ec872875b69ceaa84e184c4481bfa53cb2d99f029439fe9564393756f591dd20c30984eddbeb44e9e5104dbc64fbf4bc88319115cf49b21eb137f5a1576ea5819224800f2977285a611de039cd1049a62cb3f4e67d9c65dc48af76555819e57712018989b6f46fd06e477938b79ee8246fd27349abef24f5738173925dbfbace3f264e7edec8cb836900e60b5a59af3c56f14d8953d3411f9bad910846eff8d9f1796723722a88dda362be3abfec27f67cc32bdc7d41e2848d56d9d91cd754765a3e5a171e5964d862cc64a3437e1a35a997fe47ead24c2e5823ef70acc9ac946f3f00bc0177146d68369a8b607a72392b9dea6ee7477baaaa4a50106aa648ff4f4da63d8f3306116466a289c0d9927606cd104cfe8e3ae65849bbe124fc61ebf289c2f5cf1399aa5bf08aeef91fb4b542ce253a87b89ec9ce0a4be3914a67d44b6a8fa5678d8e8d1185ab86cac8472aad50c039115b61790a2c7dbe2e7bdc94990f1d6bb0aa0a5613d7387216fe18c1a0fe6b9388bf708ee9a9074da10a576774987b41f6a;

reg [K*N-1:0]   iddmm_result = 0; 

reg clk = 0;
reg rst_n = 0;
always #5 clk = ~clk;
initial #30 rst_n = 1;


reg     [2          :0]     wr_ena          ;
reg     [ADDR_W-1   :0]     wr_addr         ;
reg     [K-1        :0]     wr_x            ;
reg     [K-1        :0]     wr_y            ;
reg     [K-1        :0]     wr_m            ;
reg     [K-1        :0]     wr_m1           ;

reg                         task_req        ;
wire                        task_end        ;
wire                        task_grant      ;
wire    [K-1        :0]     task_res        ;

reg     [K*N-1      :0]     iddmm_result    ;

task single_request();
    integer i;

    wr_ena      <=  0;
    wr_addr     <=  0;
    wr_x        <=  0;
    wr_y        <=  0;
    wr_m        <=  0;
    wr_m1       <=  0;

    task_req    <=  0;

    @(posedge rst_n);
    for(i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
    end

    for(i = 0; i < 32; i = i + 1) begin
        @(posedge clk);
        wr_ena      <=  3'b111;
        wr_addr     <=  i;
        wr_x        <=  big_x[i*K +: K];
        wr_y        <=  big_y[i*K +: K];
        wr_m        <=  big_m[i*K +: K];
        wr_m1       <=  wr_m1_;
    end
    
    @(posedge clk);
    task_req    <=  1;
    @(posedge clk);
    task_req    <=  0;

    wait(task_grant);
    for(i = 0; i < 32; i = i + 1) begin
        @(posedge clk);
        iddmm_result[i*K +: K]   <=  task_res;
    end
    for(i = 0; i < 10; i = i + 1) begin
        @(posedge clk);
    end
    $display("iddmm_result = %h", iddmm_result);    
    assert(iddmm_result ==  iddmm_result_confirm)
        $display("result is correct!");
    else
        $display("result is wrong!");
    $stop;
endtask


initial begin
    single_request();
    $stop;
end

iddmm_top #(
        .K              (K          )
    ,   .N              (N          )
)iddmm_top_inst(
        .clk            (clk        )
    ,   .rst_n          (rst_n      )

    ,   .wr_ena         (wr_ena     )
    ,   .wr_addr        (wr_addr    )
    ,   .wr_x           (wr_x       )
    ,   .wr_y           (wr_y       )
    ,   .wr_m           (wr_m       )
    ,   .wr_m1          (wr_m1      )

    ,   .task_req       (task_req   )
    ,   .task_end       (task_end   )
    ,   .task_grant     (task_grant )
    ,   .task_res       (task_res   )
);


endmodule