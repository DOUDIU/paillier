module mm_iddmm_top#(
        parameter K                     = 128
    ,   parameter N                     = 32
    ,   parameter OUTSIDE_MONTGOMERY    = 0
)(
        input                       clk         
    ,   input                       rst_n       

    ,   input   [1  :0]             mm_type
    ,   input                       mm_start
    ,   input   [K-1:0]             mm_x
    ,   input                       mm_x_valid
    ,   input   [K-1:0]             mm_y
    ,   input                       mm_y_valid
    ,   output  [K-1:0]             mm_result   
    ,   output                      mm_valid

    ,   output  [2  :0]             iddmm_wr_ena
    ,   output  [$clog2(N)-1:0]     iddmm_wr_addr
    ,   output  [K-1:0]             iddmm_wr_x
    ,   output  [K-1:0]             iddmm_wr_y
    ,   output  [K-1:0]             iddmm_wr_m
    ,   output  [K-1:0]             iddmm_wr_m1

    ,   output                      iddmm_task_req
    ,   input                       iddmm_task_end
    ,   input                       iddmm_task_grant
    ,   input   [K-1:0]             iddmm_task_res
);
localparam ADDR_W   =   $clog2(N);

typedef enum logic [1:0] {
    MM_N2           ,
    MM_N            ,
    MM_INV          
} MM_TYPE;

typedef enum logic [2:0] {
    STA_IDLE        ,
    STA_MM_X_ROU    ,
    STA_MM_Y_ROU    ,
    STA_MM_R1_R2    ,
    STA_MM_R3_1     ,
    STA_END         
} FSM_STATE;

FSM_STATE  state_now;
FSM_STATE  state_next;

wire    [K-1    : 0]    mm_m1_n2                    ;
wire    [K-1    : 0]    mm_m1_n                     ;
wire    [K-1    : 0]    mm_m1_inv                   ;

//m1=(-1*(mod_inv(m,2**K)))%2**K
assign  mm_m1_n2    =   128'hb885007f9c90c3f3beb79b92378fe7f;
assign  mm_m1_n     =   128'hf14bf14f3b9eb93fcfc300c2853938c1;
assign  mm_m1_inv   =   128'h9070cb8b8be9930f83c3fe53c21784b1;

wire    [2              : 0]    wr_ena                  ;
reg                             wr_ena_x                ;
reg                             wr_ena_y                ;
reg                             wr_ena_m                ;
reg     [ADDR_W-1       : 0]    wr_addr                 ;
reg     [ADDR_W-1       : 0]    wr_addr_d1          = 0 ;
reg     [ADDR_W-1       : 0]    wr_cnt                  ;
reg     [K-1            : 0]    wr_x                    ;
reg     [K-1            : 0]    wr_y                    ;
reg     [K-1            : 0]    wr_m                    ;

reg     [K-1            : 0]    wr_x_reg                ;
reg     [K-1            : 0]    wr_y_reg                ;
reg     [K-1            : 0]    wr_m_reg                ;
reg     [K-1            : 0]    mm_m1_reg               ;

reg                             task_req                ;

wire                            task_end                ;
wire                            task_grant              ;
wire    [K-1            : 0]    task_res                ;

reg                             result_valid            ;
reg     [K-1            : 0]    result_out              ;


wire    [K-1            : 0]    ram_rou_n2_rd_data      ;
wire    [K-1            : 0]    ram_rou_n_rd_data       ;
wire    [K-1            : 0]    ram_rou_inv_rd_data     ;

wire    [K-1            : 0]    ram_m_n2_rd_data        ;
wire    [K-1            : 0]    ram_m_n_rd_data         ;
wire    [K-1            : 0]    ram_m_inv_rd_data       ; 

wire                            ram_result0_wr_en       ;
wire    [K-1            : 0]    ram_result0_rd_data     ;

wire                            ram_result1_wr_en       ;
wire    [K-1            : 0]    ram_result1_rd_data     ;

reg                             ram_y_wr_en             ;
reg     [ADDR_W-1       : 0]    ram_y_wr_addr           ;
reg     [K-1            : 0]    ram_y_wr_data           ;
wire    [K-1            : 0]    ram_y_rd_data           ;

assign ram_result0_wr_en = ((state_now == STA_MM_X_ROU) | (state_now == STA_MM_R1_R2)) & task_grant;
assign ram_result1_wr_en = (state_now == STA_MM_Y_ROU) & task_grant;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//algorithm achievement:
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//pre calculate
    // rou = fastExpMod(2,2*k,m)

//step0
    // result0 = mont_r2mm(x,rou,m,k)
//step1
    // result1 = mont_r2mm(y,rou,m,k)
//step2
    // result2 = mont_r2mm(result0,result1,m,k)
//step3
    // result3 = mont_r2mm(result2,1,m,k)
//---------------------------------------------------------------------
//---------------------------------------------------------------------

always@(*) begin
    case(state_now) 
        STA_MM_X_ROU: begin
            wr_x_reg    =   wr_x;
        end
        STA_MM_Y_ROU: begin
            wr_x_reg    =   ram_y_rd_data;
        end
        STA_MM_R1_R2: begin
            wr_x_reg    =   ram_result0_rd_data;
        end
        STA_MM_R3_1: begin
            wr_x_reg    =   ram_result0_rd_data;
        end
        default: begin
            wr_x_reg    =   wr_x;
        end
    endcase
end

always@(*) begin
    case(state_now) 
        STA_MM_X_ROU: begin
            case(mm_type)
                MM_N2: begin
                    wr_y_reg    =   ram_rou_n2_rd_data;
                end
                MM_N: begin
                    wr_y_reg    =   ram_rou_n_rd_data;
                end
                MM_INV: begin
                    wr_y_reg    =   ram_rou_inv_rd_data;
                end
                default: begin
                    wr_y_reg    =   ram_rou_n2_rd_data;
                end
            endcase
        end
        STA_MM_Y_ROU: begin
            case(mm_type)
                MM_N2: begin
                    wr_y_reg    =   ram_rou_n2_rd_data;
                end
                MM_N: begin
                    wr_y_reg    =   ram_rou_n_rd_data;
                end
                MM_INV: begin
                    wr_y_reg    =   ram_rou_inv_rd_data;
                end
                default: begin
                    wr_y_reg    =   ram_rou_n2_rd_data;
                end
            endcase
        end
        STA_MM_R1_R2: begin
            wr_y_reg    =   ram_result1_rd_data;
        end
        STA_MM_R3_1: begin
            wr_y_reg    =   (wr_addr_d1 == 0) ? 1 : 0;
        end
        default: begin
            wr_y_reg    =   wr_y;
        end
    endcase
end

always@(*) begin
    case(mm_type)
        MM_N2: begin
            wr_m_reg    =   ram_m_n2_rd_data;
        end
        MM_N: begin
            wr_m_reg    =   ram_m_n_rd_data;
        end
        MM_INV: begin
            wr_m_reg    =   ram_m_inv_rd_data;
        end
        default: begin
            wr_m_reg    =   ram_m_n2_rd_data;
        end
    endcase
end

always@(*) begin
    case(mm_type)
        MM_N2: begin
            mm_m1_reg   =   mm_m1_n2;
        end
        MM_N: begin
            mm_m1_reg   =   mm_m1_n;
        end
        MM_INV: begin
            mm_m1_reg   =   mm_m1_inv;
        end
        default: begin
            mm_m1_reg   =   mm_m1_n2;
        end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n | mm_start)begin
        ram_y_wr_en         <=  0;
        ram_y_wr_addr       <=  0-1;
        ram_y_wr_data       <=  0;
    end
    else if(mm_y_valid) begin
        ram_y_wr_en         <=  1;
        ram_y_wr_addr       <=  ram_y_wr_addr + 1;
        ram_y_wr_data       <=  mm_y;
    end
end

always@(posedge clk)begin
  wr_addr_d1 <= wr_addr;
end

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
                end
            end
            STA_MM_Y_ROU:begin
                if(!task_req) begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                end
                else begin
                    wr_addr             <=  0;
                end
                if((wr_addr_d1 < N - 1)&!task_req)begin
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if((wr_addr_d1 == N - 1))begin
                    task_req            <=  1;
                end
                else if(task_end) begin
                    task_req            <=  0;
                end
                if(task_grant) begin
                    wr_cnt                  <=  wr_cnt  +  1;
                end
            end
            STA_MM_R1_R2:begin
                if(!task_req) begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                end
                else begin
                    wr_addr             <=  0;
                end
                if((wr_addr_d1 < N - 1)&!task_req)begin
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if((wr_addr_d1 == N - 1))begin
                    task_req            <=  1;
                end
                else if(task_end) begin
                    task_req            <=  0;
                end
                if(task_grant) begin
                    wr_cnt                  <=  wr_cnt  +  1;
                end
            end
            STA_MM_R3_1:begin
                if(!task_req) begin
                    wr_addr             <=  wr_addr < N - 1 ? wr_addr + 1 : wr_addr;
                end
                else begin
                    wr_addr             <=  0;
                end
                if((wr_addr_d1 < N - 1)&!task_req)begin
                    wr_ena_x            <=  1;
                    wr_ena_y            <=  1;
                    wr_ena_m            <=  1;
                end 
                else begin
                    wr_ena_x            <=  0;
                    wr_ena_y            <=  0;
                    wr_ena_m            <=  0;
                end
                if((wr_addr_d1 == N - 1))begin
                    task_req            <=  1;
                end
                else if(task_end) begin
                    task_req            <=  0;
                end
                result_out          <=  task_res;
                result_valid        <=  task_grant;
            end
            default:begin
            end
        endcase
    end
end

assign wr_ena       = {wr_ena_m,wr_ena_y,wr_ena_x};
assign mm_result    = result_out;
assign mm_valid     = result_valid;

generate 
    if(OUTSIDE_MONTGOMERY == 1) begin
        assign  iddmm_wr_ena        =   wr_ena;
        assign  iddmm_wr_addr       =   wr_addr_d1;
        assign  iddmm_wr_x          =   wr_x_reg;
        assign  iddmm_wr_y          =   wr_y_reg;
        assign  iddmm_wr_m          =   wr_m_reg;
        assign  iddmm_wr_m1         =   mm_m1_reg;

        assign  iddmm_task_req      =   task_req;
        
        assign  task_res            =   iddmm_task_res;
        assign  task_end            =   iddmm_task_end;
        assign  task_grant          =   iddmm_task_grant;
    end
    else begin
        iddmm_top #(
                .K                  (K              )   // K bits in every group
            ,   .N                  (N              )   // Number of groups
        )u_iddmm_top(    
                .clk                (clk            )
            ,   .rst_n              (rst_n          )

            ,   .wr_ena             (wr_ena         )
            ,   .wr_addr            (wr_addr_d1     )
            ,   .wr_x               (wr_x_reg       )   //low words first
            ,   .wr_y               (wr_y_reg       )   //low words first
            ,   .wr_m               (wr_m_reg       )   //low words first
            ,   .wr_m1              (mm_m1_reg      )

            ,   .task_req           (task_req       )
            ,   .task_end           (task_end       )
            ,   .task_grant         (task_grant     )
            ,   .task_res           (task_res       )    
        );
    end
endgenerate

dual_port_ram#(
    `ifdef Vivado_Sim
        .filename       ("../../../../../1.RTL/data/ram_mm_m_n2.txt")
    `elsif Vivado_Syn
        .filename       ("../../../1.RTL/data/ram_mm_m_n2.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mm_m_n2.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_m_n2(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_m_n2_rd_data   )
);

dual_port_ram#(
    `ifdef Vivado_Sim
        .filename       ("../../../../../1.RTL/data/ram_mm_m_n.txt")
    `elsif Vivado_Syn
        .filename       ("../../../1.RTL/data/ram_mm_m_n.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mm_m_n.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_m_n(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_m_n_rd_data    )
);

dual_port_ram#(
    `ifdef Vivado_Sim
        .filename       ("../../../../../1.RTL/data/ram_mm_m_inv.txt")
    `elsif Vivado_Syn
        .filename       ("../../../1.RTL/data/ram_mm_m_inv.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mm_m_inv.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_m_inv(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_m_inv_rd_data  )
);

dual_port_ram#(
    `ifdef Vivado_Sim
        .filename       ("../../../../../1.RTL/data/ram_mm_rou_n2.txt")
    `elsif Vivado_Syn
        .filename       ("../../../1.RTL/data/ram_mm_rou_n2.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mm_rou_n2.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_rou_n2(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_rou_n2_rd_data )
);

dual_port_ram#(
    `ifdef Vivado_Sim
        .filename       ("../../../../../1.RTL/data/ram_mm_rou_n.txt")
    `elsif Vivado_Syn
        .filename       ("../../../1.RTL/data/ram_mm_rou_n.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mm_rou_n.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_rou_n(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_rou_n_rd_data  )
);

dual_port_ram#(
    `ifdef Vivado_Sim
        .filename       ("../../../../../1.RTL/data/ram_mm_rou_inv.txt")
    `elsif Vivado_Syn
        .filename       ("../../../1.RTL/data/ram_mm_rou_inv.txt")
    `else
        .filename       ("..\\1.RTL\\data\\ram_mm_rou_inv.txt")
    `endif
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_mm_rou_inv(
        .clk            (clk                )
    ,   .wr_en          (0)
    ,   .wr_addr        ()
    ,   .wr_data        ()
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_rou_inv_rd_data)
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_result0(
        .clk            (clk                )
    ,   .wr_en          (ram_result0_wr_en  )
    ,   .wr_addr        (wr_cnt             )
    ,   .wr_data        (task_res           )
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_result0_rd_data)
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_result1(
        .clk            (clk                )
    ,   .wr_en          (ram_result1_wr_en  )
    ,   .wr_addr        (wr_cnt             )
    ,   .wr_data        (task_res           )
    ,   .rd_en          (1)
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_result1_rd_data)
);

dual_port_ram#(
        .filename       ("none")
    ,   .RAM_WIDTH      (K                  )
    ,   .ADDR_LINE      ($clog2(N)          )
)ram_y(
        .clk            (clk                )
    ,   .wr_en          (ram_y_wr_en        )
    ,   .wr_addr        (ram_y_wr_addr      )
    ,   .wr_data        (ram_y_wr_data      )
    ,   .rd_en          (1                  )
    ,   .rd_addr        (wr_addr            )
    ,   .rd_data        (ram_y_rd_data      )
);

endmodule
