/*
X = x7x6x5x4x3x2x1
Y = y7y6y5y4y3y2y1
X*Y = (x7x6x5x4x3x2x1) * (y7y6y5y4y3y2y1)
    = ((x7 << 112) + (x6 << 96) + (x5 << 80) + (x4 << 64) + (x3 << 48) + (x2 << 32) + (x1 << 16) + x0)
        * ((y7 << 112) + (y6 << 96) + (y5 << 80) + (y4 << 64) + (y3 << 48) + (y2 << 32) + (y1 << 16) + y0)
    =  ((x7y7) << 224) 
     + ((x7y6 + x6y7) << 208) 
     + ((x7y5 + x6y6 + x5y7) << 192) 
     + ((x7y4 + x6y5 + x5y6 + x4y7) << 176)
     + ((x7y3 + x6y4 + x5y5 + x4y6 + x3y7) << 160)
     + ((x7y2 + x6y3 + x5y4 + x4y5 + x3y6 + x2y7) << 144)
     + ((x7y1 + x6y2 + x5y3 + x4y4 + x3y5 + x2y6 + x1y7) << 128)
     + ((x7y0 + x6y1 + x5y2 + x4y3 + x3y4 + x2y5 + x1y6+ x0y7) << 112)
     + ((x6y0 + x5y1 + x4y2 + x3y3 + x2y4 + x1y5 + x0y6) << 96)
     + ((x5y0 + x4y1 + x3y2 + x2y3 + x1y4 + x0y5) << 80)
     + ((x4y0 + x3y1 + x2y2 + x1y3 + x0y4) << 64)
     + ((x3y0 + x2y1 + x1y2 + x0y3) << 48)
     + ((x2y0 + x1y1 + x0y2) << 32)
     + ((x1y0 + x0y1) << 16)
     +x0y0
*/
module iddmm_mul_128_to_128(
        input               clk
    ,   input               rst_n

    ,   input   [127    :0] x
    ,   input   [127    :0] y
    ,   output  [127    :0] result
);

wire [15:0] x7 = x[127:112];
wire [15:0] x6 = x[111:96];
wire [15:0] x5 = x[95:80];
wire [15:0] x4 = x[79:64];
wire [15:0] x3 = x[63:48];
wire [15:0] x2 = x[47:32];
wire [15:0] x1 = x[31:16];
wire [15:0] x0 = x[15:0];

wire [15:0] y7 = y[127:112];
wire [15:0] y6 = y[111:96];
wire [15:0] y5 = y[95:80];
wire [15:0] y4 = y[79:64];
wire [15:0] y3 = y[63:48];
wire [15:0] y2 = y[47:32];
wire [15:0] y1 = y[31:16];
wire [15:0] y0 = y[15:0];

reg[31:0]   x7y0;
reg[31:0]   x6y1, x6y0;
reg[31:0]   x5y2, x5y1, x5y0;
reg[31:0]   x4y3, x4y2, x4y1, x4y0;
reg[31:0]   x3y4, x3y3, x3y2, x3y1, x3y0;
reg[31:0]   x2y5, x2y4, x2y3, x2y2, x2y1, x2y0;
reg[31:0]   x1y6, x1y5, x1y4, x1y3, x1y2, x1y1, x1y0;
reg[31:0]   x0y7, x0y6, x0y5, x0y4, x0y3, x0y2, x0y1, x0y0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x7y0 <= 0;
        x6y1 <= 0;
        x6y0 <= 0;
        x5y2 <= 0;
        x5y1 <= 0;
        x5y0 <= 0;
        x4y3 <= 0;
        x4y2 <= 0;
        x4y1 <= 0;
        x4y0 <= 0;
        x3y4 <= 0;
        x3y3 <= 0;
        x3y2 <= 0;
        x3y1 <= 0;
        x3y0 <= 0;
        x2y5 <= 0;
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
        x7y0 <= x7 * y0;

        x6y1 <= x6 * y1;
        x6y0 <= x6 * y0;

        x5y2 <= x5 * y2;
        x5y1 <= x5 * y1;
        x5y0 <= x5 * y0;

        x4y3 <= x4 * y3;
        x4y2 <= x4 * y2;
        x4y1 <= x4 * y1;
        x4y0 <= x4 * y0;

        x3y4 <= x3 * y4;
        x3y3 <= x3 * y3;
        x3y2 <= x3 * y2;
        x3y1 <= x3 * y1;
        x3y0 <= x3 * y0;

        x2y5 <= x2 * y5;
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

//  + ((x7y0 + x6y1 + x5y2 + x4y3 + x3y4 + x2y5 + x1y6+ x0y7) << 112)
//  + ((x6y0 + x5y1 + x4y2 + x3y3 + x2y4 + x1y5 + x0y6) << 96)
//  + ((x5y0 + x4y1 + x3y2 + x2y3 + x1y4 + x0y5) << 80)
//  + ((x4y0 + x3y1 + x2y2 + x1y3 + x0y4) << 64)
//  + ((x3y0 + x2y1 + x1y2 + x0y3) << 48)
//  + ((x2y0 + x1y1 + x0y2) << 32)
//  + ((x1y0 + x0y1) << 16)
//  + x0y0

// 
// round 0
reg [255:0] sum070;
reg [255:0] sum061, sum060;
reg [255:0] sum052, sum051, sum050;
reg [255:0] sum043, sum042, sum041, sum040;
reg [255:0] sum033, sum032, sum031, sum030;
reg [255:0] sum022, sum021, sum020;
reg [255:0] sum011, sum010;
reg [255:0] sum000;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum070 <= 0;
        sum061 <= 0;
        sum052 <= 0;
        sum043 <= 0;
        sum060 <= 0;
        sum051 <= 0;
        sum042 <= 0;
        sum033 <= 0;
        sum050 <= 0;
        sum041 <= 0;
        sum032 <= 0;
        sum040 <= 0;
        sum031 <= 0;
        sum022 <= 0;
        sum030 <= 0;
        sum021 <= 0;
        sum020 <= 0;
        sum011 <= 0;
        sum010 <= 0;
        sum000 <= 0;
    end
    else begin
        sum070 <= x7y0 + x0y7;
        sum061 <= x6y1 + x1y6;
        sum052 <= x5y2 + x2y5;
        sum043 <= x4y3 + x3y4;
        
        sum060 <= x6y0 + x0y6;
        sum051 <= x5y1 + x1y5;
        sum042 <= x4y2 + x2y4;
        sum033 <= x3y3;
        
        sum050 <= x5y0 + x0y5;
        sum041 <= x4y1 + x1y4;
        sum032 <= x3y2 + x2y3;

        sum040 <= x4y0 + x0y4;
        sum031 <= x3y1 + x1y3;
        sum022 <= x2y2;

        sum030 <= x3y0 + x0y3;
        sum021 <= x2y1 + x1y2;

        sum020 <= x2y0 + x0y2;
        sum011 <= x1y1;

        sum010 <= (x1y0 + x0y1) << 16;

        sum000 <= x0y0;
    end
end

// round1

reg [255:0] sum7_0,sum7_1;
reg [255:0] sum6_0,sum6_1;
reg [255:0] sum5_0,sum5_1;
reg [255:0] sum4_0,sum4_1;
reg [255:0] sum3_0;
reg [255:0] sum2_0;
reg [255:0] sum01;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum7_0 <= 0;
        sum7_1 <= 0;
        sum6_0 <= 0;
        sum6_1 <= 0;
        sum5_0 <= 0;
        sum5_1 <= 0;
        sum4_0 <= 0;
        sum4_1 <= 0;
        sum3_0 <= 0;
        sum2_0 <= 0;
        sum01  <= 0;
    end
    else begin
        sum7_0 <= sum070 + sum061;
        sum7_1 <= sum052 + sum043;

        sum6_0 <= sum060 + sum051;
        sum6_1 <= sum042 + sum033;

        sum5_0 <= sum050 + sum041;
        sum5_1 <= sum032;

        sum4_0 <= sum040 + sum031;
        sum4_1 <= sum022;

        sum3_0 <= (sum030 + sum021) << 48;
        
        sum2_0 <= (sum020 + sum011) << 32;

        sum01  <= sum000 + sum010;
    end
end

//round2
reg [255:0] sum7;
reg [255:0] sum6;
reg [255:0] sum5;
reg [255:0] sum4;
reg [255:0] sum321;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum7    <= 0;
        sum6    <= 0;
        sum5    <= 0;
        sum4    <= 0;
        sum321  <= 0;
    end
    else begin
        sum7    <= (sum7_0 + sum7_1) << 112;
        sum6    <= (sum6_0 + sum6_1) << 96;
        sum5    <= (sum5_0 + sum5_1) << 80;
        sum4    <= (sum4_0 + sum4_1) << 64;
        sum321  <= (sum3_0 + sum2_0 + sum01);
    end
end

//round3
reg [255:0] sum456;
reg [255:0] sum7321;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum456  <= 0;
        sum7321 <= 0;
    end
    else begin
        sum456  <= sum4 + sum5 + sum6;
        sum7321 <= sum7 + sum321;
    end
end

//round4
reg [255:0] sum01234567;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum01234567 <= 0;
    end
    else begin
        sum01234567 <= sum456 + sum7321;
    end
end

assign result = sum01234567;

endmodule