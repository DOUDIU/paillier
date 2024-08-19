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
module iddmm_mul_128_to_256(
        input               clk
    ,   input               rst_n

    ,   input   [127    :0] x
    ,   input   [127    :0] y
    ,   output  [255    :0] result
);

wire [15:0]x7 = x[127:112];
wire [15:0]x6 = x[111:96];
wire [15:0]x5 = x[95:80];
wire [15:0]x4 = x[79:64];
wire [15:0]x3 = x[63:48];
wire [15:0]x2 = x[47:32];
wire [15:0]x1 = x[31:16];
wire [15:0]x0 = x[15:0];

wire [15:0]y7 = y[127:112];
wire [15:0]y6 = y[111:96];
wire [15:0]y5 = y[95:80];
wire [15:0]y4 = y[79:64];
wire [15:0]y3 = y[63:48];
wire [15:0]y2 = y[47:32];
wire [15:0]y1 = y[31:16];
wire [15:0]y0 = y[15:0];

reg[31:0]x7y7, x7y6, x7y5, x7y4, x7y3, x7y2, x7y1, x7y0;
reg[31:0]x6y7, x6y6, x6y5, x6y4, x6y3, x6y2, x6y1, x6y0;
reg[31:0]x5y7, x5y6, x5y5, x5y4, x5y3, x5y2, x5y1, x5y0;
reg[31:0]x4y7, x4y6, x4y5, x4y4, x4y3, x4y2, x4y1, x4y0;
reg[31:0]x3y7, x3y6, x3y5, x3y4, x3y3, x3y2, x3y1, x3y0;
reg[31:0]x2y7, x2y6, x2y5, x2y4, x2y3, x2y2, x2y1, x2y0;
reg[31:0]x1y7, x1y6, x1y5, x1y4, x1y3, x1y2, x1y1, x1y0;
reg[31:0]x0y7, x0y6, x0y5, x0y4, x0y3, x0y2, x0y1, x0y0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x7y7 <= 0; 
        x7y6 <= 0;
        x7y5 <= 0;
        x7y4 <= 0;
        x7y3 <= 0;
        x7y2 <= 0;
        x7y1 <= 0;
        x7y0 <= 0;

        x6y7 <= 0;
        x6y6 <= 0;
        x6y5 <= 0;
        x6y4 <= 0;
        x6y3 <= 0;
        x6y2 <= 0;
        x6y1 <= 0;
        x6y0 <= 0;

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
        x7y7 <= x7 * y7; 
        x7y6 <= x7 * y6;
        x7y5 <= x7 * y5;
        x7y4 <= x7 * y4;
        x7y3 <= x7 * y3;
        x7y2 <= x7 * y2;
        x7y1 <= x7 * y1;
        x7y0 <= x7 * y0;

        x6y7 <= x6 * y7;
        x6y6 <= x6 * y6;
        x6y5 <= x6 * y5;
        x6y4 <= x6 * y4;
        x6y3 <= x6 * y3;
        x6y2 <= x6 * y2;
        x6y1 <= x6 * y1;
        x6y0 <= x6 * y0;

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

// 
// round 0
reg [255:0]sum077;
reg [255:0]sum076, sum075, sum074, sum073, sum072, sum071, sum070;
reg [255:0]sum066, sum065, sum064, sum063, sum062, sum061, sum060;
reg [255:0]sum055, sum054, sum053, sum052, sum051, sum050;
reg [255:0]sum044, sum043, sum042, sum041, sum040;
reg [255:0]sum033, sum032, sum031, sum030;
reg [255:0]sum022, sum021, sum020;
reg [255:0]sum011, sum010;
reg [255:0]sum000;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum077 <= 0;
        sum076 <= 0;
        sum075 <= 0;
        sum074 <= 0;
        sum073 <= 0;
        sum072 <= 0;
        sum071 <= 0;
        sum070 <= 0;
        sum066 <= 0;
        sum065 <= 0;
        sum064 <= 0;
        sum063 <= 0;
        sum062 <= 0;
        sum061 <= 0;
        sum060 <= 0;
        sum055 <= 0;
        sum054 <= 0;
        sum053 <= 0;
        sum052 <= 0;
        sum051 <= 0;
        sum050 <= 0;
        sum044 <= 0;
        sum043 <= 0;
        sum042 <= 0;
        sum041 <= 0;
        sum040 <= 0;
        sum033 <= 0;
        sum032 <= 0;
        sum031 <= 0;
        sum030 <= 0;
        sum022 <= 0;
        sum021 <= 0;
        sum020 <= 0;
        sum011 <= 0;
        sum010 <= 0;
        sum000 <= 0;
    end
    else begin
        sum077 <= x7y7;
        sum076 <= x7y6 + x6y7;
        sum075 <= x7y5 + x5y7;
        sum074 <= x7y4 + x4y7;
        sum073 <= x7y3 + x3y7;
        sum072 <= x7y2 + x2y7;
        sum071 <= x7y1 + x1y7;
        sum070 <= x7y0 + x0y7;
        sum066 <= x6y6;
        sum065 <= x6y5 + x5y6;
        sum064 <= x6y4 + x4y6;
        sum063 <= x6y3 + x3y6;
        sum062 <= x6y2 + x2y6;
        sum061 <= x6y1 + x1y6;
        sum060 <= x6y0 + x0y6;
        sum055 <= x5y5;
        sum054 <= x5y4 + x4y5;
        sum053 <= x5y3 + x3y5;
        sum052 <= x5y2 + x2y5;
        sum051 <= x5y1 + x1y5;
        sum050 <= x5y0 + x0y5;
        sum044 <= x4y4;
        sum043 <= x4y3 + x3y4;
        sum042 <= x4y2 + x2y4;
        sum041 <= x4y1 + x1y4;
        sum040 <= x4y0 + x0y4;
        sum033 <= x3y3;
        sum032 <= x3y2 + x2y3;
        sum031 <= x3y1 + x1y3;
        sum030 <= x3y0 + x0y3;
        sum022 <= x2y2;
        sum021 <= x2y1 + x1y2;
        sum020 <= x2y0 + x0y2;
        sum011 <= x1y1;
        sum010 <= x1y0 + x0y1;
        sum000 <= x0y0;
    end
end

// round1
reg[255:0] sum114_s, sum113_s, sum112,sum111;
reg[255:0] sum110_a, sum110_b;
reg[255:0] sum109_a, sum109_b;
reg[255:0] sum108_a, sum108_b;
reg[255:0] sum107_a, sum107_b;
reg[255:0] sum106_a, sum106_b;
reg[255:0] sum105_a, sum105_b;
reg[255:0] sum104_a, sum104_b;
reg[255:0] sum103, sum102, sum101_s, sum100_s;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum114_s <= 0;
        sum113_s <= 0;
        sum112   <= 0;
        sum111   <= 0;
        sum110_a <= 0;
        sum110_b <= 0;
        sum109_a <= 0;
        sum109_b <= 0;
        sum108_a <= 0;
        sum108_b <= 0;
        sum107_a <= 0;
        sum107_b <= 0;
        sum106_a <= 0;
        sum106_b <= 0;
        sum105_a <= 0;
        sum105_b <= 0;
        sum104_a <= 0;
        sum104_b <= 0;
        sum103   <= 0;
        sum102   <= 0;
        sum101_s <= 0;
        sum100_s <= 0;
    end
    else begin
        sum114_s <= sum077 << 224;
        sum113_s <= sum076 << 208;
        sum112 <= sum075 + sum066;
        sum111 <= sum074 + sum065;
        sum110_a <= sum073 + sum064;
        sum110_b <= sum055;
        sum109_a <= sum072 + sum063;
        sum109_b <= sum054;
        sum108_a <= sum071 + sum062;
        sum108_b <= sum053 + sum044;
        sum107_a <= sum070 + sum061;
        sum107_b <= sum052 + sum043;
        sum106_a <= sum060 + sum051;
        sum106_b <= sum042 + sum033;
        sum105_a <= sum050 + sum041;
        sum105_b <= sum032;
        sum104_a <= sum040 + sum031;
        sum104_b <= sum022;
        sum103 <= sum030 + sum021;
        sum102 <= sum020 + sum011;
        sum101_s <= sum010 << 16;
        sum100_s <= sum000;
    end
end

// round2
reg[255:0] sum2_1400;
reg[255:0] sum2_1301;
reg[255:0] sum210, sum209, sum208, sum207, sum206, sum205, sum204;
reg[255:0] sum212_s, sum211_s, sum203_s, sum202_s;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum210      <= 0;
        sum209      <= 0;
        sum208      <= 0;
        sum207      <= 0;
        sum206      <= 0;
        sum205      <= 0;
        sum204      <= 0;
        sum212_s    <= 0;
        sum211_s    <= 0;
        sum203_s    <= 0;
        sum202_s    <= 0;
        sum2_1301   <= 0;
        sum2_1400   <= 0;
    end
    else begin
        sum210 <= sum110_a + sum110_b;
        sum209 <= sum109_a + sum109_b;
        sum208 <= sum108_a + sum108_b;
        sum207 <= sum107_a + sum107_b;
        sum206 <= sum106_a + sum106_b;
        sum205 <= sum105_a + sum105_b;
        sum204 <= sum104_a + sum104_b;
        
        sum212_s <= sum112 << 192;
        sum211_s <= sum111 << 176;
        sum203_s <= sum103 << 48;
        sum202_s <= sum102 << 32;
        sum2_1301 <= sum113_s + sum101_s;
        sum2_1400 <= sum114_s + sum100_s;
    end
end

//round3
reg [255:0] sum310_s, sum309_s, sum308_s, sum307_s, sum306_s, sum305_s, sum304_s;
reg [255:0] sum3_1211, sum3_0302, sum3_1413;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum310_s    <= 0;
        sum309_s    <= 0;
        sum308_s    <= 0;
        sum307_s    <= 0;
        sum306_s    <= 0;
        sum305_s    <= 0;
        sum304_s    <= 0;
        sum3_1211   <= 0;
        sum3_0302   <= 0;
        sum3_1413   <= 0;
    end
    else begin
        sum310_s <= sum210 << 160;
        sum309_s <= sum209 << 144;
        sum308_s <= sum208 << 128;
        sum307_s <= sum207 << 112;
        sum306_s <= sum206 << 96;
        sum305_s <= sum205 << 80;
        sum304_s <= sum204 << 64;
        sum3_1211 <= sum212_s + sum211_s;
        sum3_0302 <= sum203_s + sum202_s;
        sum3_1413 <= sum2_1400 + sum2_1301;
    end
end

// round4
reg [255:0]sum4_0, sum4_1, sum4_2, sum4_3, sum4_4;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin        
        sum4_0 <= 0;
        sum4_1 <= 0;
        sum4_2 <= 0;
        sum4_3 <= 0;
        sum4_4 <= 0;
    end
    else begin
        sum4_0 <= sum310_s + sum309_s;
        sum4_1 <= sum308_s + sum307_s;
        sum4_2 <= sum306_s + sum305_s;
        sum4_3 <= sum304_s + sum3_1211;
        sum4_4 <= sum3_0302 + sum3_1413;
    end
end

//round5
reg [255:0]sum5_0, sum5_1, sum5_2;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum5_0 <= 0;
        sum5_1 <= 0;
        sum5_2 <= 0;
    end
    else begin
        sum5_0 <= sum4_0 + sum4_1;
        sum5_1 <= sum4_2 + sum4_3;
        sum5_2 <= sum4_4;
    end
end

// round 6
reg [255:0]sum6_0, sum6_1;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum6_0 <= 0;
        sum6_1 <= 0;
    end
    else begin
        sum6_0 <= sum5_0 + sum5_1;
        sum6_1 <= sum5_2;
    end
end

//round 7 8
wire _,__;
reg [257:0] sum7;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum7 <= 0;
    end
    else begin
        sum7 <= sum6_0 + sum6_1;
    end
end

assign result = sum7;

// simple_p12adder256_3_2 #(
//     .STAGE              ( 2                 )
// )simple_p12adder256_3_2(
//     .clk                ( clk               ),
//     .ain                ( sum6_0            ),//256
//     .bin                ( sum6_1            ),//256
//     .final_fa_cout_i    ( 1'd0              ),
//     .full_sum           ( {_,__,carry,ret}  ) //258
// );


endmodule