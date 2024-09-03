module iddmm_mul_tb();

reg                 clk         = 0 ;
reg                 rst_n       = 0 ;
reg     [255:0]     mul_x       = 0 ;
reg     [255:0]     mul_y       = 0 ;
wire    [511:0]     result          ;

wire    [511:0]     result_confirm;

always #5 clk = ~clk;
initial #30 rst_n = 1;
assign result_confirm = (mul_x * mul_y);
integer i;

task test_256_to_512();
    @(posedge clk);
    @(posedge clk);

    for(i = 0; i < 256; i = i + 32) begin
        mul_x[i+:32]    <=  $random;
        mul_y[i+:32]    <=  $random;
    end
    for(i = 0; i < 10; i = i + 1)begin
        @(posedge clk);
    end
    assert(result == result_confirm)
        // $display("Right:");
    else begin
        $display("Error: ");
        $display("result_confirm: %x",result_confirm);
        $display("result_output : %x",result);
    end
endtask

initial begin
    wait(rst_n);
    for(i = 0; i < 100; i = i + 1)begin
        test_256_to_512();
    end
    $display("Finished");
    $stop;
end

iddmm_mul_256_to_512 iddmm_mul_256_to_512_inst(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )
    ,   .x              (mul_x          )
    ,   .y              (mul_y          )
    ,   .result         (result         )
);

endmodule