
//result = x*y*mod_inv(r,m)%m 
//r is the bitwidth of x,y,m
module iddmm_top#(
        parameter K = 128                       // K bits in every group
    ,   parameter N = 32                        // Number of groups
    ,   parameter ADDR_W = $clog2(N)
)(
        input                           clk
    ,   input                           rst_n

    ,   input       [2          :0]     wr_ena
    ,   input       [ADDR_W-1   :0]     wr_addr
    ,   input       [K-1        :0]     wr_x
    ,   input       [K-1        :0]     wr_y
    ,   input       [K-1        :0]     wr_m
    ,   input       [K-1        :0]     wr_m1

    ,   input                           task_req
    ,   output                          task_end
    ,   output                          task_grant
    ,   output      [K-1        :0]     task_res
);

wire    [K-1        :0]     a               ;
wire    [K-1        :0]     x               ;
wire    [K-1        :0]     y               ;
wire    [K-1        :0]     y_adv           ;
wire    [K-1        :0]     p               ;
wire    [ADDR_W-1   :0]     i_cnt           ;
wire    [ADDR_W     :0]     j_cnt           ;
wire    [ADDR_W     :0]     rd_data_addr_i  ;
wire    [ADDR_W     :0]     rd_data_addr_j  ;

wire    [K-1        :0]     result_q_update ;

wire                        cal_done        ;
wire                        cal_sign        ;

wire                        wr_a_en         ;
wire    [ADDR_W     :0]     wr_a_addr       ;
wire    [K-1        :0]     wr_a_data       ;

wire                        fifo_wr_en_a    ;
wire    [K-1        :0]     fifo_wr_data_a  ;
wire                        fifo_wr_en_sub  ;
wire    [K-1        :0]     fifo_wr_data_sub;

wire                        fifo_rd_en      ;
wire    [K-1        :0]     fifo_rd_data_a  ;
wire    [K-1        :0]     fifo_rd_data_sub;

iddmm_ctrl iddmm_ctrl(
        .clk                (clk                )
    ,   .rst_n              (rst_n              )

    ,   .task_req           (task_req           )
    ,   .task_end           (task_end           )
    ,   .task_grant         (task_grant         )
    ,   .task_res           (task_res           )

    ,   .i_cnt              (i_cnt              )
    ,   .j_cnt              (j_cnt              )

    ,   .rd_data_addr_i     (rd_data_addr_i     )
    ,   .rd_data_addr_j     (rd_data_addr_j     )

    ,   .cal_done           (cal_done           )
    ,   .cal_sign           (cal_sign           )

    ,   .fifo_rd_en         (fifo_rd_en         )
    ,   .fifo_rd_data_a     (fifo_rd_data_a     )
    ,   .fifo_rd_data_sub   (fifo_rd_data_sub   )
);

iddmm_q_update iddmm_q_update(
        .clk                (clk                )
    ,   .rst_n              (rst_n              )

    ,   .wr_ena             (wr_ena             )
    ,   .wr_addr            (wr_addr            )
    ,   .wr_x               (wr_x               )
    ,   .wr_y               (wr_y               )
    
    ,   .i_cnt              (i_cnt              )
    ,   .j_cnt              (j_cnt              )
    ,   .x                  (x                  )
    ,   .y_adv              (y_adv              )
    
    ,   .wr_a_en            (wr_a_en            )
    ,   .wr_a_addr          (wr_a_addr          )
    ,   .wr_a_data          (wr_a_data          )
    
    ,   .p1                 (wr_m1              )

    ,   .result_q_update    (result_q_update    )
);

//fully pipelined calculation architecture
iddmm_cal iddmm_cal(
        .clk                (clk                )
    ,   .rst_n              (rst_n              )

    ,   .i_cnt              (i_cnt              )
    ,   .j_cnt              (j_cnt              )

    ,   .a                  (a                  )
    ,   .x                  (x                  )
    ,   .y                  (y                  )
    ,   .p                  (p                  )
    ,   .p1                 (wr_m1              )

    ,   .wr_a_en            (wr_a_en            )
    ,   .wr_a_addr          (wr_a_addr          )
    ,   .wr_a_data          (wr_a_data          )

    ,   .fifo_wr_en_a       (fifo_wr_en_a       )
    ,   .fifo_wr_data_a     (fifo_wr_data_a     )
    ,   .fifo_wr_en_sub     (fifo_wr_en_sub     )
    ,   .fifo_wr_data_sub   (fifo_wr_data_sub   )

    ,   .cal_done           (cal_done           )
    ,   .cal_sign           (cal_sign           )

    ,   .result_q_update    (result_q_update    )
);

dual_port_dram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)+1        )
)dual_port_ram_x(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[0]          )
    ,   .wr_addr            ({1'd0,wr_addr}     )
    ,   .wr_data            (wr_x               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr_j     )
    ,   .rd_data            (x                  )
);
dual_port_dram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)          )
)dual_port_ram_y(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[1]          )
    ,   .wr_addr            (wr_addr            )
    ,   .wr_data            (wr_y               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr_i     )
    ,   .rd_data            (y                  )
);
dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)          )
)dual_port_ram_y_adv(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[1]          )
    ,   .wr_addr            (wr_addr            )
    ,   .wr_data            (wr_y               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr_i+1   )
    ,   .rd_data            (y_adv              )
);
dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)+1        )
)dual_port_ram_m(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[2]          )
    ,   .wr_addr            ({1'd0,wr_addr}     )
    ,   .wr_data            (wr_m               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr_j     )
    ,   .rd_data            (p                  )
);

dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)+1        )
)dual_port_ram_a(
        .clk                (clk                )
    ,   .wr_en              (wr_a_en            )
    ,   .wr_addr            (wr_a_addr          )
    ,   .wr_data            (wr_a_data          )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr_j     )
    ,   .rd_data            (a                  )
);

fifo_ram#(
        .DATA_WIDTH         (K                  )
    ,   .DATA_DEPTH         (N                  )
)fifo_ram_a(
        .clk                (clk                )
    ,   .wr_en              (fifo_wr_en_a       )
    ,   .wr_data            (fifo_wr_data_a     )
    ,   .wr_full            ()
    ,   .rd_en              (fifo_rd_en         )
    ,   .rd_data            (fifo_rd_data_a     )
    ,   .rd_empty           ()
);

fifo_ram#(
        .DATA_WIDTH         (K                  )
    ,   .DATA_DEPTH         (N                  )
)fifo_ram_sub(
        .clk                (clk                )
    ,   .wr_en              (fifo_wr_en_sub     )
    ,   .wr_data            (fifo_wr_data_sub   )
    ,   .wr_full            ()
    ,   .rd_en              (fifo_rd_en         )
    ,   .rd_data            (fifo_rd_data_sub   )
    ,   .rd_empty           ()
);

endmodule