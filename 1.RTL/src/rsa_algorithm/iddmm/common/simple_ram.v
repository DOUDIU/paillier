/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 *   modify:helrori
 */
module simple_ram#(

    parameter width     = 1,
    parameter widthad   = 1,
    parameter deep      = 0,
    parameter filename  = "none"
)(
    input                       clk,
    
    input       [widthad-1:0]   wraddress,
    input                       wren,
    input       [width-1:0]     data,
    
    input       [widthad-1:0]   rdaddress,
    output reg  [width-1:0]     q
);
integer i;
localparam f=(deep==0)?(2**widthad):deep;
(* ram_style = "distributed" *) reg [width-1:0] mem [0:f-1];
// Xilinx feature,force LUT RAMs
// (* ram_style = "distributed" *) reg [width-1:0] mem [0:(2**widthad)-1];


initial begin
    if(filename == "none") begin
        for(i = 0; i < f; i = i + 1) begin
            mem[i]  <=  0;
        end
    end
    else begin
        $readmemh(filename,mem);
    end
end

always @(posedge clk) begin
    if(wren) begin
        mem[wraddress] <= data;
    end
end

always @(posedge clk) begin
    q <= mem[rdaddress];
end

endmodule
