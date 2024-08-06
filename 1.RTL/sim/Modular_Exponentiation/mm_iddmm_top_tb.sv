module mm_iddmm_top_tb();

localparam K       = 128 ;
localparam N       = 32  ;

reg     clk = 0;
reg     rst_n = 0;

always #5 clk = ~clk;
initial #100 rst_n = 1;
reg [K*N-1:0]   big_x = 4096'hc1df0542cbba9f6aed3aeeb7401bb37903c58d9d5f21d65ad1b98dcdea604d1c93002beae5e3ba36e68c53947334535de07fa62dae8dab29a705764d6361d337bb8f8b2eb7544d4d712448daab680c1a23e1a1ba6f85f82c796d8ac217525ec6351e343ccab4d1081fa4b3cd63a8ad43d70848b8fc6c47672bc104c8e0c70a7ed425406b85000155592afd87614ce8fb8b69e1a113a78b1d62fc60d72fbb16b0577f67c5068d4d3a149920a9574965fecb6c2cc3243acc4673fc5610f2fcb59ffe99b9a19e5cbe58c395a594a0c0b53320271837ed95054f858a97e561b3145391ab16dcbbe5e58da8e7dec86babca61e844a72f26bf3f52d87bd7a4f58113f32a6b621a0430;
reg [K*N-1:0]   big_y = 4096'h6ba000aae20213f722fc5470729ad8c24582b0a2770f4d03cacace6d643e651b3693808cdb14d627e66041a01d0b880b6ef860f128dc00763a17e8ba2ab82d8ab74abf1f8fefb8084c79fea078d240f9494e015693644635d3666a738e44cd1fb2d2bba34fa9229c630c1214fd0da66429175f7c0b25e19ff5d8c30a95c3ff70bffcbbffe9f71a5184eb10d8db7ea06a0b7a3bed231377d8e2635da172fe2f9ee2976a8661384cd36092502be1117958dd2252d84ecb53d63ab1d04be31f760212af374c8ca98d1a7e7ff29c24b7a9c25b3ed35c3c2be6e625033ae984a61426af0239b50b0ae849384e14120366b6e6233bc679d74362ca5c0ac2278762821bf4e67587acfb1f5386615fa7c2670cc010f322cf6731fd4120f7bf5c1fa33186c9e14c325bd9ef9439c15aa06101167d29fd728f42a66b04eea3db148ada8b23e680706b56d39c1724af0bf491075de4f6c18592054345a7ffe93b14d10e6532512dc88a4b43c51b8dd43dd80a31232e33882a7f3c0ae1364e2cd2bbe99113be5a98ca21cc10e3aaff2f53ff8f1e7125df9f31683fca3fd08474702171f46f7278edc0cc248a2d3d5d3a82515bb2c5d6b16880499bf455a41291e1a88e373fb6bcde50818f640570928e34371de7aa86df6e792c98fe8002807e016f6e27b47e127a6877402aaf23dde9b00b1520551678990e9d17cae6f8b0a8208391db5780;
wire [K*N-1:0]   result_confirm;
assign result_confirm =
4096'h39979947f84591c7011dc06e677dc75ce460fd29a14d022555732743a714c8cf18ff8ebe1a8b01aabd6d421cf63ee8f0870f09badc9224f9fed2af198c5da91847bb617d0e28a369453604f44580667d19c6cbf1365dc89c74126ac7c4ff6f974fdb853bf92e50975dd7c5e6e3bed5c2c20b11011a8f308c56d193bf1461326716180d26596840499b727663b9271e7ad17020b0202ffeb0f83d610245b396e63ea93b568be6ad20dcf85bd66411987b9c99a9756a6b21c03e7d16d9807cf9b1f63208f216144c08c5c571343d1d05032239a444b890d96abed9f0cbacfbbfab6f2f28f1460f6ed4e906b303d12bf4f1ec40d1a7d4a572dfa8b09a0fa5730ff88981780bb3f309afc99fab51bba5b1e5c768809c880bda44efa7cfbb03ac9d317cd6211d142fd3eb964d872d3a8f833a19a0c0b825bdf7972a22e3133a538a063430cfef88eb7aa8f028d88a7272678ccb0deff5bd7ae373a62ffa5789c874dac229ecda874772927346cf18c197bae55c93c16eeacbea4acc52a6abd20e95f0aa41adb389c6468400741f2a27fbee12e8de39d80f67fa81e252caa8d46903016e3202345b9abeab552d7f912d346ce1603e209010af32ef06b3286e86daeb8ced3dfc0a45097f952aade6a537c61f26a2e1c47658ce092e9b6c29a02604523b931dd247099e3123c04a84ebad9f2f569be1df94c3fe93f1c92358cd60233349;

reg                mm_start     ;
reg    [K-1:0]     mm_x         ;
reg                mm_x_valid   ;
reg    [K-1:0]     mm_y         ;
reg                mm_y_valid   ;
wire   [K-1:0]     mm_result    ;
wire               mm_valid     ;
reg     [K*N-1  :   0]     MM_RESULT;

mm_iddmm_top#(
        .MULT_METHOD    ("COMMON"       )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD    ("COMMON"       )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                            // 
    ,   .ADD2_METHOD    ("COMMON"       )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 
    ,   .K              (K              )
    ,   .N              (N              )
)mm_iddmm_top_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .mm_start       (mm_start       )
    ,   .mm_x           (mm_x           )
    ,   .mm_x_valid     (mm_x_valid     )
    ,   .mm_y           (mm_y           )
    ,   .mm_y_valid     (mm_y_valid     )
    ,   .mm_result      (mm_result      )
    ,   .mm_valid       (mm_valid       )
);


initial begin
    mm_start        <=  0;
    mm_x            <=  0;
    mm_y            <=  0;
    mm_x_valid      <=  0;
    mm_y_valid      <=  0;

    @(posedge rst_n);
    #40
    @(posedge clk);
    mm_start    <=  1;
    @(posedge clk);
    mm_start    <=  0;
    for(integer i = 0; i < 32; i = i + 1) begin
        @(posedge clk);
        mm_x        <=  big_x[i*K+:K];
        mm_y        <=  big_y[i*K+:K];
        mm_x_valid  <=  1;
        mm_y_valid  <=  1;
    end
    @(posedge clk);
    mm_x_valid  <=  0;
    mm_y_valid  <=  0;
    wait(mm_valid);
    MM_RESULT      = {MM_RESULT[(K*N-K-1):0],mm_result};
    for (integer i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        MM_RESULT      = {mm_result,MM_RESULT[(K*N-1):K]};
    end
    $display("MM_RESULT: \n0x%x\n",MM_RESULT);
    #100;
    assert(MM_RESULT ==  result_confirm)
        $display("result is correct!");
    else
        $display("result is wrong!");
    $stop;

end



endmodule