`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 12:45:13
// Design Name: 
// Module Name: me_iddmm_top
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

//function:result = x^^y mod m

module me_iddmm_top#(
        parameter K       = 128
    ,   parameter N       = 16
    ,   parameter ADDR_W  = $clog2(N)
)(
        input                   clk         
    ,   input                   rst_n       

    ,   input                   me_start

    ,   input       [K-1:0]     me_x
    ,   input                   me_x_valid

    ,   output      [K-1:0]     me_result   
    ,   output                  me_valid
);

wire    [K*N-1  : 0]    me_y                        ;
wire    [K-1    : 0]    me_m            [N-1:0]     ;
wire    [K-1    : 0]    me_m1                       ;
reg     [K-1    : 0]    rou             [N-1:0]     ;
reg     [K-1    : 0]    result          [N-1:0]     ;
reg     [K-1    : 0]    result_backup   [N-1:0]     ;


assign  me_y        =   2048'hD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9;
assign  me_m1       =   128'h328289a3442afa98c0d743199fd3cc59;//m1=(-1*(mod_inv(m,2**K)))%2**K
assign  me_m        =   '{
    128'hd27bf9f01e2a901db957879f45f69733,
    128'hd21a21095da4fa7d3aab75454a8e9f0,
    128'hf4ea531ece34f0c3ba9e02eb27d8f0db,
    128'he78eede4ac84061beef162d00b55c0dd,
    128'h772d28f23e994899aa19b9bea7b12a80,
    128'h27a32a92190a3630e249544675488121,
    128'h565a23548fcd36f5382eeb993db9ce3f,
    128'h526f20ab355e82d963d59541bc1161e2,
    128'h11a03e3b372560840c57e12bd2f40eac,
    128'h5ffcec01b3f07c378c0a60b74bef7b57,
    128'h2764c88a4f98b61fa8ccd905afae779e,
    128'h6193378304d8eb17695ce71a173ac3de,
    128'h11271753c48db58546e5af9917c1cebb,
    128'ha5bb1af3fce3df9516c0c95c9bc14bb6,
    128'h5d1c53078c06c81ac0f3ed0d8634260e,
    128'h47bf780cf4f4996084df732935194417
    };

initial begin
    rou = '{//high->low
    128'h250587be7ffcea8af2224d0c24a784ac,
    128'h66dceef15517d28730b926cd85bef8bc,
    128'hf574132b8d2e5fb4824f7404146d0071,
    128'hae5aa259b0f090e1c15a835e843ae277,
    128'hc1037cd639d9b522a7242dd9fd3c718c,
    128'h4ac9db510421922d1f9d742ec2ef1925,
    128'h91d437eef9dc0bb97e6e43fbf0823a70,
    128'h82f95eb83f667683ad516f6d270b376,
    128'ha0076f9933a5ea462bfecf79fe219bb1,
    128'h946c528a30ca276a1186eb398bd0f97f,
    128'h3ee3de936e02eaf2bc6c51e025336625,
    128'h16a803895f5b66ecf2051eec22c192b0,
    128'h63f54e7b725cecd6d04725c6ab23a6db,
    128'h703b44bfd2987c471401fe1d88734c12,
    128'h762b921e88de82cc44acb36f9d41fb28,
    128'hbad9430aa0c0b48e24a84569e941386d
    };//2^(2*K) mod m
end

initial begin
    result = '{//high->low
    128'h2d84060fe1d56fe246a87860ba0968cc,
    128'hf2de5def6a25b0582c5548abab57160f,
    128'hb15ace131cb0f3c4561fd14d8270f24,
    128'h1871121b537bf9e4110e9d2ff4aa3f22,
    128'h88d2d70dc166b76655e64641584ed57f,
    128'hd85cd56de6f5c9cf1db6abb98ab77ede,
    128'ha9a5dcab7032c90ac7d11466c24631c0,
    128'had90df54caa17d269c2a6abe43ee9e1d,
    128'hee5fc1c4c8da9f7bf3a81ed42d0bf153,
    128'ha00313fe4c0f83c873f59f48b41084a8,
    128'hd89b3775b06749e0573326fa50518861,
    128'h9e6cc87cfb2714e896a318e5e8c53c21,
    128'heed8e8ac3b724a7ab91a5066e83e3144,
    128'h5a44e50c031c206ae93f36a3643eb449,
    128'ha2e3acf873f937e53f0c12f279cbd9f1,
    128'hb84087f30b0b669f7b208cd6cae6bbe9
    };//1*2^(K) mod m
end

initial begin
    result_backup = '{//high->low
    128'h2d84060fe1d56fe246a87860ba0968cc,
    128'hf2de5def6a25b0582c5548abab57160f,
    128'hb15ace131cb0f3c4561fd14d8270f24,
    128'h1871121b537bf9e4110e9d2ff4aa3f22,
    128'h88d2d70dc166b76655e64641584ed57f,
    128'hd85cd56de6f5c9cf1db6abb98ab77ede,
    128'ha9a5dcab7032c90ac7d11466c24631c0,
    128'had90df54caa17d269c2a6abe43ee9e1d,
    128'hee5fc1c4c8da9f7bf3a81ed42d0bf153,
    128'ha00313fe4c0f83c873f59f48b41084a8,
    128'hd89b3775b06749e0573326fa50518861,
    128'h9e6cc87cfb2714e896a318e5e8c53c21,
    128'heed8e8ac3b724a7ab91a5066e83e3144,
    128'h5a44e50c031c206ae93f36a3643eb449,
    128'ha2e3acf873f937e53f0c12f279cbd9f1,
    128'hb84087f30b0b669f7b208cd6cae6bbe9
    };//1*2^(K) mod m
end

reg     [4              : 0]    current_state           ;  
localparam  IDLE        = 0,
            state_0_0   = 1,
            state_0_1   = 2,
            state_1_0   = 3,
            state_1_1   = 4,
            state_2_0   = 5,
            state_2_1   = 6,
            state_3     = 7,
            state_4     = 8;

reg     [$clog2(K*N)-1  : 0]    loop_counter            ; 
reg     [K-1            : 0]    result2       [N-1 : 0] ;
reg     [K*N-1          : 0]    yy                      ;
reg                             result_valid            ;
reg     [K-1            : 0]    result_out              ; 
reg     [ADDR_W         : 0]    wr_x_cnt                ;

wire    [2              : 0]    wr_ena                  ;
reg                             wr_ena_x                ;
reg                             wr_ena_y                ;
reg                             wr_ena_m                ;
reg     [ADDR_W-1       : 0]    wr_addr                 ;
reg     [K-1            : 0]    wr_x                    ;
reg     [K-1            : 0]    wr_y                    ;
reg     [K-1            : 0]    wr_m                    ;

reg                             task_req                ;

wire                            task_end                ;
wire                            task_grant              ;
wire    [K-1            : 0]    task_res                ;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//algorithm achievement:
//---------------------------------------------------------------------
//---------------------------------------------------------------------
// rou = fastExpMod(2,2*nbit,p)
// result = mont_r2mm(rou,1,p,nbit)

//step0
// result2 = mont_r2mm(xx,rou,p,nbit) 

//step1
// for(i) in range(nbit-1,-1,-1):
//     result = mont_r2mm(result,result,p,nbit)
//     if((yy>>i)&1==1):
//         result = mont_r2mm(result,result2,p,nbit)

//step2
// result = mont_r2mm(result,1,p,nbit)
//---------------------------------------------------------------------
//---------------------------------------------------------------------
reg  [ADDR_W-1       : 0]    wr_addr_d1              = 0;
always@(posedge clk)begin
  wr_addr_d1 <= wr_addr;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_state   <=  IDLE;
        task_req        <=  0;
        wr_addr         <=  0;
        wr_ena_x        <=  0;
        wr_ena_y        <=  0;
        wr_ena_m        <=  0;
        yy              <=  me_y;
        loop_counter    <=  0;
        result_valid    <=  0;
        result_out      <=  0;
        wr_x            <=  0;  
        wr_y            <=  0;
        wr_x_cnt        <=  0;
    end
    else begin
        case (current_state)
            IDLE:begin
                task_req          <=  0;
                yy                <=  me_y;
                loop_counter      <=  0;
                result_valid      <=  0;
                result_out        <=  0;
                wr_x              <=  0;
                wr_y              <=  0;
                wr_m              <=  0;
                wr_addr           <=  0;
                wr_x_cnt          <=  0;
                if(me_start)begin
                    current_state   <=  state_0_0;
                end
            end
            //write xx & rou
            state_0_0:begin
                if(me_x_valid)begin
                    wr_x_cnt            <=  wr_x_cnt + 1;
                    wr_addr             <=  wr_addr + 1;
                    wr_ena_x            <=  1;
                    wr_x                <=  me_x;
                    wr_ena_y            <=  1;
                    wr_y                <=  rou[wr_addr];
                    wr_ena_m            <=  1;
                    wr_m                <=  me_m[wr_addr];
                end 
                else begin
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if(wr_x_cnt == N)begin
                    wr_x_cnt            <=  0;
                    task_req            <=  1;
                    wr_addr             <=  0;
                    current_state       <=  state_0_1;
                end
            end
            //store result2
            state_0_1:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  state_1_0;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result2[wr_addr]  <=  task_res;
                end
            end
            //result = mont_r2mm(result,result,p,nbit)
            state_1_0:begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                    current_state     <=  state_2_0;
                end
                else begin
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  result[wr_addr];
                    wr_ena_y          <=  1;
                    wr_y              <=  result[wr_addr];
                end
            end
            //result = mont_r2mm(result,result2,p,nbit)
            state_1_1:begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                    current_state     <=  state_2_1;
                end
                else begin
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  result[wr_addr];
                    wr_ena_y          <=  1;
                    wr_y              <=  result2[wr_addr];
                end
            end
            //store result and decide whether to skip state_1_1
            state_2_0:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  yy[K*N-1] ? state_1_1 : ((loop_counter == (K*N-1)) ? state_3 : state_1_0);
                    yy                <=  yy << 1;
                    loop_counter      <=  loop_counter == (K*N-1) ? loop_counter : loop_counter + 1;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result[wr_addr]   <=  task_res;
                end
            end
            //store result and decide whether to skip state_1_1
            state_2_1:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  (loop_counter == (K*N-1)) ? state_3 : state_1_0;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result[wr_addr]   <=  task_res;
                end
            end
            //result = mont_r2mm(result,1,p,nbit)
            state_3:begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                    current_state     <=  state_4;
                end
                else begin
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  result[wr_addr];
                    wr_ena_y          <=  1;
                    wr_y              <=  wr_addr==0 ? 1 : 0;
                end
            end
            //get final result
            state_4:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  IDLE;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result[wr_addr]   <=  result_backup[wr_addr];
                    result_out        <=  task_res;
                    result_valid      <=  1;  
                end
                else begin
                    result_valid      <=  0;
                end
            end
            //default state
            default:begin
                current_state     <=  IDLE;
            end
        endcase
    end
end


mmp_iddmm_sp #(
        .MULT_METHOD    ("COMMON"       )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD    ("COMMON"       )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                            // 
    ,   .ADD2_METHOD    ("COMMON"       )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 
    ,   .MULT_LATENCY   (0              )
    ,   .ADD1_LATENCY   (0              )
    ,   .K              (K              )   // K bits in every group
    ,   .N              (N              )   // Number of groups
)u_mmp_iddmm_sp(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .wr_ena         (wr_ena         )
    ,   .wr_addr        (wr_addr_d1     )
    ,   .wr_x           (wr_x           )   //low words first
    ,   .wr_y           (wr_y           )   //low words first
    ,   .wr_m           (wr_m           )   //low words first
    ,   .wr_m1          (me_m1          )

    ,   .task_req       (task_req       )
    ,   .task_end       (task_end       )
    ,   .task_grant     (task_grant     )
    ,   .task_res       (task_res       )    
);



assign wr_ena       = {wr_ena_m,wr_ena_y,wr_ena_x};
assign me_result    = result_out;
assign me_valid     = result_valid;



endmodule
