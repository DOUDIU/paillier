



module paillier_top#(
        parameter   n = 2048
    ,   parameter   p = 1024
    ,   parameter   q = 512
    ,   parameter   g = n + 1
    ,   parameter   u = 256
    ,   parameter   r = 32
)(

);
localparam  K = 2048;
localparam  ADDR_W = 11;





single_port_ram#(
        .WIDTH_DATA     ( 1         )  
    ,   .DEPTH          ( 0         )  
    ,   .FILENAME       ( "none"    )
)single_port_ram_n(
        .clk            ()
    ,   .wen            ()
    ,   .addr           ()
    ,   .wr_data        ()
    ,   .rd_data        ()
);




























endmodule