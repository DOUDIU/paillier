`timescale 1ns / 1ps
module paillier_top_tb();

parameter K       = 256 ;
parameter N       = 16  ;

reg     clk = 0;
reg     rst_n = 0;

always #2 clk = ~clk;
initial #100 rst_n = 1;

wire    [N-1:0]     [K-1:0] PAILLIER_N                                      ;
wire    [N-1:0]     [K-1:0] PAILLIER_N_SQUARE                               ;
wire    [N-1:0]     [K-1:0] PAILLIER_M                                      ;
wire    [N-1:0]     [K-1:0] PAILLIER_C                                      ;
wire    [N-1:0]     [K-1:0] PAILLIER_R                                      ;

wire    [N-1:0]     [K-1:0] PAILLIER_ENC_A                                  ;
wire    [N-1:0]     [K-1:0] PAILLIER_ENC_B                                  ;

wire    [N-1:0]     [K-1:0] PAILLIER_MUL_M                                  ;
wire    [N-1:0]     [K-1:0] PAILLIER_CONST_SCALAR                           ;

reg     [K*N-1  :   0]      PAILLIER_ENC_RESULT                             ;
reg     [K*N-1  :   0]      PAILLIER_DEC_RESULT                             ;
wire    [K*N-1  :   0]      PAILLIER_ENC_RESULT_CONFIRM                     ;
wire    [K*N-1  :   0]      PAILLIER_DEC_RESULT_CONFIRM                     ;
wire    [K*N-1  :   0]      PAILLIER_HOMOMORPHIC_ADD_RESULT_CONFIRM         ;
wire    [K*N-1  :   0]      PAILLIER_POSTIVE_SCALAR_MUL_RESULT_CONFIRM      ;

reg     [1      :   0]      task_cmd                                        ;
reg                         task_req                                        ;

reg     [K-1    :   0]      enc_m_data                                      ;
reg                         enc_m_valid                                     ;
reg     [K-1    :   0]      enc_r_data                                      ;
reg                         enc_r_valid                                     ;

reg     [K-1    :   0]      dec_c_data                                      ;
reg                         dec_c_valid                                     ;

reg     [K-1    :   0]      homo_add_c1                                     ;
reg                         homo_add_c1_valid                               ;
reg     [K-1    :   0]      homo_add_c2                                     ;
reg                         homo_add_c2_valid                               ;

reg     [K-1    :   0]      scalar_mul_c1                                   ;
reg                         scalar_mul_c1_valid                             ;
reg     [K-1    :   0]      scalar_mul_const                                ;
reg                         scalar_mul_const_valid                          ;

wire    [K-1    :   0]      enc_out_data                                    ;
wire                        enc_out_valid                                   ;

assign  PAILLIER_N          =
    4096'hc1df05419c6057e26ebad2d3abd7123cdd612c4cf0c09d1881f83b3ea46ad2f1239e21d0a3a778cfbfa9f4f46a0f355c3c57d0305706482133aa5b0aa7d961798442d0c0a2d7fd48359690c361c66fa0dc7131e9dcf83e11cab3812b22861546a5be250c5ab7d671d5e6129b0ef708e105d2d0ed5bde948bf5c4339c0d7e45b9c3ac4ef3c50af15fbd37492f126c5a518af725228255ab1b6ecab2f668149e3ff74e3cd371e7fadf3edb24476ca0632fa53d0af0840ed39b736a5f08339a21e35a53aa612f73dabd6864bf2dc85b296b4e2a2bddcdabdae21b8c938d1c95d3278213cc126746497a511d8d29aea5ac13d2c5de79b62fb1a1a8e12114c110a8bf;

assign  PAILLIER_N_SQUARE   =
    4096'h92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81;

assign  PAILLIER_M          =       
    4096'h1000000019091;

assign  PAILLIER_C          =
    4096'h12591abff226f153673f624c737515f36a57de8a31e464d43b06e15194984bf169a47f41222b820953f18efa3a987ae384f753c56d261b9196be65192c46a4f6102489dc8499cdfbf89db24a2e876e6dde2728c8ac5b9b149ae0729bbc8281a1f63a061bba6103691948f787e1bdcf00faa0ecec17272304bb9804d593c0252624323a434780fcba9869d9ad35a4550c196a3118965a605067b680ee69e17ac1e01cdd3154bd89caa5b9b99dd77c2667aaeb94fbb66cf652d24ec81aa844e3eb3e41b67cbbde79230cefb1c6adb046c40dd9d0ca82fb54c69af9c0daed1fd4a2edd44bc61609c052052a37e3a7f10a9dbbb7643fc2dfa20bf9187e292f37683c3c4f40327e415bc5287b1059a412648e114e562684a08e4dbb7ea1bf3e240395aace38324ef4b03c499fe8280f31ca90342e4ba2c5c3b1db0dc83d9ee27c55670697d39f539d3a90ff139524d75b934a86137fb1447307f8745b0b62a4a135fdd09f856974d5f0d6d236a5cc641edb11920580c27772bc278a54c4af39e7ff556a61fc10665ca2a62ceb505f822a471d76dd28cd337360940e5cc45c1d3fc9b01491940045fb0f8ae2b8ca0745d00ee0dcffb928f785001cda75c2f3fa74378520aa8cb8363a0f19b959c899ac6d66b84a090462737ed625e84c9cfa618b2dc24254ece8543a77a7fc5953c739c66a1cb9d789167b983f98f3359c11124f39d6;

assign  PAILLIER_R          =       
    4096'h100000000000007b;

assign PAILLIER_ENC_A = 
    4096'h5f2579eda509b7350d6201ffeab34e044e6a8d8ae82225d0faaca8238f7dbf9dadfbe345140d72d60d88e94589f5a833f9e3d34b516aa42e4bcca67bece61390469e5a42a4e10b0cd8f63004d57c14169ec9e746ac368906b2cf6378cb4378b80eae11f08cba788f492b4cd5146d96ab250d6365a00e67278bf8e616f4ecbf086244dce5296fa856da4c4d821222cb31975e1624313accc7383c0a06be276fede028f787108c84a0445bf9aac820d6b675300e9ef86a4869741c8582575e0e7d76e890795010405a94e225d71a7e1f310bfb53db842fd59a25ae8e9497f2ef8fd35c0d91a1feb0acebc1f6fd5559ed45c3f54298cd570c8911a02c6634e6b4461eb7306d7110b29ccac2688c56d3e80081e0c112cfdec0d8768eaaaf5a8037fa4395f7023b6b3ce90327221ca8a859ef41e574ce81d2bc68432d296ab2cfa983ca91016866c7c4504ece506998522b44117ab4478f5bd5c8138fffeddf19b2795daf120522a78eb905d23d681b3ee2780cbc178e04d3bf37aa6e475e8bfbbe35ba0abcd40fe613c131e75af84d2036f78afbe59d8f16fdd61af19f6b8ba6d19f521c7695e189727f2d4180a05f6d5a910332a03ce2a9b5324ea6b7aa604658fec246f9b14e130ec3fd510c0d4d34485ffb37d364a013723f3ca5ea7cadc20af3e3e71357619ac396414d39ed37936dd8ca7389105cd30a79dc169cda7b8ffba5;

assign PAILLIER_ENC_B = 
    4096'h3bdafb341460b0c72dd8c1d811a1e4f456d1dcf2822c2ea671a4c327b758d6de2d728f225fb2ec78b1f18d50e75e782bb8b81e4710b2112e32f18ca0ebcff51464746369c2cf41936f85ac4347d9e09e79ceab645dc6e031f134559185b5abcc3bafb8786164644819d2e303aa28798549380f82dd8368f143f7b42c24bc790b0b1ed84dcdf34797a522c22747af63f7254a8e5c6330039352c77a8a0b2106589176d23ade3362c9fc459227e84cb8b4eedc5ab8814d4d4d62ee1583ea2405eb26e356101288202b85c33490c875284d978cbbd3c2c71e5b46078d1dfac38cd1bac0d43489f565e7e09405427012f309bdb1c345f8d4bbcccbe632c26d7ae7a19452c9d7e27a3d4f073f553e185a92634e2b961b1a6024783378595b8a14f86d1d59aa9fbd511a070f67e00a32535ce288b777cd3d7d228cf3ea22057c702f04a862f90ca151da90fd847c69db5053fa25b5c60aaa8f36ce17106ac30c2919cceaaa751230cb7b0390c2f6a21d9eec7f8038818a2a225426ef7374e6ab9501e0726403e8a36997ad7e032f071a90b9ef1e27971b99500dd98088fad5dc0ecfc69d44390096129db5b9b00346ae74033f0bbaa7635c53c6682e2f19e7783e9e34577261a5ea7f89d2ba71e6673e7a717827b5183bc054e53a142833f4c59a9b9185093c24f8868bf2005df965bc4d921bed881a066ea5d68589f6333cb72a8f4c;

assign PAILLIER_MUL_M = 
    4096'h62473723121fa1413366979bab6cc11848075252b92b3ba6392b18c5dac4bb3bbb03952a4b1ffb72e3b42d816e95cdbc795190d7136ef06893e9e0edcf68e60908a64a985ce4543f532db8680aef25a08fe25cff8f16ef461c39dd3f3770f3c0eb3f117148346e81bb675dfddeed6cdc44728af1f65a183497fa5778bace682a4615f6d8ceaf04d9deae0cc36471f5d8c2c58f918c13f6caefe5180bddbea1bb88a34d4228209dee02373aa70ee7b823038f754ebbf1c6ff21ffc2762947cfc3e30d11a86700f24acc498db5f6ae9d8722c14c1110e2abcbb3236432b273c96b1e61bc294c6e6ac50a8da36e8518371c5b3d2a3c3ae45ab1257391618070be8787424474c82d75ce19589589045491530d5a6ffedeef9f936385c23e95e78172a889a8cd876bba43b1cba429296abac9ffbd75ca32e5025f52c694a4b726333b93441ee022dc10406fc8d535fbffd6ae67006c33c6b2d146a30242a3556f3a097273a680017415c2144dd107d3d22501835d2c677cbf0d5761adcea720bf30f53a26d908d0adc18ac8f055810f8aebc94858b8b7bce242223817bb92cd14bf5435be247bc802c59f144a6f47178e0de255f3ec0de028cd430102c1d17d8b11198242a0017121481a7be0118b2e3c6148678d359b8d7696e06745f97c1c1eddcba38c87f0db56426fac65bd91fbf351580f91ba4485f3996feb21510c6471ad24;

assign PAILLIER_CONST_SCALAR = 
    4096'h11401bc48162751614fac47d1fac04c9195777f3a01f5da7aa3524c22db5f72c98bb07fa84b723bb05c0c31facd31202088adbcf8bc9126f8b823cb2c0badf10baf9f085a090db04cd4562520c0d9920c19cdec00e6971c9546545205d13acf70029be900c569d7c1b53be7459cea2d73b855f0e825fb421ef85d3709a651a8a;

assign PAILLIER_ENC_RESULT_CONFIRM = 
    4096'h39979947f84591c7011dc06e677dc75ce460fd29a14d022555732743a714c8cf18ff8ebe1a8b01aabd6d421cf63ee8f0870f09badc9224f9fed2af198c5da91847bb617d0e28a369453604f44580667d19c6cbf1365dc89c74126ac7c4ff6f974fdb853bf92e50975dd7c5e6e3bed5c2c20b11011a8f308c56d193bf1461326716180d26596840499b727663b9271e7ad17020b0202ffeb0f83d610245b396e63ea93b568be6ad20dcf85bd66411987b9c99a9756a6b21c03e7d16d9807cf9b1f63208f216144c08c5c571343d1d05032239a444b890d96abed9f0cbacfbbfab6f2f28f1460f6ed4e906b303d12bf4f1ec40d1a7d4a572dfa8b09a0fa5730ff88981780bb3f309afc99fab51bba5b1e5c768809c880bda44efa7cfbb03ac9d317cd6211d142fd3eb964d872d3a8f833a19a0c0b825bdf7972a22e3133a538a063430cfef88eb7aa8f028d88a7272678ccb0deff5bd7ae373a62ffa5789c874dac229ecda874772927346cf18c197bae55c93c16eeacbea4acc52a6abd20e95f0aa41adb389c6468400741f2a27fbee12e8de39d80f67fa81e252caa8d46903016e3202345b9abeab552d7f912d346ce1603e209010af32ef06b3286e86daeb8ced3dfc0a45097f952aade6a537c61f26a2e1c47658ce092e9b6c29a02604523b931dd247099e3123c04a84ebad9f2f569be1df94c3fe93f1c92358cd60233349;

assign PAILLIER_HOMOMORPHIC_ADD_RESULT_CONFIRM = 
    4096'h7078e3da67df6182c4d264753d39eb8f49a6eb1d741f8caeaa84c7fea860ee6680550f9f2bc65cfbae0bf0cddc64e1268d381842f9a233a28efdc41d6b80b7a81b2ca7b1c582b0ab8bfa31adb00e1071dfa59e2bca58918dc8b6d3322a353faf8904ed88ebaf6da08d1bf456b7af875406a2f935450ed5155f41728595bc04048a9bf069c21f37f8e4357ff51eeea2e6edb5f0200d7412ca1d5c7ba31c3111916edb6f65c687779478c9f91f05a47ed9aa0edaa72e5a4e4893816261d0479add0b1efe18a5516ce85f117f34882f55b578f05fc10ef11005a389e7ddcf713b03b9deb362dae90e11733149a7d5fbda0638a519b4f9fdacbd8979d1ffc0d7d16faa0a88e52a3d5026cee7c8b20ac01964dfb5f84e99d99acb238d09eec90a66d5143a2d5521c2246bf88bf70bb425c241fd8f8c1ec973623a2a32c2225bc5fa8d2865e71dea35c52a22186033d2e765494b3ca228a512d6c9216997f3c6cf094a46c9d7c4ff65b75e46841011c99fa9b9e8ad73b868d0b449e3f726e4955ba7c0957d19853cd9accce0c034e5f4ee846cb77d5ce14491eddcd8059e601a79b544eaca9cfd9067ed11558a8ffc120a64ca7556a5ef7c9a11d71da108001c54e00977d890bfda99bd3a6f463e9f42e663a750b5e693aa6cd070e4540742a87c13da873b09ccd4f2a738d00160b26dbe6ba06659f17514e183ba2058c6418fb71ef7;

assign PAILLIER_POSTIVE_SCALAR_MUL_RESULT_CONFIRM = 
    4096'h7f6fa78ae2840394ee397a24bab21a453df5f2f8ce92cd46d26507448514ce6351d8152e2cfba339df17841599189cd97965af0e86b623e212771c8d608417b80b0e3fb2c2c85e8cdfd75b2d3af15a86bd204d5662616f44f5bb6a6a19f120b0ebfb4e4958bc0d970fcb2c339987a162c2762cfed24e0d420c078c78dc554a6f421719fe093fccb661034b9b6499671860d85741853ec1577dcb0cf48ff57bc29edc6ac834ca63ba83f61694000ead423c2ad71ab54965d76f508b7ef180a480f793466c039e4edebce56dbf88320d065662dec9fd6c555801caa3be78b0189eb0aa6c38dacb8602aba3a885d475c54c5bf8c3b324e6ca2e6a309d84f3175225d750fd52e9e94a5d9b6189ab4f48fff567f69638adf3fc82ac89c4f3a851d1ed43277a6b0718f16c0cec1c7d90b37b32d26a037ba40de2c03b84b2f0c7dc146a7c20727d7b47aedbcd3872341753c378df7b5e58699fde4ae3262d2b10aa3bafdc1939e5d1e452daaac3d4d4c33c8adce811fe6a76a68c7e13e2ce831e17232642f421b3eb97be3a70fe4311dbf92ca65e7512c4564e4049410786f0c4d44402116bd9f93795b854b1faf16473ca2fcdde45a1a6aebefab4a83f153aabea595243f1b9d384795fa062df9dbc8b9b84e93a783c9aa4cd34352bca7aa1b6953d7fa5efd89ea2a9c3c912d1b23885fe34f449a1f8ca9ab08679fbe2acf7144db623;

assign PAILLIER_DEC_RESULT_CONFIRM =    
    4096'ha23f8540376d6cdc766d1ed79b923b3d0ceafc02c3d8b7d2bd24cc4a6b0e595d4e7feb630ab20352027ae7a7077b0cce9070fb17aa7b40eafd6fcf13bec5cb81ac3e4e45ca09f13847d13c1cc653912f99709e98b2334edf4bdd0776c2fcb0d96b059a6e963cce35abce84186866e50e555ddf482a13e999beb9af1c8a03fb9e956a16cab697ced16c5262a94473f5284901b5a57b12302f0e634e8c3d660178ee227e8cc4dcc720156655ceff69cb8e0acbdfd4838134ae69680f35a175a2c85e5228c4fc28eaf1e88c4c86acb0f53b044c3db982c583121632b3a48259ad37ee28e475ca99c13c516e4fa4523ac2ea6c570ffaf70def26b6b7b6a65be121b;

initial begin
    // paillier_encrypt_task;
    // paillier_decrypt_task;
    // paillier_homomorphic_addition_task;
    paillier_postive_scalar_multiplication_task;
end

paillier_top #(
        .K                          (K                          )
    ,   .N                          (N                          )
)paillier_top_inst(
        .clk                        (clk                        )
    ,   .rst_n                      (rst_n                      )

    ,   .task_cmd                   (task_cmd                   )
    ,   .task_req                   (task_req                   )

    ,   .enc_m_data                 (enc_m_data                 )
    ,   .enc_m_valid                (enc_m_valid                )
    ,   .enc_r_data                 (enc_r_data                 )
    ,   .enc_r_valid                (enc_r_valid                )

    ,   .dec_c_data                 (dec_c_data                 )
    ,   .dec_c_valid                (dec_c_valid                )

    ,   .homo_add_c1                (homo_add_c1                )
    ,   .homo_add_c1_valid          (homo_add_c1_valid          )
    ,   .homo_add_c2                (homo_add_c2                )
    ,   .homo_add_c2_valid          (homo_add_c2_valid          )

    ,   .scalar_mul_c1              (scalar_mul_c1              )
    ,   .scalar_mul_c1_valid        (scalar_mul_c1_valid        )
    ,   .scalar_mul_const           (scalar_mul_const           )
    ,   .scalar_mul_const_valid     (scalar_mul_const_valid     )

    ,   .enc_out_data               (enc_out_data               )
    ,   .enc_out_valid              (enc_out_valid              )
);

task paillier_encrypt_task;
    task_cmd    <=  2'b00;
    task_req    <=  0;
    enc_m_data  <=  0;
    enc_r_data  <=  0;
    enc_m_valid <=  0;
    enc_r_valid <=  0;

    @(posedge rst_n);
    #40
    @(posedge clk);
    task_req    <=  1;
    task_cmd    <=  2'b00;
    @(posedge clk);
    task_req    <=  0;
    task_cmd    <=  0;
    for(integer i = 0; i < N; i = i + 1) begin
        @(posedge clk);
        enc_m_data  <=  PAILLIER_M[i];
        enc_r_data  <=  PAILLIER_R[i];
        enc_m_valid <=  1;
        enc_r_valid <=  1;
    end
    @(posedge clk);
    enc_m_valid <=  0;
    enc_r_valid <=  0;
    wait(enc_out_valid);
    PAILLIER_ENC_RESULT      = {PAILLIER_ENC_RESULT[(K*N-K-1):0],enc_out_data};
    for (integer i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        PAILLIER_ENC_RESULT      = {enc_out_data,PAILLIER_ENC_RESULT[(K*N-1):K]};
    end
    $display("paillier encrypt result: \n0x%x",PAILLIER_ENC_RESULT);
    #100;
    assert(PAILLIER_ENC_RESULT ==  PAILLIER_ENC_RESULT_CONFIRM)
        $display("paillier encrypt result is correct!");
    else
        $display("paillier encrypt result is wrong!");
    $stop;
endtask

task paillier_decrypt_task;
    task_cmd    <=  2'b00;
    task_req    <=  0;
    dec_c_data  <=  0;
    dec_c_valid <=  0;

    @(posedge rst_n);
    #40
    @(posedge clk);
    task_req    <=  1;
    task_cmd    <=  2'b01;
    @(posedge clk);
    task_req    <=  0;
    task_cmd    <=  0;
    for(integer i = 0; i < N; i = i + 1) begin
        @(posedge clk);
        dec_c_data  <=  PAILLIER_C[i];
        dec_c_valid <=  1;
    end
    @(posedge clk);
    dec_c_data  <=  0;
    dec_c_valid <=  0;
    wait(enc_out_valid);
    PAILLIER_DEC_RESULT      = {PAILLIER_DEC_RESULT[(K*N-K-1):0],enc_out_data};
    for (integer i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        PAILLIER_DEC_RESULT      = {enc_out_data,PAILLIER_DEC_RESULT[(K*N-1):K]};
    end
    $display("paillier decrypt result: \n0x%x",PAILLIER_DEC_RESULT);
    #100;
    assert(PAILLIER_DEC_RESULT ==  PAILLIER_DEC_RESULT_CONFIRM)
        $display("paillier decrypt result is correct!");
    else
        $display("paillier decrypt result is wrong!");
    $stop;
endtask

task paillier_homomorphic_addition_task;
    task_cmd            <=  3'b000;
    task_req            <=  0;
    homo_add_c1         <=  0;
    homo_add_c1_valid   <=  0;
    homo_add_c2         <=  0;
    homo_add_c2_valid   <=  0;

    @(posedge rst_n);
    #40
    @(posedge clk);
    task_req    <=  1;
    task_cmd    <=  2'b10;
    @(posedge clk);
    task_req    <=  0;
    task_cmd    <=  0;
    for(integer i = 0; i < N; i = i + 1) begin
        @(posedge clk);
        homo_add_c1        <=  PAILLIER_ENC_A[i];
        homo_add_c2        <=  PAILLIER_ENC_B[i];
        homo_add_c1_valid  <=  1;
        homo_add_c2_valid  <=  1;
    end
    @(posedge clk);
    homo_add_c1_valid  <=  0;
    homo_add_c2_valid  <=  0;
    wait(enc_out_valid);
    PAILLIER_ENC_RESULT      = {PAILLIER_ENC_RESULT[(K*N-K-1):0],enc_out_data};
    for (integer i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        PAILLIER_ENC_RESULT      = {enc_out_data,PAILLIER_ENC_RESULT[(K*N-1):K]};
    end
    $display("paillier homomorphic addition result: \n0x%x",PAILLIER_ENC_RESULT);
    #100;
    assert(PAILLIER_ENC_RESULT ==  PAILLIER_HOMOMORPHIC_ADD_RESULT_CONFIRM)
        $display("paillier homomorphic addition result is correct!");
    else
        $display("paillier homomorphic addition result is wrong!");
    $stop;
endtask

task paillier_postive_scalar_multiplication_task;
    task_cmd                <=  3'b000;
    task_req                <=  0;
    scalar_mul_c1           <=  0;
    scalar_mul_c1_valid     <=  0;
    scalar_mul_const        <=  0;
    scalar_mul_const_valid  <=  0;

    @(posedge rst_n);
    #40
    @(posedge clk);
    task_req    <=  1;
    task_cmd    <=  2'b11;
    @(posedge clk);
    task_req    <=  0;
    task_cmd    <=  0;
    for(integer i = 0; i < N; i = i + 1) begin
        @(posedge clk);
            scalar_mul_c1           <=  PAILLIER_MUL_M[i];
            scalar_mul_const        <=  PAILLIER_CONST_SCALAR[i];
            scalar_mul_c1_valid     <=  1;
            scalar_mul_const_valid  <=  1;
    end
    @(posedge clk);
    scalar_mul_c1_valid     <=  0;
    scalar_mul_const_valid  <=  0;
    wait(enc_out_valid);
    PAILLIER_ENC_RESULT      = {PAILLIER_ENC_RESULT[(K*N-K-1):0],enc_out_data};
    for (integer i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        PAILLIER_ENC_RESULT      = {enc_out_data,PAILLIER_ENC_RESULT[(K*N-1):K]};
    end
    $display("paillier postive multiplication result: \n0x%x",PAILLIER_ENC_RESULT);
    #100;
    assert(PAILLIER_ENC_RESULT ==  PAILLIER_POSTIVE_SCALAR_MUL_RESULT_CONFIRM)
        $display("paillier postive multiplication result is correct!");
    else
        $display("paillier postive multiplication result is wrong!");
    $stop;
endtask

endmodule