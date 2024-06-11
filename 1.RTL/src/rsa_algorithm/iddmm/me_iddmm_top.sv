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
        parameter MULT_METHOD   = "TRADITION"   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                                // "TRADITION" :MULT_LATENCY=9                
                                                // "VEDIC8"    :VEDIC MULT, MULT_LATENCY=8 
    ,   parameter ADD1_METHOD   = "3-2_PIPE1"   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                                // "3-2_PIPE2" :classic pipeline adder,stage 2,ADD1_LATENCY=2
                                                // "3-2_PIPE1" :classic pipeline adder,stage 1,ADD1_LATENCY=1
                                                // 
    ,   parameter ADD2_METHOD   = "3-2_DELAY2"  // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                                // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                                // 
    ,   parameter K             = 128
    ,   parameter N             = 16
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
localparam ADDR_W   =   $clog2(N);

reg     [K*N-1  : 0]    me_y_storage             = 0;
wire    [K-1    : 0]    me_m            [N-1:0]     ;
wire    [K-1    : 0]    me_m1                       ;
reg     [K-1    : 0]    rou             [N-1:0]     ;
reg     [K-1    : 0]    result          [N-1:0]     ;
reg     [K-1    : 0]    result_backup   [N-1:0]     ;

assign  me_m1       =   128'hb885007f9c90c3f3beb79b92378fe7f;//m1=(-1*(mod_inv(m,2**K)))%2**K
assign  me_m        =   '{
    128'h92d20837163355491353a40bfbed6aff,
    128'hfb000939ca99e2dcb7e96c94d9e6ff1b,
    128'h54db47d62fa87283db4ef47e8119e2cb,
    128'hd126f44ef110cd64d6493014fbee11f,
    128'hce25ad01515ed88bef11f595cc5b107a,
    128'hed44c3aecf42318a0e9dc2431934703c,
    128'h219abc2ee926037fbd46e2b2465b19b3,
    128'h110e3ccdbdfbe0daadefe22a725ef38b,
    128'hc2371fdc5e9cfb439ea6ac84b3e424e7,
    128'h1cc3a263dc8cb4642042d01abe4e5441,
    128'h6d821fae3e588950e16d5bdc76fc0629,
    128'hb4829eabad9ad1535fc322dc0ad791ca,
    128'h8a353157ab771cc0eafb621a07b0ce09,
    128'h98a65541754ffeedb756ff3ca3b606de,
    128'ha2b63fa2483a5dda07c17496f556f441,
    128'he4c09fbb079cbbb8279c01fca24b56bf,
    128'h32e9902603d670439cee8a4f9730281c,
    128'ha7e736783300f69b64cce28fb565b995,
    128'h99758f8c8e5d58ce03af202cfe8d8809,
    128'h2884f15b5a76578db8bf6a32cf7e2d78,
    128'ha758c60de9e6cf037bd2a6c7d22c670b,
    128'h8b384722fef18a9870588c1368f3c1f8,
    128'h2caa709eff78cfdb2a3594bce3977875,
    128'hc0c30e464a5fc136225c7e206ba599b1,
    128'h4ec856a9a230bca081331c969774eb11,
    128'h2295c0670d4cb20723ceaa02e0ff4879,
    128'ha508052dad14c59f1787572686d68c51,
    128'heb3ce8f505e141803ec18bc77c4986a7,
    128'hea1dd24c13c7bb976496361ad38078e2,
    128'hdaaf39f049a489793e2b46643b3eb3f1,
    128'h68a3ad29eb4accb4ca422e7dd70e809f,
    128'h4ad5ed15d295f6765773bb5d851b3e81
    };

initial begin
    rou = '{//high->low
    128'h915f94ab9c50ca4ab4eeed592a9beaa5,
    128'had6f3ab8cde33356263b7ca1cd6327f9,
    128'h3abe0f5f621642eb55318e74137d0b25,
    128'h8ebc8b10a00cab3ffe67b8e78a16a98e,
    128'h4ddb4c9ac0c0a08302a84f682ca131a4,
    128'h77edce6c0888a7d3b0aa71c00185447b,
    128'h162a3b903f9853566121da8222821f44,
    128'h29e054b3919b6c6c038207f135accb78,
    128'hacd282aca5f291fca5ea2cc846ae54df,
    128'hfe7b604b0be2fe402bcb234c62e04017,
    128'h7915fd96957f012fc6c3c43fa5b2e411,
    128'h7252f907ab98a98c4d0dd09e90ef2e0,
    128'hf4a75b8a7d8b166e180cb21a76528f23,
    128'hf9a7752b5ac26ac1e8c15c514343b84b,
    128'h3b1450e77af95bdf8148328d73d65a6c,
    128'hd4479f00aaf1fe6a7641a67c0515e8f6,
    128'he169cc22bf64c781c30d0a498b07001a,
    128'h95d7776b9beb874091aeaabc1594693f,
    128'hd8ea828ac8251e7835669e4adb373a0f,
    128'h24428720ad662853fbb3f3f4d95cf52d,
    128'he704570cefbc67502abb2837ea155c3d,
    128'hf5e87eb6400b55d7ec696534b23ed377,
    128'h4ed73d9fc2788919bf9d984c670019bd,
    128'h4d0a8c0ba1be9c46ce46811a7f8fbaea,
    128'h6e74eb0c8d4989c5f7f7ba424a380576,
    128'h979df18527249a66e10251090d2bad6a,
    128'h25fa45d9a2ce695e98e2ae4f3b06c5f3,
    128'hc72909e099111c79ca5511174ff3fb35,
    128'hf3e16d1d8e50675156b0f608a0c7d82b,
    128'h62d7b109a4be8fceb700f50b47c35664,
    128'hce312818a6f6c0b2ff78a1ac2de5674a,
    128'h4fcaa08ceba5ea9d842695dd79db7aa0
    };//2^(2*K) mod m
end

initial begin
    result = '{//high->low
    128'h6d2df7c8e9ccaab6ecac5bf404129500,
    128'h4fff6c635661d234816936b261900e4,
    128'hab24b829d0578d7c24b10b817ee61d34,
    128'hf2ed90bb10eef329b29b6cfeb0411ee0,
    128'h31da52feaea1277410ee0a6a33a4ef85,
    128'h12bb3c5130bdce75f1623dbce6cb8fc3,
    128'hde6543d116d9fc8042b91d4db9a4e64c,
    128'heef1c33242041f2552101dd58da10c74,
    128'h3dc8e023a16304bc6159537b4c1bdb18,
    128'he33c5d9c23734b9bdfbd2fe541b1abbe,
    128'h927de051c1a776af1e92a4238903f9d6,
    128'h4b7d615452652eaca03cdd23f5286e35,
    128'h75cacea85488e33f15049de5f84f31f6,
    128'h6759aabe8ab0011248a900c35c49f921,
    128'h5d49c05db7c5a225f83e8b690aa90bbe,
    128'h1b3f6044f8634447d863fe035db4a940,
    128'hcd166fd9fc298fbc631175b068cfd7e3,
    128'h5818c987ccff09649b331d704a9a466a,
    128'h668a707371a2a731fc50dfd3017277f6,
    128'hd77b0ea4a589a872474095cd3081d287,
    128'h58a739f2161930fc842d59382dd398f4,
    128'h74c7b8dd010e75678fa773ec970c3e07,
    128'hd3558f6100873024d5ca6b431c68878a,
    128'h3f3cf1b9b5a03ec9dda381df945a664e,
    128'hb137a9565dcf435f7ecce369688b14ee,
    128'hdd6a3f98f2b34df8dc3155fd1f00b786,
    128'h5af7fad252eb3a60e878a8d9792973ae,
    128'h14c3170afa1ebe7fc13e743883b67958,
    128'h15e22db3ec3844689b69c9e52c7f871d,
    128'h2550c60fb65b7686c1d4b99bc4c14c0e,
    128'h975c52d614b5334b35bdd18228f17f60,
    128'hb52a12ea2d6a0989a88c44a27ae4c17f
    };//2^(K) mod m
end

initial begin
    result_backup = '{//high->low
    128'h6d2df7c8e9ccaab6ecac5bf404129500,
    128'h4fff6c635661d234816936b261900e4,
    128'hab24b829d0578d7c24b10b817ee61d34,
    128'hf2ed90bb10eef329b29b6cfeb0411ee0,
    128'h31da52feaea1277410ee0a6a33a4ef85,
    128'h12bb3c5130bdce75f1623dbce6cb8fc3,
    128'hde6543d116d9fc8042b91d4db9a4e64c,
    128'heef1c33242041f2552101dd58da10c74,
    128'h3dc8e023a16304bc6159537b4c1bdb18,
    128'he33c5d9c23734b9bdfbd2fe541b1abbe,
    128'h927de051c1a776af1e92a4238903f9d6,
    128'h4b7d615452652eaca03cdd23f5286e35,
    128'h75cacea85488e33f15049de5f84f31f6,
    128'h6759aabe8ab0011248a900c35c49f921,
    128'h5d49c05db7c5a225f83e8b690aa90bbe,
    128'h1b3f6044f8634447d863fe035db4a940,
    128'hcd166fd9fc298fbc631175b068cfd7e3,
    128'h5818c987ccff09649b331d704a9a466a,
    128'h668a707371a2a731fc50dfd3017277f6,
    128'hd77b0ea4a589a872474095cd3081d287,
    128'h58a739f2161930fc842d59382dd398f4,
    128'h74c7b8dd010e75678fa773ec970c3e07,
    128'hd3558f6100873024d5ca6b431c68878a,
    128'h3f3cf1b9b5a03ec9dda381df945a664e,
    128'hb137a9565dcf435f7ecce369688b14ee,
    128'hdd6a3f98f2b34df8dc3155fd1f00b786,
    128'h5af7fad252eb3a60e878a8d9792973ae,
    128'h14c3170afa1ebe7fc13e743883b67958,
    128'h15e22db3ec3844689b69c9e52c7f871d,
    128'h2550c60fb65b7686c1d4b99bc4c14c0e,
    128'h975c52d614b5334b35bdd18228f17f60,
    128'hb52a12ea2d6a0989a88c44a27ae4c17f
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
        .MULT_METHOD    (MULT_METHOD    )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD    (ADD1_METHOD    )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                            // 
    ,   .ADD2_METHOD    (ADD2_METHOD    )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 
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
