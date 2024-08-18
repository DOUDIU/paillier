
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

reg     [K-1:0]                 m1;

always@(posedge clk)begin 
    if (wr_ena) begin 
        m1<=wr_m1; 
    end 
    else begin 
        m1<=m1;
    end 
end

























simple_ram#(
        .width              ( K                 )
    ,   .widthad            ( ADDR_W + 1        )//0-63,0-32 will be used
)simple_ram_x(//caution:>>>>> addr32 must be 0 <<<<<
        .clk                ( clk               )
    ,   .wraddress          ( {1'd0,wr_addr}    )//0-31
    ,   .wren               ( wr_ena[0]         )
    ,   .data               ( wr_x              )
    ,   .rdaddress          ()//0-32 will be read out
    ,   .q                  ()
);
simple_ram#(
        .width              ( K                 )
    ,   .widthad            ( ADDR_W            )
)simple_ram_y(
        .clk                ( clk               )
    ,   .wraddress          ( wr_addr           )
    ,   .wren               ( wr_ena[1]         )
    ,   .data               ( wr_y              )
    ,   .rdaddress          ()
    ,   .q                  ()
);
simple_ram#(
        .width              ( K                 )
    ,   .widthad            ( ADDR_W            )
)simple_ram_m(
        .clk                ( clk               )
    ,   .wraddress          ( wr_addr           )
    ,   .wren               ( wr_ena[2]         )
    ,   .data               ( wr_m              )
    ,   .rdaddress          ()
    ,   .q                  ()
);
simple_ram#(
        .width              ( K                 )
    ,   .widthad            ( ADDR_W            )
)simple_ram_a(//a(0)~a(n-1)
        .clk                ( clk               )
    ,   .wraddress          ()
    ,   .wren               ()
    ,   .data               ()
    ,   .rdaddress          ()
    ,   .q                  ()
);



endmodule