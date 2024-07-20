module mm_iddmm_top_tb();

localparam K       = 128 ;
localparam N       = 32  ;

reg     clk = 0;
reg     rst_n = 0;

always #5 clk = ~clk;
initial #100 rst_n = 1;
reg [K*N-1:0]   big_x = 4096'hc1df0542cbba9f6aed3aeeb7401bb37903c58d9d5f21d65ad1b98dcdea604d1c93002beae5e3ba36e68c53947334535de07fa62dae8dab29a705764d6361d337bb8f8b2eb7544d4d712448daab680c1a23e1a1ba6f85f82c796d8ac217525ec6351e343ccab4d1081fa4b3cd63a8ad43d70848b8fc6c47672bc104c8e0c70a7ed425406b85000155592afd87614ce8fb8b69e1a113a78b1d62fc60d72fbb16b0577f67c5068d4d3a149920a9574965fecb6c2cc3243acc4673fc5610f2fcb59ffe99b9a19e5cbe58c395a594a0c0b53320271837ed95054f858a97e561b3145391ab16dcbbe5e58da8e7dec86babca61e844a72f26bf3f52d87bd7a4f58113f32a6b621a0430;
reg [K*N-1:0]   big_y = 4096'h6ba000aae20213f722fc5470729ad8c24582b0a2770f4d03cacace6d643e651b3693808cdb14d627e66041a01d0b880b6ef860f128dc00763a17e8ba2ab82d8ab74abf1f8fefb8084c79fea078d240f9494e015693644635d3666a738e44cd1fb2d2bba34fa9229c630c1214fd0da66429175f7c0b25e19ff5d8c30a95c3ff70bffcbbffe9f71a5184eb10d8db7ea06a0b7a3bed231377d8e2635da172fe2f9ee2976a8661384cd36092502be1117958dd2252d84ecb53d63ab1d04be31f760212af374c8ca98d1a7e7ff29c24b7a9c25b3ed35c3c2be6e625033ae984a61426af0239b50b0ae849384e14120366b6e6233bc679d74362ca5c0ac2278762821bf4e67587acfb1f5386615fa7c2670cc010f322cf6731fd4120f7bf5c1fa33186c9e14c325bd9ef9439c15aa06101167d29fd728f42a66b04eea3db148ada8b23e680706b56d39c1724af0bf491075de4f6c18592054345a7ffe93b14d10e6532512dc88a4b43c51b8dd43dd80a31232e33882a7f3c0ae1364e2cd2bbe99113be5a98ca21cc10e3aaff2f53ff8f1e7125df9f31683fca3fd08474702171f46f7278edc0cc248a2d3d5d3a82515bb2c5d6b16880499bf455a41291e1a88e373fb6bcde50818f640570928e34371de7aa86df6e792c98fe8002807e016f6e27b47e127a6877402aaf23dde9b00b1520551678990e9d17cae6f8b0a8208391db5780;


reg                mm_start     ;
reg    [K-1:0]     mm_x         ;
reg                mm_x_valid   ;
reg    [K-1:0]     mm_y         ;
reg                mm_y_valid   ;
wire   [K-1:0]     mm_result    ;
wire               mm_valid     ;
reg     [K*N-1  :   0]     MM_RESULT;

mm_iddmm_top#(
        .K              (K                  )
    ,   .N              (N                  )
    ,   .ADDR_W         ($clog2(N)          )
)mm_iddmm_top_inst(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .mm_start       (mm_start           )
    ,   .mm_x           (mm_x               )
    ,   .mm_x_valid     (mm_x_valid         )
    ,   .mm_y           (mm_y               )
    ,   .mm_y_valid     (mm_y_valid         )
    ,   .mm_result      (mm_result          )
    ,   .mm_valid       (mm_valid           )
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
    $stop;

end









































endmodule






