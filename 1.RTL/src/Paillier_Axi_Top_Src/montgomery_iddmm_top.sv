module montgomery_iddmm_top#(
        parameter K             = 128
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

    ,   input       [1  :0]     mm_type
    ,   input                   mm_start
    ,   input       [K-1:0]     mm_x
    ,   input                   mm_x_valid
    ,   input       [K-1:0]     mm_y
    ,   input                   mm_y_valid
    ,   output      [K-1:0]     mm_result
    ,   output                  mm_valid
);

reg     mm_flag;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mm_flag <= 1'b0;
    end
    else if(mm_start) begin
        mm_flag <= 1'b1;
    end
    else if(me_start) begin
        mm_flag <= 1'b0;
    end
end


wire    [2  :0]             wr_ena_me       ;
wire    [$clog2(N)-1:0]     wr_addr_me      ;
wire    [K-1:0]             wr_x_me         ;
wire    [K-1:0]             wr_y_me         ;
wire    [K-1:0]             wr_m_me         ;
wire    [K-1:0]             wr_m1_me        ;
wire                        task_req_me     ;
wire                        task_end_me     ;
wire                        task_grant_me   ;
wire    [K-1:0]             task_res_me     ;

wire    [2  :0]             wr_ena_mm       ;
wire    [$clog2(N)-1:0]     wr_addr_mm      ;
wire    [K-1:0]             wr_x_mm         ;
wire    [K-1:0]             wr_y_mm         ;
wire    [K-1:0]             wr_m_mm         ;
wire    [K-1:0]             wr_m1_mm        ;
wire                        task_req_mm     ;
wire                        task_end_mm     ;
wire                        task_grant_mm   ;
wire    [K-1:0]             task_res_mm     ;

wire    [2  :0]             wr_ena          ;
wire    [$clog2(N)-1:0]     wr_addr         ;
wire    [K-1:0]             wr_x            ;
wire    [K-1:0]             wr_y            ;
wire    [K-1:0]             wr_m            ;
wire    [K-1:0]             wr_m1           ;
wire                        task_req        ;
wire                        task_end        ;
wire                        task_grant      ;
wire    [K-1:0]             task_res        ;

assign      wr_ena          =   mm_flag     ?   wr_ena_mm       :   wr_ena_me       ;
assign      wr_addr         =   mm_flag     ?   wr_addr_mm      :   wr_addr_me      ;
assign      wr_x            =   mm_flag     ?   wr_x_mm         :   wr_x_me         ;
assign      wr_y            =   mm_flag     ?   wr_y_mm         :   wr_y_me         ;
assign      wr_m            =   mm_flag     ?   wr_m_mm         :   wr_m_me         ;
assign      wr_m1           =   mm_flag     ?   wr_m1_mm        :   wr_m1_me        ;

assign      task_req        =   mm_flag     ?   task_req_mm     :   task_req_me     ;

assign      task_end_mm     =   mm_flag     ?   task_end        :   0               ;
assign      task_grant_mm   =   mm_flag     ?   task_grant      :   0               ;
assign      task_res_mm     =   mm_flag     ?   task_res        :   0               ;

assign      task_end_me     =   !mm_flag    ?   task_end        :   0               ;
assign      task_grant_me   =   !mm_flag    ?   task_grant      :   0               ;
assign      task_res_me     =   !mm_flag    ?   task_res        :   0               ;

me_iddmm_top #(
        .K                  (K              )
    ,   .N                  (N              )
    ,   .OUTSIDE_MONTGOMERY (1              )
)me_4096_inst_0(
        .clk                (clk            )
    ,   .rst_n              (rst_n          )

    ,   .me_start           (me_start       )
    ,   .me_x               (me_x           )
    ,   .me_x_valid         (me_x_valid     )
    ,   .me_y               (me_y           )
    ,   .me_y_valid         (me_y_valid     )
    ,   .me_result          (me_result      )
    ,   .me_valid           (me_valid       )

    ,   .iddmm_wr_ena       (wr_ena_me      )
    ,   .iddmm_wr_addr      (wr_addr_me     )
    ,   .iddmm_wr_x         (wr_x_me        )
    ,   .iddmm_wr_y         (wr_y_me        )
    ,   .iddmm_wr_m         (wr_m_me        )
    ,   .iddmm_wr_m1        (wr_m1_me       )
    ,   .iddmm_task_req     (task_req_me    )
    ,   .iddmm_task_end     (task_end_me    )
    ,   .iddmm_task_grant   (task_grant_me  )    
    ,   .iddmm_task_res     (task_res_me    )
);

mm_iddmm_top #(
        .K                  (K              )
    ,   .N                  (N              )
    ,   .OUTSIDE_MONTGOMERY (1              )
)mm_4096_inst_0(
        .clk                (clk            )
    ,   .rst_n              (rst_n          )

    ,   .mm_type            (mm_type        )
    ,   .mm_start           (mm_start       )
    ,   .mm_x               (mm_x           )
    ,   .mm_x_valid         (mm_x_valid     )
    ,   .mm_y               (mm_y           )
    ,   .mm_y_valid         (mm_y_valid     )
    ,   .mm_result          (mm_result      )
    ,   .mm_valid           (mm_valid       )

    ,   .iddmm_wr_ena       (wr_ena_mm      )
    ,   .iddmm_wr_addr      (wr_addr_mm     )
    ,   .iddmm_wr_x         (wr_x_mm        )
    ,   .iddmm_wr_y         (wr_y_mm        )
    ,   .iddmm_wr_m         (wr_m_mm        )
    ,   .iddmm_wr_m1        (wr_m1_mm       )
    ,   .iddmm_task_req     (task_req_mm    )
    ,   .iddmm_task_end     (task_end_mm    )
    ,   .iddmm_task_grant   (task_grant_mm  )    
    ,   .iddmm_task_res     (task_res_mm    )
);

iddmm_top #(
        .K                  (K              )   // K bits in every group
    ,   .N                  (N              )   // Number of groups
)u_iddmm_top(    
        .clk                (clk            )
    ,   .rst_n              (rst_n          )

    ,   .wr_ena             (wr_ena         )
    ,   .wr_addr            (wr_addr        )
    ,   .wr_x               (wr_x           )   //low words first
    ,   .wr_y               (wr_y           )   //low words first
    ,   .wr_m               (wr_m           )   //low words first
    ,   .wr_m1              (wr_m1          )
    ,   .task_req           (task_req       )
    ,   .task_end           (task_end       )
    ,   .task_grant         (task_grant     )
    ,   .task_res           (task_res       )    
);


endmodule