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
    ,   parameter N             = 32
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
wire    [K-1    : 0]    me_m1                       ;
reg     [K-1    : 0]    rou             [N-1:0]     ;
reg     [K-1    : 0]    result          [N-1:0]     ;
reg     [K-1    : 0]    result2         [N-1:0]     ;
reg     [K-1    : 0]    result_backup   [N-1:0]     ;
reg     [K-1    : 0]    yy                          ;

assign  me_m1       =   128'hb885007f9c90c3f3beb79b92378fe7f;//m1=(-1*(mod_inv(m,2**K)))%2**K

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

reg     [4              : 0]    state_now;
reg     [4              : 0]    state_next;
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
reg                             result_valid            ;
reg     [K-1            : 0]    result_out              ; 
reg     [ADDR_W         : 0]    wr_x_cnt                ;

wire    [2              : 0]    wr_ena                  ;
reg                             wr_ena_x                ;
reg                             wr_ena_y                ;
reg                             wr_ena_m                ;
reg     [ADDR_W-1       : 0]    wr_addr                 ;
reg     [ADDR_W-1       : 0]    wr_addr_d1          = 0 ;
reg     [K-1            : 0]    wr_x                    ;
reg     [K-1            : 0]    wr_y                    ;
wire    [K-1            : 0]    wr_y_reg                ;
wire    [K-1            : 0]    wr_m                    ;

reg                             task_req                ;

wire                            task_end                ;
wire                            task_grant              ;
wire    [K-1            : 0]    task_res                ;

wire    [K-1            : 0]    ram_rou_rd_data         ;
wire    [K-1            : 0]    ram_m_rd_data           ;

wire                            ram_result2_wr_en       ;
wire                            ram_result2_wr_addr     ;
wire                            ram_result2_rd_en       ;

reg                             ram_result_wr_en        ;
reg                             ram_result_wr_addr      ;
reg                             ram_result_wr_data      ;
reg                             ram_result_rd_en        ;
reg                             ram_result_rd_addr      ;
wire                            ram_result_rd_data      ;

reg                             fifo_rd_en_yy           ;
wire    [K-1            :0]     fifo_rd_data            ;

assign ram_result2_wr_en = (state_now == state_0_1) & task_grant;
assign wr_y_reg = (state_now == state_0_0) ? ram_rou_rd_data : wr_y;

dual_port_ram#(
        .filename       ("../../../../../1.RTL/data/ram_me_m.txt")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_me_m(
        .clk            (clk                )
    ,   .wr_en          (0                  )
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1                  )
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (wr_m               )
);

dual_port_ram#(
        .filename       ("../../../../../1.RTL/data/ram_me_rou.txt")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_me_rou(
        .clk            (clk                )
    ,   .wr_en          (0                  )
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1                  )
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_rou_rd_data    )
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_result2(
        .clk            (clk                )
    ,   .wr_en          (ram_result2_wr_en  )
    ,   .wr_addr        (wr_addr            )
    ,   .wr_data        (task_res           )
    ,   .rd_en          ()
    ,   .rd_addr        ()
    ,   .rd_data        ()
);

dual_port_ram#(
        .filename       ("../../../../../1.RTL/data/ram_me_result.txt")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_result(
        .clk            (clk                )
    ,   .wr_en          (ram_result_wr_en   )
    ,   .wr_addr        (ram_result_wr_addr )
    ,   .wr_data        (ram_result_wr_data )
    ,   .rd_en          (ram_result_rd_en   )
    ,   .rd_addr        (ram_result_rd_addr )
    ,   .rd_data        (ram_result_rd_data )
);

fifo_ram#(
        .DATA_WIDTH     (K                  )
    ,   .DATA_DEPTH     ($clog2(N) + 1      )
)fifo_ram_y(
        .clk            (clk                )
    ,   .wr_en          (me_y_valid         )
    ,   .wr_data        (me_y               )
    ,   .wr_full        ()
    ,   .rd_en          (fifo_rd_en_yy      )
    ,   .rd_data        (fifo_rd_data       )
    ,   .rd_empty       ()
);

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

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        loop_counter    <=  0;
    end
    else if(task_end) begin
        loop_counter    <=  loop_counter + 1;
    end
end

// localparam  IDLE        = 0,
//             state_0_0   = 1,
//             state_0_1   = 2,
//             state_1_0   = 3,
//             state_1_1   = 4,
//             state_2_0   = 5,
//             state_2_1   = 6,
//             state_3     = 7,
//             state_4     = 8;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_now   <=  IDLE;
    end
    else begin
        state_now   <=  state_next;
    end
end

always@(*) begin
    if(!rst_n)begin
        state_next  =  IDLE;
    end
    else begin
        case (state_now)
            IDLE: begin
                if(me_start) begin
                    state_next  =   state_0_0;
                end
                else begin
                    state_next  =   IDLE;
                end
            end
            state_0_0: begin
                if(wr_x_cnt == N) begin
                    state_next  =   state_0_1;
                end
                else begin
                    state_next  =   state_0_0;
                end
            end
            state_0_1: begin
                if(task_end) begin
                    state_next  =   state_1_0;
                end
                else begin
                    state_next  =   state_0_1;
                end
            end
            state_1_0: begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y)) begin
                    state_next  =   state_2_0;
                end
                else begin
                    state_next  =   state_1_0;
                end
            end
            // state_1_1: begin
            //     state_next  <=  wr_addr_d1 == N-1 ? state_2_1 : state_1_1;
            // end
            // state_2_0: begin
            //     state_next  <=  loop_counter == K*N-1 ? state_3 : state_1_0;
            // end
            // state_2_1: begin
            //     state_next  <=  loop_counter == K*N ? state_3 : state_1_0;
            // end
            // state_3: begin
            //     state_next  <=  wr_addr_d1 == N-1 ? state_4 : state_3;
            // end
            // state_4: begin
            //     state_next  <=  task_end ? IDLE : state_4;
            // end
            default: begin
                state_next  =  IDLE;
            end
        endcase
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        task_req            <=  0;
        wr_addr             <=  0;

        wr_x                <=  0;
        wr_y                <=  0;
        wr_ena_x            <=  0;
        wr_ena_y            <=  0;
        wr_ena_m            <=  0;

        fifo_rd_en_yy       <=  0;
        yy                  <=  0;

        loop_counter        <=  0;
        result_valid        <=  0;
        result_out          <=  0;
        wr_x_cnt            <=  0;

        ram_result_wr_en    <=  0;
        ram_result_wr_addr  <=  0;
        ram_result_wr_data  <=  0;
        ram_result_rd_en    <=  0;
        ram_result_rd_addr  <=  0;
    end
    else begin
        case (state_now)
            IDLE:begin
                task_req          <=  0;
                loop_counter      <=  0;
                result_valid      <=  0;
                result_out        <=  0;

                wr_x              <=  0;
                wr_y              <=  0;
                wr_ena_x          <=  0;
                wr_ena_y          <=  0;
                wr_ena_m          <=  0;

                wr_addr           <=  0;
                wr_x_cnt          <=  0;
            end
            //write xx & rou
            state_0_0:begin
                if(me_x_valid)begin
                    wr_x_cnt            <=  wr_x_cnt + 1;
                    wr_addr             <=  wr_addr + 1;
                    wr_ena_x            <=  1;
                    wr_x                <=  me_x;
                    wr_ena_y            <=  1;
                    // wr_y                <=  ram_rou_rd_data;
                    wr_ena_m            <=  1;
                    // wr_m                <=  me_m[wr_addr];
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
                end
            end
            //store result2
            state_0_1:begin
                if(task_end)begin
                    task_req            <=  0;
                    yy                  <=  fifo_rd_data;
                    fifo_rd_en_yy       <=  1;
                end
                
                if(task_grant)begin
                    wr_addr             <=  wr_addr + 1;
                end
            end
            //result = mont_r2mm(result,result,p,nbit)
            state_1_0:begin
                fifo_rd_en_yy           <=  0;
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
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
                    // state_now     <=  state_2_1;
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
                    // state_now     <=  yy[K*N-1] ? state_1_1 : ((loop_counter == (K*N-1)) ? state_3 : state_1_0);
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
                    // state_now     <=  (loop_counter == (K*N)) ? state_3 : state_1_0;
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
                    // state_now     <=  state_4;
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
                    // state_now     <=  IDLE;
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
                // state_now     <=  IDLE;
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
    ,   .wr_y           (wr_y_reg       )   //low words first
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
