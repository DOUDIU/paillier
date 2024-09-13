module iddmm_mul_tb();

reg                 clk         = 0 ;
reg                 rst_n       = 0 ;
reg     [127:0]     mul_x       = 0 ;
reg     [127:0]     mul_y       = 0 ;
wire    [255:0]     result          ;
wire    [127:0]     result_low128   ;

wire    [255:0]     result_confirm;

always #2 clk = ~clk;
initial #30 rst_n = 1;
assign result_confirm = (mul_x * mul_y);//&((1<<64) - 1);
integer i;

task test_128_to_256();
    @(posedge clk);
    @(posedge clk);

    mul_x   <= $random;
    mul_y   <= $random;
    //pending 9 clock cycle
    for(i = 0; i < 7; i = i + 1)begin
        @(posedge clk);
    end
    assert((result == result_confirm) && (result_low128 == result_confirm[127:0]))
        $display("Right:");
    else begin
        $display("Error: ");
        $display("result_confirm: %x",result_confirm);
        $display("result_output : %x",result);
        $display("result_output : %x",result_low128);
    end
endtask

initial begin
    wait(rst_n);
    for(i = 0; i < 100; i = i + 1)begin
        test_128_to_256();
    end
    $display("Finished");
    $stop;
end

iddmm_mul_128_to_256 iddmm_mul_128_to_256_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (mul_x          )
    ,   .y              (mul_y          )
    ,   .result         (result         )
);

iddmm_mul_128_to_128 iddmm_mul_128_to_128_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (mul_x          )
    ,   .y              (mul_y          )
    ,   .result         (result_low128  )
);

endmodule