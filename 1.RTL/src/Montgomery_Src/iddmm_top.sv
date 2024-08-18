
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
wire    [K-1        :0]     p               ;
wire    [ADDR_W     :0]     rd_data_addr    ;
wire                        clear_a_en      ;
wire    [ADDR_W-1   :0]     clear_a_addr    ;
wire    [ADDR_W     :0]     j_cnt           ;
wire                        finish_reg_flag ;

assign  finish_reg_flag = (wr_ena !=0) && (wr_addr == N-1);

iddmm_ctrl iddmm_ctrl(
        .clk                (clk                )
    ,   .rst_n              (rst_n              )

    ,   .task_req           (task_req           )
    ,   .task_end           (task_end           )
    ,   .task_grant         (task_grant         )
    ,   .task_res           (task_res           )

    ,   .finish_reg_flag    (finish_reg_flag    )

    ,   .j_cnt              (j_cnt              )

    ,   .rd_data_addr       (rd_data_addr       )
    ,   .rd_a_data          (a                  )
    ,   .clear_a_en         (clear_a_en         )
    ,   .clear_a_addr       (clear_a_addr       )
);

//fully pipelined calculation architecture
iddmm_cal iddmm_cal_inst(
        .clk                (clk                )
    ,   .rst_n              (rst_n              )
    ,   .j_cnt              (j_cnt              )
    ,   .a                  (a                  )
    ,   .x                  (x                  )
    ,   .y                  (y                  )
    ,   .p                  (p                  )
    ,   .p1                 (wr_m1              )

    ,   .wr_a_en            (wr_a_en            )
    ,   .wr_a_addr          (wr_a_addr          )
    ,   .wr_a_data          (wr_a_data          )
);

dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)+1        )
)simple_ram_x(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[0]          )
    ,   .wr_addr            ({1'd0,wr_addr}     )
    ,   .wr_data            (wr_x               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr       )
    ,   .rd_data            (x                  )
);
dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)          )
)simple_ram_y(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[1]          )
    ,   .wr_addr            (wr_addr            )
    ,   .wr_data            (wr_y               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr       )
    ,   .rd_data            (y                  )
);
dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)          )
)simple_ram_m(
        .clk                (clk                )
    ,   .wr_en              (wr_ena[2]          )
    ,   .wr_addr            (wr_addr            )
    ,   .wr_data            (wr_m               )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr       )
    ,   .rd_data            (p                  )
);
wire                        wr_a_en  ;
wire    [ADDR_W     :0]     wr_a_addr;
wire    [K-1        :0]     wr_a_data;

assign  wr_a_en     =   clear_a_en ? wr_a_en   : 1;
assign  wr_a_addr   =   clear_a_en ? wr_a_addr : clear_a_addr;
assign  wr_a_data   =   clear_a_en ? wr_a_data : 0;

dual_port_ram#(
        .filename           ("none"             )
    ,   .RAM_WIDTH          (K                  )
    ,   .ADDR_LINE          ($clog2(N)          )
)dual_port_ram_a(
        .clk                (clk                )
    ,   .wr_en              (wr_a_en            )
    ,   .wr_addr            (wr_a_addr          )
    ,   .wr_data            (wr_a_data          )
    ,   .rd_en              (1                  )
    ,   .rd_addr            (rd_data_addr       )
    ,   .rd_data            (a                  )
);


endmodule