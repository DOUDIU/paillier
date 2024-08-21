/*
X = x5x4x3x2x1x0
Y = y7y6y5y4y3y2y1y0
X*Y = (x5x4x3x2x1x0) * (y7y6y5y4y3y2y1y0)
    = ((x5 << 120) + (x4 << 96) + (x3 << 72) + (x2 << 48) + (x1 << 24) + x0)
        * ((y7 << 112) + (y6 << 96) + (y5 << 80) + (y4 << 64) + (y3 << 48) + (y2 << 32) + (y1 << 16) + y0)
    =  (
        (x5y7) << 232
    +   (x5y6) << 216
    +   (x4y7) << 208
    +   (x5y5) << 200
    +   (x4y6) << 192

    +   (x5y4 + x3y7) << 184
    +   (x4y5) << 176
    +   (x5y3 + x3y6) << 168
    +   (x4y4 + x2y7) << 160
    +   (x5y2 + x3y5) << 152

    +   (x4y3 + x2y6) << 144
    +   (x5y1 + x3y4 + x1y7) << 136
    +   (x4y2 + x2y5) << 128


    +   (x5y0 + x3y3 + x1y6) << 120
    +   (x4y1 + x2y4 + x0y7) << 112
    +   (x3y2 + x1y5) << 104

    +   (x4y0 + x2y3 + x0y6) << 96
    +   (x3y1 + x1y4) << 88
    +   (x2y2 + x0y5) << 80
    +   (x3y0 + x1y3) << 72

    +   (x2y1 + x0y4) << 64
    +   (x1y2) << 56
    +   (x2y0 + x0y3) << 48
    +   (x1y1) << 40
    +   (x0y2) << 32
    +   (x1y0) << 24
    +   (x0y1) << 16
    +   (x0y0)
)
*/
module iddmm_mul_128_to_256(
        input                           clk
    ,   input                           rst_n

    ,   input           [127    :0]     x
    ,   input           [127    :0]     y
    ,   output  reg     [255    :0]     result
);
wire [7 :0]x5 = x[120   +: 8];
wire [23:0]x4 = x[96    +:24];
wire [23:0]x3 = x[72    +:24];
wire [23:0]x2 = x[48    +:24];
wire [23:0]x1 = x[24    +:24];
wire [23:0]x0 = x[ 0    +:24];

wire [15:0]y7 = y[127   :112];
wire [15:0]y6 = y[111   : 96];
wire [15:0]y5 = y[95    : 80];
wire [15:0]y4 = y[79    : 64];
wire [15:0]y3 = y[63    : 48];
wire [15:0]y2 = y[47    : 32];
wire [15:0]y1 = y[31    : 16];
wire [15:0]y0 = y[15    :  0];

reg[39:0]x5y7, x5y6, x5y5, x5y4, x5y3, x5y2, x5y1, x5y0;
reg[39:0]x4y7, x4y6, x4y5, x4y4, x4y3, x4y2, x4y1, x4y0;
reg[39:0]x3y7, x3y6, x3y5, x3y4, x3y3, x3y2, x3y1, x3y0;
reg[39:0]x2y7, x2y6, x2y5, x2y4, x2y3, x2y2, x2y1, x2y0;
reg[39:0]x1y7, x1y6, x1y5, x1y4, x1y3, x1y2, x1y1, x1y0;
reg[39:0]x0y7, x0y6, x0y5, x0y4, x0y3, x0y2, x0y1, x0y0;

// pipe 0
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x5y7 <= 0;
        x5y6 <= 0;
        x5y5 <= 0;
        x5y4 <= 0;
        x5y3 <= 0;
        x5y2 <= 0;
        x5y1 <= 0;
        x5y0 <= 0;

        x4y7 <= 0;
        x4y6 <= 0;
        x4y5 <= 0;
        x4y4 <= 0;
        x4y3 <= 0;
        x4y2 <= 0;
        x4y1 <= 0;
        x4y0 <= 0;

        x3y7 <= 0;
        x3y6 <= 0;
        x3y5 <= 0;
        x3y4 <= 0;
        x3y3 <= 0;
        x3y2 <= 0;
        x3y1 <= 0;
        x3y0 <= 0;

        x2y7 <= 0;
        x2y6 <= 0;
        x2y5 <= 0;
        x2y4 <= 0;
        x2y3 <= 0;
        x2y2 <= 0;
        x2y1 <= 0;
        x2y0 <= 0;

        x1y7 <= 0;
        x1y6 <= 0;
        x1y5 <= 0;
        x1y4 <= 0;
        x1y3 <= 0;
        x1y2 <= 0;
        x1y1 <= 0;
        x1y0 <= 0;

        x0y7 <= 0;
        x0y6 <= 0;
        x0y5 <= 0;
        x0y4 <= 0;
        x0y3 <= 0;
        x0y2 <= 0;
        x0y1 <= 0;
        x0y0 <= 0;
    end
    else begin
        x5y7 <= x5 * y7;
        x5y6 <= x5 * y6;
        x5y5 <= x5 * y5;
        x5y4 <= x5 * y4;
        x5y3 <= x5 * y3;
        x5y2 <= x5 * y2;
        x5y1 <= x5 * y1;
        x5y0 <= x5 * y0;

        x4y7 <= x4 * y7;
        x4y6 <= x4 * y6;
        x4y5 <= x4 * y5;
        x4y4 <= x4 * y4;
        x4y3 <= x4 * y3;
        x4y2 <= x4 * y2;
        x4y1 <= x4 * y1;
        x4y0 <= x4 * y0;

        x3y7 <= x3 * y7;
        x3y6 <= x3 * y6;
        x3y5 <= x3 * y5;
        x3y4 <= x3 * y4;
        x3y3 <= x3 * y3;
        x3y2 <= x3 * y2;
        x3y1 <= x3 * y1;
        x3y0 <= x3 * y0;

        x2y7 <= x2 * y7;
        x2y6 <= x2 * y6;
        x2y5 <= x2 * y5;
        x2y4 <= x2 * y4;
        x2y3 <= x2 * y3;
        x2y2 <= x2 * y2;
        x2y1 <= x2 * y1;
        x2y0 <= x2 * y0;

        x1y7 <= x1 * y7;
        x1y6 <= x1 * y6;
        x1y5 <= x1 * y5;
        x1y4 <= x1 * y4;
        x1y3 <= x1 * y3;
        x1y2 <= x1 * y2;
        x1y1 <= x1 * y1;
        x1y0 <= x1 * y0;

        x0y7 <= x0 * y7;
        x0y6 <= x0 * y6;
        x0y5 <= x0 * y5;
        x0y4 <= x0 * y4;
        x0y3 <= x0 * y3;
        x0y2 <= x0 * y2;
        x0y1 <= x0 * y1;
        x0y0 <= x0 * y0;
    end
end

// pipe 1
reg [64:0] sum_s1_0;
reg [49:0] sum_s1_1;
reg [49:0] sum_s1_2;
reg [49:0] sum_s1_3;
reg [49:0] sum_s1_4;
reg [49:0] sum_s1_5;
reg [49:0] sum_s1_6;
reg [49:0] sum_s1_7;
reg [49:0] sum_s1_8;
reg [49:0] sum_s1_9;
reg [49:0] sum_s1_10;
reg [49:0] sum_s1_11;
reg [49:0] sum_s1_12;
reg [49:0] sum_s1_13;
reg [56:0] sum_s1_14;
reg [56:0] sum_s1_15;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_s1_0    <=  0;
        sum_s1_1    <=  0;
        sum_s1_2    <=  0;
        sum_s1_3    <=  0;
        sum_s1_4    <=  0;
        sum_s1_5    <=  0;
        sum_s1_6    <=  0;
        sum_s1_7    <=  0;
        sum_s1_8    <=  0;
        sum_s1_9    <=  0;
        sum_s1_10   <=  0;
        sum_s1_11   <=  0;
        sum_s1_12   <=  0;
        sum_s1_13   <=  0;
        sum_s1_14   <=  0;
        sum_s1_15   <=  0;
    end
    else begin
        sum_s1_0    <=  x0y0 + (x0y1 << 16) + (x1y0 << 24);// << 0
        sum_s1_1    <=  x0y2 + (x1y1 << 8);// << 32
        sum_s1_2    <=  x2y0 + x0y3 + (x1y2 << 8);// << 48
        sum_s1_3    <=  x2y1 + x0y4 + ((x3y0 + x1y3) << 8);// << 64
        sum_s1_4    <=  x2y2 + x0y5 + ((x3y1 + x1y4) << 8);// << 80
        sum_s1_5    <=  x4y0 + x2y3 + x0y6;// << 96
        sum_s1_6    <=  (x3y2 + x1y5) << 8;// << 96
        sum_s1_7    <=  x4y1 + x2y4 + x0y7;// << 112

        sum_s1_8    <=  (x5y0 + x3y3 + x1y6) << 8;// << 112
        sum_s1_9    <=  x4y2 + x2y5;// << 128
        sum_s1_10   <=  (x5y1 + x3y4 + x1y7) << 8;// << 128
        sum_s1_11   <=  x4y3 + x2y6 + ((x5y2 + x3y5) << 8);// << 144
        sum_s1_12   <=  x4y4 + x2y7 + ((x5y3 + x3y6) << 8);// << 160
        sum_s1_13   <=  x4y5 + ((x5y4 + x3y7) << 8);// << 176
        sum_s1_14   <=  x4y6 + (x5y5 << 8) + (x4y7 << 16);// << 192
        sum_s1_15   <=  x5y6 + (x5y7 << 16);// << 216
    end
end

// pipe 2
reg [82 :0]  sum_s2_0;
reg [66 :0]  sum_s2_1;
reg [66 :0]  sum_s2_2;
reg [66 :0]  sum_s2_3;
reg [66 :0]  sum_s2_4;
reg [66 :0]  sum_s2_5;
reg [66 :0]  sum_s2_6;
reg [81 :0]  sum_s2_7;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_s2_0    <=  0;
        sum_s2_1    <=  0;
        sum_s2_2    <=  0;
        sum_s2_3    <=  0;
        sum_s2_4    <=  0;
        sum_s2_5    <=  0;
        sum_s2_6    <=  0;
        sum_s2_7    <=  0;
    end
    else begin
        sum_s2_0    <=  sum_s1_0  + (sum_s1_1  << 32);// << 0
        sum_s2_1    <=  sum_s1_2  + (sum_s1_3  << 16);// << 48
        sum_s2_2    <=  sum_s1_4  + (sum_s1_5  << 16);// << 80
        sum_s2_3    <=  sum_s1_6  + (sum_s1_7  << 16);// << 96

        sum_s2_4    <=  sum_s1_8  + (sum_s1_9  << 16);// << 112
        sum_s2_5    <=  sum_s1_10 + (sum_s1_11 << 16);// << 128
        sum_s2_6    <=  sum_s1_12 + (sum_s1_13 << 16);// << 160
        sum_s2_7    <=  sum_s1_14 + (sum_s1_15 << 24);// << 192
    end
end

// pipe 3
reg [114:0] sum_s3_0;
reg [83 :0] sum_s3_1;
reg [83 :0] sum_s3_2;
reg [114:0] sum_s3_3;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_s3_0    <=  0;
        sum_s3_1    <=  0;
        sum_s3_2    <=  0;
        sum_s3_3    <=  0;
    end
    else begin
        sum_s3_0    <=  sum_s2_0 + (sum_s2_1 << 48);// << 0
        sum_s3_1    <=  sum_s2_2 + (sum_s2_3 << 16);// << 80

        sum_s3_2    <=  sum_s2_4 + (sum_s2_5 << 16);// << 112
        sum_s3_3    <=  sum_s2_6 + (sum_s2_7 << 32);// << 160
    end
end

// pipe 4
reg [164:0] sum_s4_0;
reg [164:0] sum_s4_1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_s4_0    <=  0;
        sum_s4_1    <=  0;
    end
    else begin
        sum_s4_0    <=  sum_s3_0 + (sum_s3_1 << 80);// << 0
        sum_s4_1    <=  sum_s3_2 + (sum_s3_3 << 48);// << 112
    end
end

//pipe 5
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        result <= 0;
    end
    else begin
        result <= sum_s4_0 + (sum_s4_1 << 112);
        // result  <=  (
        //     +   (sum_s2_0   << 0)
        //     +   (sum_s2_1   << 48)
        //     +   (sum_s2_2   << 80)
        //     +   (sum_s2_3   << 96)
        //     +   (sum_s2_4   << 112)
        //     +   (sum_s2_5   << 128)
        //     +   (sum_s2_6   << 160)
        //     +   (sum_s2_7   << 192)

        //         (sum_s1_0   << 0)
        //     +   (sum_s1_1   << 32)
        //     +   (sum_s1_2   << 48)
        //     +   (sum_s1_3   << 64)
        //     +   (sum_s1_4   << 80)
        //     +   (sum_s1_5   << 96)
        //     +   (sum_s1_6   << 96)
        //     +   (sum_s1_7   << 112)
        //     +   (sum_s1_8   << 112)
        //     +   (sum_s1_9   << 128)
        //     +   (sum_s1_10  << 128)
        //     +   (sum_s1_11  << 144)
        //     +   (sum_s1_12  << 160)
        //     +   (sum_s1_13  << 176)
        //     +   (sum_s1_14  << 192)
        //     +   (sum_s1_15  << 216)
        // );
    end
end

endmodule
/*
    X = x5x4x3x2x1x0
    Y = y7y6y5y4y3y2y1y0
    X*Y = (x5x4x3x2x1x0) * (y7y6y5y4y3y2y1y0)
        = ((x5 << 120) + (x4 << 96) + (x3 << 72) + (x2 << 48) + (x1 << 24) + x0)
            * ((y7 << 112) + (y6 << 96) + (y5 << 80) + (y4 << 64) + (y3 << 48) + (y2 << 32) + (y1 << 16) + y0)
        =  (
            ((x5y7) << 232)
        +   ((x5y6) << 216)
        +   ((x5y5) << 200)
        +   ((x5y4) << 184)
        +   ((x5y3) << 168)
        +   ((x5y2) << 152)
        +   ((x5y1) << 136)
        +   ((x5y0) << 120)

        +   ((x4y7) << 208)
        +   ((x4y6) << 192)
        +   ((x4y5) << 176)
        +   ((x4y4) << 160)
        +   ((x4y3) << 144)
        +   ((x4y2) << 128)
        +   ((x4y1) << 112)
        +   ((x4y0) << 96)

        +   ((x3y7) << 184)
        +   ((x3y6) << 168)
        +   ((x3y5) << 152)
        +   ((x3y4) << 136)
        +   ((x3y3) << 120)
        +   ((x3y2) << 104)
        +   ((x3y1) << 88)
        +   ((x3y0) << 72)

        +   ((x2y7) << 160)
        +   ((x2y6) << 144)
        +   ((x2y5) << 128)
        +   ((x2y4) << 112)
        +   ((x2y3) << 96)
        +   ((x2y2) << 80)
        +   ((x2y1) << 64)
        +   ((x2y0) << 48)

        +   ((x1y7) << 136)
        +   ((x1y6) << 120)
        +   ((x1y5) << 104)
        +   ((x1y4) << 88)
        +   ((x1y3) << 72)
        +   ((x1y2) << 56)
        +   ((x1y1) << 40)
        +   ((x1y0) << 24)

        +   ((x0y7) << 112)
        +   ((x0y6) << 96)
        +   ((x0y5) << 80)
        +   ((x0y4) << 64)
        +   ((x0y3) << 48)
        +   ((x0y2) << 32)
        +   ((x0y1) << 16)
        +   ((x0y0))
    )
*/
/*
    X = x5x4x3x2x1x0
    Y = y7y6y5y4y3y2y1y0
    X*Y = (x5x4x3x2x1x0) * (y7y6y5y4y3y2y1y0)
        = ((x5 << 120) + (x4 << 96) + (x3 << 72) + (x2 << 48) + (x1 << 24) + x0)
            * ((y7 << 112) + (y6 << 96) + (y5 << 80) + (y4 << 64) + (y3 << 48) + (y2 << 32) + (y1 << 16) + y0)
        =  (
                ((x5y7) << 232)
            +   ((x5y6) << 216)
            +   ((x5y5) << 200)

            +   ((x5y4 + x3y7) << 184)
            +   ((x5y3 + x3y6) << 168)
            +   ((x5y2 + x3y5) << 152)
            +   ((x5y1 + x3y4 + x1y7) << 136)
            +   ((x5y0 + x3y3 + x1y6) << 120)

            +   ((x4y7) << 208)
            +   ((x4y6) << 192)
            +   ((x4y5) << 176)
            +   ((x4y4 + x2y7) << 160)
            +   ((x4y3 + x2y6) << 144)
            +   ((x4y2 + x2y5) << 128)
            +   ((x4y1 + x2y4 + x0y7) << 112)
            +   ((x4y0 + x2y3 + x0y6) << 96)

            +   ((x3y2 + x1y5) << 104)
            +   ((x3y1 + x1y4) << 88)
            +   ((x3y0 + x1y3) << 72)

            +   ((x2y2 + x0y5) << 80)
            +   ((x2y1 + x0y4) << 64)
            +   ((x2y0 + x0y3) << 48)

            +   ((x1y2) << 56)
            +   ((x1y1) << 40)
            +   ((x1y0) << 24)

            +   ((x0y2) << 32)
            +   ((x0y1) << 16)
            +   ((x0y0))
    )
*/
/*
    X = x5x4x3x2x1x0
    Y = y7y6y5y4y3y2y1y0
    X*Y = (x5x4x3x2x1x0) * (y7y6y5y4y3y2y1y0)
        = ((x5 << 120) + (x4 << 96) + (x3 << 72) + (x2 << 48) + (x1 << 24) + x0)
            * ((y7 << 112) + (y6 << 96) + (y5 << 80) + (y4 << 64) + (y3 << 48) + (y2 << 32) + (y1 << 16) + y0)
        =  (
                (x5y7) << 232
            +   (x5y6) << 216
            +   (x4y7) << 208
            +   (x5y5) << 200
            +   (x4y6) << 192
            +   (x5y4 + x3y7) << 184
            +   (x4y5) << 176
            +   (x5y3 + x3y6) << 168
            +   (x4y4 + x2y7) << 160
            +   (x5y2 + x3y5) << 152
            +   (x4y3 + x2y6) << 144
            +   (x5y1 + x3y4 + x1y7) << 136
            +   (x4y2 + x2y5) << 128
            +   (x5y0 + x3y3 + x1y6) << 120
            +   (x4y1 + x2y4 + x0y7) << 112
            +   (x3y2 + x1y5) << 104

            +   (x4y0 + x2y3 + x0y6) << 96

            +   (x2y2 + x0y5 + ((x3y1 + x1y4) << 8)) << 80

            +   (x2y1 + x0y4 + ((x3y0 + x1y3) << 8)) << 64

            +   (x2y0 + x0y3 + (x1y2 << 8)) << 48

            +   (x0y2 + (x1y1 << 8)) << 32

            +   ((x0y0) + (x0y1 << 16) + (x1y0 << 24))
    )
*/
