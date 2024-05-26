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

    ,   input       [K-1:0]     me_y
    ,   input                   me_y_valid

    ,   output      [K-1:0]     me_result   
    ,   output                  me_valid
);

reg     [K*N-1  : 0]    me_y_storage             = 0;
wire    [K-1    : 0]    me_m            [N-1:0]     ;
wire    [K-1    : 0]    me_m1                       ;
reg     [K-1    : 0]    rou             [N-1:0]     ;
reg     [K-1    : 0]    result          [N-1:0]     ;
reg     [K-1    : 0]    result_backup   [N-1:0]     ;

assign  me_m1       =   128'hecd18b11b6a41b9bb3ef4fcae3ba221f;//m1=(-1*(mod_inv(m,2**K)))%2**K
assign  me_m        =   '{
    128'hff5f4906fd176bc241535c78955d02f4,
    128'hd0acf376d736ae280077887200c758b7,
    128'h781b4432fa8baca2a81ad6fb0817051a,
    128'hfccf8e15c63048681bcf8342b56433,
    128'habd550affa489b289cd4f0482adce321,
    128'hc8cf4374ce15267692dfc8b0da108f4b,
    128'hb0e922d4a28402ef785c2516f6296486,
    128'hf8505ac3df05c0f953acce65e2dc5f1e,
    128'h59965ded73fa18ffb482ad1a2e5433d4,
    128'hdf8211de12a3e7a71a1a084fed671fb1,
    128'h1eeaf76f640c4fd549ea307b6622f798,
    128'hf027786e79232206de1507281d84c719,
    128'h209d408bc85f9ed2e1b82ecf72ff805a,
    128'h45221dc712c45a8dbc375e9b64227ec6,
    128'hb659a75fc5b5e051e776bcd9f4f6d82e,
    128'hbaff89a48c8494d6ed072372b846156a,
    128'hf229994baab390ec57c00130255acc2c,
    128'hdf975783df4678153f0ca51b854425b1,
    128'h568b5b8b53239f50dd39fc53c3d41827,
    128'ha0687c435f6de5e98843def3fb7b0f7e,
    128'h701cdfb51517d6628392bd9291c16282,
    128'h556f5581766dd6a0a426a35312237399,
    128'hf93ad69502592c0f6d1864ba0b75600e,
    128'he04cb406bcb833bc98527a0ac1249c6a,
    128'h918456b06f24611770c1708426b4d904,
    128'h1f7fe83be68fbc7018e461951d234ebf,
    128'h227b4301911e24055c745203c88827,
    128'h6f4db0c05f66514ae4e6b4bf4c8914e3,
    128'h6c4a94bf57bf807dd40c7572d1a99c27,
    128'hd9f58af0877bb217c081d750d5edbe3c,
    128'h45eafc3ea6786560fa819873452cc8bf,
    128'hfc7ab998ab70496b77fdadffb7ef2621
    };

initial begin
    rou = '{//high->low
    128'h6e4327fbc8a7821311c90ec965639c7b,
    128'hea4f74a0c2041f36eb96ee51c0859f63,
    128'hc0762523735caf92f2e11af0b2f2c93a,
    128'hee24545f3ec71c15c3d80ff1a2cda5d1,
    128'h9b52d367825941fd405e03f13bceabff,
    128'h140761ca0bea5c939c90ab64a6b2a6d5,
    128'h6adcf7ba480ac7fcebd02a1d1d9a6fa7,
    128'h43ddb8dae72002e0b0fd14e9a5b5bdb7,
    128'h4e04eab936ced1a293ad27abc1da8593,
    128'h2eee28b96a266d8a764e323cb45e233a,
    128'h64e75252ebc3737478c07df5f9acd311,
    128'h9fcc68d0486e1fef3312ad8356373b7a,
    128'h69892702ed2a5dcea05cc860abe2bfe5,
    128'hdb3a9eb3a9f91dea7633dc0839047a8c,
    128'h99eeb153da7a5d2599755200e26e38ea,
    128'hdf69af36207c372ddebac13f46a097e5,
    128'h56bac136df6d301fd8af9c13ad84143b,
    128'hf3c07250959e8ef7690d1a8dff8ec93b,
    128'h7989bc833b247852dfed4e8362e4c599,
    128'he398c2fb6f0253b35ce41d29f5c8c34d,
    128'hb4bac0413e3628fd84f8e70846c272f5,
    128'he0bf82908cdfde0bb80ab7224dcaeb40,
    128'h78bf8bd7b764fe48de949288f8fa83b4,
    128'hb27ca890729d773aa22643316f9a8dc,
    128'h5eb08d7325c1bcfb4d0de004a06bcd8a,
    128'h915ddba743aa39a589428a22800026fa,
    128'hb51fe8497ffa0a82423cd76059ddb92d,
    128'h4fc52ee4fc807f6ab8588c58b19756d2,
    128'h6077eb632c3e611ae71823657f0997a1,
    128'h25cfdcc944720bab6514298741cabdc8,
    128'hd13dd7f6a8d780c936ca0b11f9d350cc,
    128'hbf4d61512bd4c5f86a91a29f7215b
    };//2^(2*K) mod m
end

initial begin
    result = '{//high->low
    128'ha0b6f902e8943dbeaca3876aa2fd0b,
    128'h2f530c8928c951d7ff88778dff38a748,
    128'h87e4bbcd0574535d57e52904f7e8fae5,
    128'hff033071ea39cfb797e4307cbd4a9bcc,
    128'h542aaf5005b764d7632b0fb7d5231cde,
    128'h3730bc8b31ead9896d20374f25ef70b4,
    128'h4f16dd2b5d7bfd1087a3dae909d69b79,
    128'h7afa53c20fa3f06ac53319a1d23a0e1,
    128'ha669a2128c05e7004b7d52e5d1abcc2b,
    128'h207dee21ed5c1858e5e5f7b01298e04e,
    128'he11508909bf3b02ab615cf8499dd0867,
    128'hfd8879186dcddf921eaf8d7e27b38e6,
    128'hdf62bf7437a0612d1e47d1308d007fa5,
    128'hbadde238ed3ba57243c8a1649bdd8139,
    128'h49a658a03a4a1fae188943260b0927d1,
    128'h4500765b737b6b2912f8dc8d47b9ea95,
    128'hdd666b4554c6f13a83ffecfdaa533d3,
    128'h2068a87c20b987eac0f35ae47abbda4e,
    128'ha974a474acdc60af22c603ac3c2be7d8,
    128'h5f9783bca0921a1677bc210c0484f081,
    128'h8fe3204aeae8299d7c6d426d6e3e9d7d,
    128'haa90aa7e8992295f5bd95caceddc8c66,
    128'h6c5296afda6d3f092e79b45f48a9ff1,
    128'h1fb34bf94347cc4367ad85f53edb6395,
    128'h6e7ba94f90db9ee88f3e8f7bd94b26fb,
    128'he08017c41970438fe71b9e6ae2dcb140,
    128'hffdd84bcfe6ee1dbfaa38badfc3777d8,
    128'h90b24f3fa099aeb51b194b40b376eb1c,
    128'h93b56b40a8407f822bf38a8d2e5663d8,
    128'h260a750f78844de83f7e28af2a1241c3,
    128'hba1503c159879a9f057e678cbad33740,
    128'h3854667548fb694880252004810d9df
    };//2^(K) mod m
end

initial begin
    result_backup = '{//high->low
    128'ha0b6f902e8943dbeaca3876aa2fd0b,
    128'h2f530c8928c951d7ff88778dff38a748,
    128'h87e4bbcd0574535d57e52904f7e8fae5,
    128'hff033071ea39cfb797e4307cbd4a9bcc,
    128'h542aaf5005b764d7632b0fb7d5231cde,
    128'h3730bc8b31ead9896d20374f25ef70b4,
    128'h4f16dd2b5d7bfd1087a3dae909d69b79,
    128'h7afa53c20fa3f06ac53319a1d23a0e1,
    128'ha669a2128c05e7004b7d52e5d1abcc2b,
    128'h207dee21ed5c1858e5e5f7b01298e04e,
    128'he11508909bf3b02ab615cf8499dd0867,
    128'hfd8879186dcddf921eaf8d7e27b38e6,
    128'hdf62bf7437a0612d1e47d1308d007fa5,
    128'hbadde238ed3ba57243c8a1649bdd8139,
    128'h49a658a03a4a1fae188943260b0927d1,
    128'h4500765b737b6b2912f8dc8d47b9ea95,
    128'hdd666b4554c6f13a83ffecfdaa533d3,
    128'h2068a87c20b987eac0f35ae47abbda4e,
    128'ha974a474acdc60af22c603ac3c2be7d8,
    128'h5f9783bca0921a1677bc210c0484f081,
    128'h8fe3204aeae8299d7c6d426d6e3e9d7d,
    128'haa90aa7e8992295f5bd95caceddc8c66,
    128'h6c5296afda6d3f092e79b45f48a9ff1,
    128'h1fb34bf94347cc4367ad85f53edb6395,
    128'h6e7ba94f90db9ee88f3e8f7bd94b26fb,
    128'he08017c41970438fe71b9e6ae2dcb140,
    128'hffdd84bcfe6ee1dbfaa38badfc3777d8,
    128'h90b24f3fa099aeb51b194b40b376eb1c,
    128'h93b56b40a8407f822bf38a8d2e5663d8,
    128'h260a750f78844de83f7e28af2a1241c3,
    128'hba1503c159879a9f057e678cbad33740,
    128'h3854667548fb694880252004810d9df
    };//2^(K) mod m
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

reg     [$clog2(K*N)    : 0]    loop_counter            ; 
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

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        me_y_storage    <=  0;
    end
    // else if(me_start) begin
    //     me_y_storage    <=  0;
    // end
    else if(me_y_valid) begin
        me_y_storage    <=  {me_y,me_y_storage[K+:(K*N-K)]};
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_state   <=  IDLE;
        task_req        <=  0;
        wr_addr         <=  0;
        wr_ena_x        <=  0;
        wr_ena_y        <=  0;
        wr_ena_m        <=  0;
        yy              <=  0;
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
                    yy                <=  me_y_storage;
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
                    loop_counter      <=  loop_counter == (K*N) ? loop_counter : loop_counter + 1;
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
                    current_state     <=  (loop_counter == (K*N)) ? state_3 : state_1_0;
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
