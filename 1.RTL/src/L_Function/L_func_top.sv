module L_func_top #(
        parameter K       = 128
    ,   parameter N       = 32
)(
        input               clk
    ,   input               rst_n

    ,   input               task_start

    ,   input   [K-1:0]     L_x
    ,   input               L_x_valid

    ,   output  [K-1:0]     L_out
    ,   output              L_out_valid
);

wire    [K-1    :   0]      PAILLIER_N          [N-1:0];

wire    [K-1    :   0]      L_x_1_out;
wire                        L_x_1_valid_out;

assign  PAILLIER_N          =       {
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'h0,
    128'hc1df05419c6057e26ebad2d3abd7123c,
    128'hdd612c4cf0c09d1881f83b3ea46ad2f1,
    128'h239e21d0a3a778cfbfa9f4f46a0f355c,
    128'h3c57d0305706482133aa5b0aa7d96179,
    128'h8442d0c0a2d7fd48359690c361c66fa0,
    128'hdc7131e9dcf83e11cab3812b22861546,
    128'ha5be250c5ab7d671d5e6129b0ef708e1,
    128'h5d2d0ed5bde948bf5c4339c0d7e45b9,
    128'hc3ac4ef3c50af15fbd37492f126c5a51,
    128'h8af725228255ab1b6ecab2f668149e3f,
    128'hf74e3cd371e7fadf3edb24476ca0632f,
    128'ha53d0af0840ed39b736a5f08339a21e3,
    128'h5a53aa612f73dabd6864bf2dc85b296b,
    128'h4e2a2bddcdabdae21b8c938d1c95d327,
    128'h8213cc126746497a511d8d29aea5ac13,
    128'hd2c5de79b62fb1a1a8e12114c110a8bf
};

minor_1 #(
        .K              (K                  )
    ,   .N              (N                  )
)minor_1_inst(
        .clk            (clk                )
    ,   .rst_n          (rst_n              )
    ,   .task_start     (task_start         )
    ,   .L_x            (L_x                )
    ,   .L_x_valid      (L_x_valid          )
    ,   .L_x_1          (L_x_1_out          )
    ,   .L_x_1_valid    (L_x_1_valid_out    ) 
);





endmodule







module minor_1 #(
        parameter K       = 128
    ,   parameter N       = 32
)(
        input               clk
    ,   input               rst_n

    ,   input               task_start

    ,   input   [K-1:0]     L_x
    ,   input               L_x_valid

    ,   output  [K-1:0]     L_x_1
    ,   output              L_x_1_valid
);

parameter   STA_IDLE    =   0,
            STA_MINOR   =   1;

reg     [3:0]       state_now;
reg     [3:0]       state_next;

reg     [K-1:0]     L_x_1_out;
reg                 L_x_1_valid_out;

assign  L_x_1       =   L_x_1_out;
assign  L_x_1_valid =   L_x_1_valid_out;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_now   <= STA_IDLE;
    end else begin
        state_now   <= state_next;
    end
end

always@(*) begin
    state_next  =   STA_IDLE;
    case(state_now)
        STA_IDLE: begin
            if(task_start) begin
                state_next  =   STA_MINOR;
            end
        end
        STA_MINOR: begin
            if(L_x_valid) begin
                state_next  =   L_x == 0 ? STA_MINOR : STA_IDLE;
            end
            else begin
                state_next  =   STA_MINOR;
            end
        end
        default: begin
            state_next  =   STA_IDLE;
        end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        L_x_1_out           <=  0;
        L_x_1_valid_out     <=  0;
    end
    else begin
        case(state_now)
            STA_IDLE: begin
                L_x_1_out           <=  L_x;
                L_x_1_valid_out     <=  L_x_valid;
            end
            STA_MINOR: begin
                L_x_1_out           <=  L_x - 1;
                L_x_1_valid_out     <=  L_x_valid;
            end
            default: begin
                L_x_1_out           <=  L_x;
                L_x_1_valid_out     <=  L_x_valid;
            end
        endcase
    end
end






endmodule