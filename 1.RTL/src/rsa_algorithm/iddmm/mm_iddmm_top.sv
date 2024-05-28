module mm_iddmm_top#(
        parameter K       = 128
    ,   parameter N       = 16
    ,   parameter ADDR_W  = $clog2(N)
)(
        input                   clk         
    ,   input                   rst_n       

    ,   input                   mm_start

    ,   input       [K-1:0]     mm_x
    ,   input                   mm_x_valid

    ,   input       [K-1:0]     mm_y
    ,   input                   mm_y_valid

    ,   output      [K-1:0]     mm_result   
    ,   output                  mm_valid
);

reg     [K*N-1  : 0]    mm_y_storage             = 0;
wire    [K-1    : 0]    mm_m            [N-1:0]     ;
wire    [K-1    : 0]    mm_m1                       ;
reg     [K-1    : 0]    rou             [N-1:0]     ;
reg     [K-1    : 0]    result_x_rou    [N-1:0]     ;
reg     [K-1    : 0]    result_y_rou    [N-1:0]     ;
reg     [K-1    : 0]    result_r1_r2    [N-1:0]     ;

assign  mm_m1       =   128'hb885007f9c90c3f3beb79b92378fe7f;//m1=(-1*(mod_inv(m,2**K)))%2**K
assign  mm_m        =   '{
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



wire    [2              : 0]    wr_ena                  ;
reg                             wr_ena_x                ;
reg                             wr_ena_y                ;
reg                             wr_ena_m                ;
reg     [ADDR_W-1       : 0]    wr_addr                 ;
reg     [ADDR_W-1       : 0]    wr_cnt                  ;
reg     [K-1            : 0]    wr_x                    ;
reg     [K-1            : 0]    wr_y                    ;
reg     [K-1            : 0]    wr_m                    ;

reg                             task_req                ;

wire                            task_end                ;
wire                            task_grant              ;
wire    [K-1            : 0]    task_res                ;

reg                             result_valid            ;
reg     [K-1            : 0]    result_out              ;

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
        mm_y_storage    <=  0;
    end
    else if(mm_y_valid) begin
        mm_y_storage    <=  {mm_y,mm_y_storage[K+:(K*N-K)]};
    end
end

localparam  STA_IDLE                = 0,
            STA_MM_X_ROU            = 1,
            STA_MM_Y_ROU            = 2,
            STA_MM_R1_R2            = 3,
            STA_MM_R3_1             = 4,
            STA_END                 = 5;

reg     [3:0]   state_now;
reg     [3:0]   state_next;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_now    <=      STA_IDLE; 
    end
    else begin
        state_now   <=      state_next;
    end
end

always@(*) begin
    state_next      =       STA_IDLE;
    case(state_now) 
        STA_IDLE: begin
            if(mm_start) begin
                state_next      =   STA_MM_X_ROU;
            end
            else begin
                state_next      =   STA_IDLE;
            end
        end
        STA_MM_X_ROU: begin
            if(task_end) begin
                state_next      =   STA_MM_Y_ROU;
            end
            else begin
                state_next      =   STA_MM_X_ROU;
            end
        end
        STA_MM_Y_ROU: begin
            if(task_end) begin
                state_next      =   STA_MM_R1_R2;
            end
            else begin
                state_next      =   STA_MM_Y_ROU;
            end
        end
        STA_MM_R1_R2: begin
            if(task_end) begin
                state_next      =   STA_MM_R3_1;
            end
            else begin
                state_next      =   STA_MM_R1_R2;
            end
        end
        STA_MM_R3_1: begin
            if(task_end) begin
                state_next      =   STA_IDLE;
            end
            else begin
                state_next      =   STA_MM_R3_1;
            end
        end
        default: begin
            state_next      =   STA_IDLE;
        end
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        task_req        <=  0;
        wr_addr         <=  0;
        wr_cnt          <=  0;
        wr_ena_x        <=  0;
        wr_ena_y        <=  0;
        wr_ena_m        <=  0;
        wr_x            <=  0;  
        wr_y            <=  0;
        wr_m            <=  0;
        result_out      <=  0;
        result_valid    <=  0;
    end
    else begin
        case (state_now)
            STA_IDLE:begin
                task_req        <=  0;
                wr_addr         <=  0;
                wr_cnt          <=  0;
                wr_x            <=  0;
                wr_y            <=  0;
                wr_m            <=  0;
                wr_ena_x        <=  0;
                wr_ena_y        <=  0;
                wr_ena_m        <=  0;
                result_out      <=  0;
                result_valid    <=  0;
            end
            STA_MM_X_ROU:begin
                if(mm_x_valid)begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                    wr_x                <=  mm_x;
                    wr_y                <=  rou[wr_addr];
                    wr_m                <=  mm_m[wr_addr];
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if(wr_addr_d1 == N - 1)begin
                    task_req            <=  1;
                    wr_addr             <=  0;
                end
                if(task_end) begin
                    task_req            <=  0;
                end
                if(task_grant) begin
                    wr_cnt                  <=  wr_cnt  +  1;
                    result_x_rou[wr_cnt]    <=  task_res;
                end
            end
            STA_MM_Y_ROU:begin
                if(!task_req) begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                end
                else begin
                    wr_addr             <=  0;
                end
                wr_x                <=  mm_y_storage[wr_addr*K+:K];
                wr_y                <=  rou[wr_addr];
                wr_m                <=  mm_m[wr_addr];
                if(wr_addr_d1 < N - 1)begin
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    task_req            <=  1;
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if(task_end) begin
                    task_req            <=  0;
                    wr_addr             <=  0;
                end
                if(task_grant) begin
                    wr_cnt                  <=  wr_cnt  +  1;
                    result_y_rou[wr_cnt]    <=  task_res;
                end
            end
            STA_MM_R1_R2:begin
                if(!task_req) begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                end
                else begin
                    wr_addr             <=  0;
                end
                if(wr_addr_d1 < N - 1)begin
                    wr_x                <=  result_x_rou[wr_addr];
                    wr_y                <=  result_y_rou[wr_addr];
                    wr_m                <=  mm_m[wr_addr];
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    task_req            <=  1;
                    // wr_addr             <=  0;
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if(task_end) begin
                    task_req            <=  0;
                    wr_addr             <=  0;
                end
                if(task_grant) begin
                    wr_cnt                  <=  wr_cnt  +  1;
                    result_r1_r2[wr_cnt]    <=  task_res;
                end
            end
            STA_MM_R3_1:begin
                if(!task_req) begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                end
                else begin
                    wr_addr             <=  0;
                end
                if(wr_addr_d1 < N - 1)begin
                    wr_x                <=  result_r1_r2[wr_addr];
                    wr_y                <=  wr_addr_d1 == 0 ? 128'h1 : 128'h0;
                    wr_m                <=  mm_m[wr_addr];
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    task_req            <=  1;
                    // wr_addr             <=  0;
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if(task_end) begin
                    task_req            <=  0;
                    wr_addr             <=  0;
                end
                result_out          <=  task_res;
                result_valid        <=  task_end;
            end
            default:begin
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
    ,   .wr_m1          (mm_m1          )

    ,   .task_req       (task_req       )
    ,   .task_end       (task_end       )
    ,   .task_grant     (task_grant     )
    ,   .task_res       (task_res       )    
);



assign wr_ena       = {wr_ena_m,wr_ena_y,wr_ena_x};
assign mm_result    = result_out;
assign mm_valid     = result_valid;



endmodule
