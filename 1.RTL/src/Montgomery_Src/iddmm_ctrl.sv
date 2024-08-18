

module iddmm_ctrl#(
        parameter K = 128
    ,   parameter N = 32
    ,   parameter ADDR_W = $clog2(N)
)(
        input                           clk
    ,   input                           rst_n

    ,   input                           task_req
    ,   output                          task_end
    ,   output                          task_grant
    ,   output      [K-1        :0]     task_res

    ,   input                           finish_reg_flag

    ,   output  reg [ADDR_W     :0]     j_cnt

    ,   output      [ADDR_W     :0]     rd_data_addr
    ,   input       [K-1        :0]     rd_a_data
    ,   output                          clear_a_en
    ,   output      [K-1        :0]     clear_a_addr
);

reg         [ADDR_W-1   :0]     i_cnt_reg;
reg         [ADDR_W     :0]     j_cnt_reg;

assign      rd_data_addr    =   j_cnt_reg;

typedef enum logic [3:0] {
    STA_IDLE                    ,
    STA_WAIT_WR_DONE            ,
    STA_START                   ,
    STA_OUTPUT_AND_CLEAR_A                                
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
    case(state_next)
        STA_IDLE: begin
            if(task_req) begin
                state_next  =   STA_WAIT_WR_DONE;
            end
        end
        STA_WAIT_WR_DONE: begin
            if(finish_reg_flag) begin
                state_next  =   STA_START;
            end
        end
        STA_START: begin
        end
        STA_OUTPUT_AND_CLEAR_A: begin
            if(clear_a_addr == K-1) begin
                state_next  =   STA_IDLE;
            end
        end
        default: begin
            state_next  =   STA_IDLE;
        end
    endcase
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_cnt_reg   <=  0;
        j_cnt_reg   <=  0;
    end
    else begin
        case(state_next)
            STA_IDLE: begin
                i_cnt_reg       <=  0;
                j_cnt_reg       <=  0;
            end
            STA_START: begin
                i_cnt_reg       <=  j_cnt_reg == N ? i_cnt_reg + 1 : i_cnt_reg;
                j_cnt_reg       <=  j_cnt_reg == N ? 0 : j_cnt_reg + 1;

                j_cnt           <=  j_cnt_reg;
            end
            STA_OUTPUT_AND_CLEAR_A: begin
                i_cnt_reg       <=  i_cnt_reg;
                j_cnt_reg       <=  j_cnt_reg + 1;
            end
            default: begin
                i_cnt_reg       <=  0;
                j_cnt_reg       <=  0;
            end
        endcase
    end
end















endmodule