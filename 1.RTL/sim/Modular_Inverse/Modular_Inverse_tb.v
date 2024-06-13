`timescale 1ns / 1ps

module Modular_Inverse_tb();

reg		clk		=	0	;
reg		rst_n	= 	0	;
always #5 clk = ~clk; 
initial #20 rst_n = 1;

reg		[255:0]		a;
reg		[255:0]		p;
reg					valid_in;

wire	[255:0]		R;
wire				valid_out;
wire				busy;


Modular_Inverse #(
		.Data_Width 	(256)
)Modular_Inverse_inst(
	 	.clk			(clk		)
	,	.rst_n			(rst_n		)
	,	.a				(a			)
	,	.p				(p			)
	,	.valid_in		(valid_in	)
	,	.R				(R			)
	,	.valid_out		(valid_out	)
	,	.busy			()
);


initial begin
	a = 256'h0;
	p = 256'h0;
	valid_in = 0;
	#100;
	valid_in = 1;
	a = 256'h123456;
	p = 256'hefee431;
	#10
	valid_in = 0;
	wait(valid_out);
	$display("R = %h",R);
	$stop;
end




















endmodule
