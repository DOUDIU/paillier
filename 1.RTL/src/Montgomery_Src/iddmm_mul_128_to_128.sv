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
module iddmm_mul_128_to_128(
        input                           clk
    ,   input                           rst_n

    ,   input           [127    :0]     x
    ,   input           [127    :0]     y
    ,   output  reg     [255    :0]     result
);
wire    [7 :0]  x5  =   x[120   +: 8];
wire    [23:0]  x4  =   x[96    +:24];
wire    [23:0]  x3  =   x[72    +:24];
wire    [23:0]  x2  =   x[48    +:24];
wire    [23:0]  x1  =   x[24    +:24];
wire    [23:0]  x0  =   x[ 0    +:24];

wire    [15:0]  y7  =   y[127   :112];
wire    [15:0]  y6  =   y[111   : 96];
wire    [15:0]  y5  =   y[95    : 80];
wire    [15:0]  y4  =   y[79    : 64];
wire    [15:0]  y3  =   y[63    : 48];
wire    [15:0]  y2  =   y[47    : 32];
wire    [15:0]  y1  =   y[31    : 16];
wire    [15:0]  y0  =   y[15    :  0];

reg     [39:0]  x5y0;
reg     [39:0]  x4y1, x4y0;
reg     [39:0]  x3y3, x3y2, x3y1, x3y0;
reg     [39:0]  x2y4, x2y3, x2y2, x2y1, x2y0;
reg     [39:0]  x1y6, x1y5, x1y4, x1y3, x1y2, x1y1, x1y0;
reg     [39:0]  x0y7, x0y6, x0y5, x0y4, x0y3, x0y2, x0y1, x0y0;

// pipe 0
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x5y0 <= 0;

        x4y1 <= 0;
        x4y0 <= 0;

        x3y3 <= 0;
        x3y2 <= 0;
        x3y1 <= 0;
        x3y0 <= 0;

        x2y4 <= 0;
        x2y3 <= 0;
        x2y2 <= 0;
        x2y1 <= 0;
        x2y0 <= 0;

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
        x5y0 <= x5 * y0;

        x4y1 <= x4 * y1;
        x4y0 <= x4 * y0;

        x3y3 <= x3 * y3;
        x3y2 <= x3 * y2;
        x3y1 <= x3 * y1;
        x3y0 <= x3 * y0;

        x2y4 <= x2 * y4;
        x2y3 <= x2 * y3;
        x2y2 <= x2 * y2;
        x2y1 <= x2 * y1;
        x2y0 <= x2 * y0;

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
        sum_s1_8    <=  x5y0 + x3y3 + x1y6;// << 120
    end
end

// pipe 2
reg [82 :0]  sum_s2_0;
reg [66 :0]  sum_s2_1;
reg [66 :0]  sum_s2_2;
reg [92 :0]  sum_s2_3;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_s2_0    <=  0;
        sum_s2_1    <=  0;
        sum_s2_2    <=  0;
        sum_s2_3    <=  0;
    end
    else begin
        sum_s2_0    <=  sum_s1_0  + (sum_s1_1  << 32);// << 0
        sum_s2_1    <=  sum_s1_2  + (sum_s1_3  << 16);// << 48
        sum_s2_2    <=  sum_s1_4  + (sum_s1_5  << 16);// << 80
        sum_s2_3    <=  sum_s1_6  + (sum_s1_7  << 16) + (sum_s1_8 << 24);// << 96
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
    end
end

// pipe 4
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        result <= 0;
    end
    else begin
        result <= sum_s3_0 + (sum_s3_1 << 80);
    end
end

endmodule