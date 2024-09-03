module iddmm_ctrl#(
        parameter K = 256
    ,   parameter N = 16
    ,   parameter ADDR_W = $clog2(N)
)(
        input                           clk
    ,   input                           rst_n

    ,   input                           task_req
    ,   output  reg                     task_end
    ,   output  reg                     task_grant
    ,   output      [K-1        :0]     task_res

    ,   output  reg [ADDR_W-1   :0]     i_cnt
    ,   output  reg [ADDR_W     :0]     j_cnt

    ,   output      [ADDR_W     :0]     rd_data_addr_i
    ,   output      [ADDR_W     :0]     rd_data_addr_j

    ,   input                           cal_done
    ,   input                           cal_sign

    ,   output  reg                     fifo_rd_en
    ,   input       [K-1        :0]     fifo_rd_data_a
    ,   input       [K-1        :0]     fifo_rd_data_sub
);

reg         [ADDR_W-1   :0]     i_cnt_reg;
reg         [ADDR_W     :0]     j_cnt_reg;
reg         [ADDR_W-1   :0]     output_cnt;
reg                             task_req_d1;
assign      rd_data_addr_i  =   i_cnt_reg;
assign      rd_data_addr_j  =   j_cnt_reg;
assign      task_res        =   cal_sign ? fifo_rd_data_sub : fifo_rd_data_a;

typedef enum logic [3:0] {
    STA_IDLE                    ,
    STA_START                   ,
    STA_WAIT                    ,
    STA_OUTPUT
} FSM_STATE;

FSM_STATE   state_now;
FSM_STATE   state_next;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_now   <=  STA_IDLE;
    end
    else begin
        state_now   <=  state_next;
    end
end

always@(*) begin
    case(state_now)
        STA_IDLE: begin
            if(!task_req_d1 & task_req) begin
                state_next  =   STA_START;
            end
            else begin
                state_next  =   STA_IDLE;
            end
        end
        STA_START: begin
            if((i_cnt_reg == N - 1) && (j_cnt_reg == N)) begin
                state_next  =   STA_WAIT;
            end
            else begin
                state_next  =   STA_START;
            end
        end
        STA_WAIT: begin
            if(cal_done) begin
                state_next  =   STA_OUTPUT;
            end
            else begin
                state_next  =   STA_WAIT;
            end
        end
        STA_OUTPUT: begin
            if(output_cnt == N - 1) begin
                state_next  =   STA_IDLE;
            end
            else begin
                state_next  =   STA_OUTPUT;
            end
        end
        default: begin
            state_next  =   STA_IDLE;
        end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_cnt_reg       <=  0;
        j_cnt_reg       <=  0;
        i_cnt           <=  0;
        j_cnt           <=  0;
        output_cnt      <=  0;
        fifo_rd_en      <=  0;
        task_grant      <=  0;
        task_end        <=  0;
        task_req_d1     <=  0;
    end
    else begin
        i_cnt           <=  i_cnt_reg;
        j_cnt           <=  j_cnt_reg;
        task_req_d1     <=  task_req;
        case(state_now)
            STA_IDLE: begin
                i_cnt_reg       <=  0;
                j_cnt_reg       <=  0;
                output_cnt      <=  0;
                fifo_rd_en      <=  0;
                task_grant      <=  0;
                task_end        <=  0;
            end
            STA_START: begin
                i_cnt_reg       <=  j_cnt_reg == N ? i_cnt_reg + 1 : i_cnt_reg;
                j_cnt_reg       <=  j_cnt_reg == N ? 0 : j_cnt_reg + 1;
            end
            STA_WAIT: begin
                i_cnt_reg       <=  0;
                j_cnt_reg       <=  0;
            end
            STA_OUTPUT: begin
                output_cnt      <=  output_cnt + 1;
                fifo_rd_en      <=  1;
                task_grant      <=  1;
                if(output_cnt == N - 1) begin
                    task_end        <=   1;
                end
            end
            default: begin
                i_cnt_reg       <=  0;
                j_cnt_reg       <=  0;
                i_cnt           <=  0;
                j_cnt           <=  0;
                output_cnt      <=  0;
                fifo_rd_en      <=  0;
                task_grant      <=  0;
                task_end        <=  0;
            end
        endcase
    end
end


endmodule