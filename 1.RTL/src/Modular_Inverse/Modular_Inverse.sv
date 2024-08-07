`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 15:29:41
// Design Name: 
// Module Name: Modular_Inverse
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
//return  r = a^-1 mod p
module modular_inverse_optimize#(
		parameter	K 	= 	128
	,	parameter	N 	= 	32
)(
		input					clk
	,	input					rst_n
	,	input					mi_start
	,	input	[ K - 1 : 0]	a
	,	input	[ K - 1 : 0]	p
	,	input					valid_in
	,	output	[ K - 1 : 0]	r
	,	output					valid_out
);
localparam	ADDR_W	=	$clog2(N);

localparam		STA_IDLE 		=	0,
				STA_STORAGE		=	1,
				STA_SHIFT 		=	2,
				STA_INITIAL 	=	3,
				STA_LOOP_STEP1	=	4,
				STA_LOOP_STEP2	=	5,
				STA_END			=	6;
reg 	[3			:	0]		state_now			;
reg		[3			:	0]		state_next			;

reg		[K-1		:	0]		x_low_128			;
reg		[K-1		:	0]		y_low_128			;
reg		[K-1		:	0]		C_low_128			;
reg		[K-1		:	0]		D_low_128			;


reg		[ADDR_W - 1	:	0]		wr_cnt				;
reg								shift_x_y_en		;
reg		[ADDR_W - 1	:	0]		ram_addr_x			;
wire	[K - 1 		: 	0]		ram_data_x			;
reg		[ADDR_W - 1	:	0]		ram_addr_y			;
wire 	[K - 1 		: 	0]		ram_data_y			;

reg								shift_req_x			;
wire							shift_x_end			;
reg								shift_req_y			;
wire							shift_y_end			;

wire							shift0_start		;
wire							shift0_end			;
reg		[ADDR_W - 1	:	0]		shift0_rd_addr		;
reg		[K - 1 		: 	0]		shift0_rd_data		;
reg		[ADDR_W - 1	:	0]		shift0_wr_addr		;
reg		[K - 1 		: 	0]		shift0_wr_data		;
reg								shift0_wr_en		;

wire							shift1_start		;
wire							shift1_end			;
reg		[ADDR_W - 1	:	0]		shift1_rd_addr		;
reg		[K - 1 		: 	0]		shift1_rd_data		;
reg		[ADDR_W - 1	:	0]		shift1_wr_addr		;
reg		[K - 1 		: 	0]		shift1_wr_data		;
reg								shift1_wr_en		;

reg		[ADDR_W - 1	:	0]		wr_addr_u			;
reg								wr_en_u				;
reg		[K - 1 		: 	0]		wr_data_u			;
reg		[ADDR_W - 1	:	0]		rd_addr_u			;
reg		[K - 1 		: 	0]		rd_data_u			;

reg		[ADDR_W - 1	:	0]		wr_addr_v			;
reg								wr_en_v				;
reg		[K - 1 		: 	0]		wr_data_v			;
reg		[ADDR_W - 1	:	0]		rd_addr_v			;
reg		[K - 1 		: 	0]		rd_data_v			;

reg		[ADDR_W - 1	:	0]		wr_addr_A			;
reg								wr_en_A				;
reg		[K - 1 		: 	0]		wr_data_A			;
reg		[ADDR_W - 1	:	0]		rd_addr_A			;
reg		[K - 1 		: 	0]		rd_data_A			;

reg		[ADDR_W - 1	:	0]		wr_addr_B			;
reg								wr_en_B				;
reg		[K - 1 		: 	0]		wr_data_B			;
reg		[ADDR_W - 1	:	0]		rd_addr_B			;
reg		[K - 1 		: 	0]		rd_data_B			;

reg		[ADDR_W - 1	:	0]		wr_addr_C			;
reg								wr_en_C				;
reg		[K - 1 		: 	0]		wr_data_C			;
reg		[ADDR_W - 1	:	0]		rd_addr_C			;
reg		[K - 1 		: 	0]		rd_data_C			;

reg		[ADDR_W - 1	:	0]		wr_addr_D			;
reg								wr_en_D				;
reg		[K - 1 		: 	0]		wr_data_D			;
reg		[ADDR_W - 1	:	0]		rd_addr_D			;
reg		[K - 1 		: 	0]		rd_data_D			;

reg		[K - 1 		: 	0]		result_data			;
reg								result_valid		;

assign		shift0_start	=	shift_req_x			;
assign		shift_x_end		=	shift0_end			;
assign		shift1_start	=	shift_req_y			;
assign		shift_y_end		=	shift1_end			;

assign		r				=	result_data			;
assign		valid_out		=	result_valid		;




always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state_now	<=	STA_IDLE;
	end
	else begin
		state_now	<=	state_next;
	end
end

always@(*) begin
	state_next	=	STA_IDLE;
	case(state_now)
		STA_IDLE:begin
			if(mi_start) begin
				state_next	=	STA_STORAGE;
			end
			else begin
				state_next	=	STA_IDLE;
			end
		end
		STA_STORAGE:begin
			if(wr_cnt == N-1) begin
				state_next	=	STA_SHIFT;
			end
			else begin
				state_next	=	STA_STORAGE;
			end
		end
		STA_SHIFT:begin
			if(x_low_128[0] | y_low_128[0]) begin
				state_next	=	STA_INITIAL;
			end
			else begin
				state_next	=	STA_SHIFT;
			end
		end
		STA_INITIAL:begin
			if(wr_cnt == N-1) begin
				state_next	=	STA_LOOP_STEP1;
			end
			else begin
				state_next	=	STA_INITIAL;
			end
		end
		STA_LOOP_STEP1:begin
			// state_next	=	STA_LOOP_STEP2;
		end
		STA_LOOP_STEP2:begin
			// if(u!=0) begin
			// 	state_next	=	STA_LOOP_STEP1;
			// end
			// else begin
			// 	state_next	=	STA_END;
			// end
		end
		STA_END:begin
			// if(wr_cnt == N-1) begin
			// 	state_next	=	STA_IDLE;
			// end
			// else begin
			// 	state_next	=	STA_END;
			// end
		end
		default: begin 
			state_next	=	STA_IDLE;
		end
	endcase
end



always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		shift_req_x		<=	0;
		shift_req_y		<=	0;

		x_low_128		<=	0;
		y_low_128		<=	0;
		
		shift_x_y_en	<=	0;
		ram_addr_x		<=	0;
		ram_addr_y		<=	0;

		wr_addr_A		<=	0;
		wr_en_A			<=	0;
		wr_data_A		<=	0;
		rd_addr_A		<=	0;
		rd_data_A		<=	0;

		wr_addr_B		<=	0;
		wr_en_B			<=	0;
		wr_data_B		<=	0;
		rd_addr_B		<=	0;
		rd_data_B		<=	0;

		wr_addr_C		<=	0;
		wr_en_C			<=	0;
		wr_data_C		<=	0;
		rd_addr_C		<=	0;
		rd_data_C		<=	0;

		wr_addr_D		<=	0;
		wr_en_D			<=	0;
		wr_data_D		<=	0;
		rd_addr_D		<=	0;
		rd_data_D		<=	0;
		
		result_data		<=	0;
		result_valid	<=	0;
	end
	else begin
		case(state_now)
			STA_IDLE:begin
				wr_cnt	<=	0;
			end
			STA_STORAGE:begin
				if(valid_in) begin
					wr_cnt			<=	wr_cnt + 1;
					x_low_128		<=	wr_cnt == 0 ? a : x_low_128;
					y_low_128		<=	wr_cnt == 0 ? p : y_low_128;
				end
				if(state_next == STA_SHIFT) begin
					shift_req_x		<=	1;
					shift_req_y		<=	1;
				end
			end
			STA_SHIFT:begin
				if(!(x_low_128[0] | y_low_128[0]) & shift_x_end) begin
					shift_req_x		<=	1;
					shift_req_y		<=	1;
				end
				else begin
					shift_req_x		<=	0;
					shift_req_y		<=	0;
				end
				x_low_128		<=	(shift0_wr_en & (shift0_wr_addr == 0)) ? shift0_wr_data : x_low_128;
				y_low_128		<=	(shift1_wr_en & (shift1_wr_addr == 0)) ? shift1_wr_data : y_low_128;
				if(state_next == STA_INITIAL) begin
					shift_x_y_en	<=	1;
					ram_addr_x		<=	ram_addr_x + 1;
					ram_addr_y		<=	ram_addr_y + 1;
				end
			end
			STA_INITIAL:begin
				wr_cnt		<=		wr_cnt + 1;
				if(!x_low_128[0]) begin
					wr_addr_u		<=	wr_cnt;
					wr_en_u			<=	1;
					wr_data_u		<=	ram_data_y;

					wr_addr_v		<=	wr_cnt;
					wr_en_v			<=	1;
					wr_data_v		<=	ram_data_x;

					wr_addr_B		<=	0;
					wr_en_B			<=	1;
					wr_data_B		<=	1;

					wr_addr_C		<=	0;
					wr_en_C			<=	1;
					wr_data_C		<=	1;
				end
				else begin
					wr_addr_u		<=	wr_cnt;
					wr_en_u			<=	1;
					wr_data_u		<=	ram_data_x;

					wr_addr_v		<=	wr_cnt;
					wr_en_v			<=	1;
					wr_data_v		<=	ram_data_y;

					wr_addr_A		<=	0;
					wr_en_A			<=	1;
					wr_data_A		<=	1;

					wr_addr_D		<=	0;
					wr_en_D			<=	1;
					wr_data_D		<=	1;
				end
				if(state_next == STA_LOOP_STEP1) begin
					wr_addr_u		<=	0;
					wr_en_u			<=	0;
					wr_data_u		<=	0;
					wr_addr_v		<=	0;
					wr_en_v			<=	0;
					wr_data_v		<=	0;
					wr_addr_A		<=	0;
					wr_en_A			<=	0;
					wr_data_A		<=	0;
					wr_addr_D		<=	0;
					wr_en_D			<=	0;
					wr_data_D		<=	0;
				end
			end
			STA_LOOP_STEP1:begin
			end
			STA_LOOP_STEP2:begin
			end
			STA_END: begin
			end
			default:begin
			end
		endcase
	end
end

simple_ram#(
        .width              (K     										)
    ,   .widthad            (ADDR_W										)
)simple_ram_x(
        .clk                (clk										)
    ,   .wraddress          (valid_in 	  ? wr_cnt	   : shift0_wr_addr	)
    ,   .wren               (valid_in 	  ? valid_in   : shift0_wr_en	)
    ,   .data               (valid_in 	  ? a	 	   : shift0_wr_data	)
    ,   .rdaddress          (shift_x_y_en ? ram_addr_x : shift0_rd_addr )
    ,   .q                  (shift_x_y_en ? ram_data_x : shift0_rd_data )
);

simple_ram#(
        .width              (K     										)
    ,   .widthad            (ADDR_W										)
)simple_ram_y(		
        .clk                (clk										)
    ,   .wraddress          (valid_in     ? wr_cnt	   : shift1_wr_addr	)
    ,   .wren               (valid_in     ? valid_in   : shift1_wr_en	)
    ,   .data               (valid_in     ? p	 	   : shift1_wr_data	)
    ,   .rdaddress          (shift_x_y_en ? ram_addr_x : shift1_rd_addr	)
    ,   .q                  (shift_x_y_en ? ram_data_x : shift1_rd_data	)
);

simple_ram#(
        .width              (K     				)
    ,   .widthad            (ADDR_W				)
)simple_ram_u(
        .clk                (clk				)
    ,   .wraddress          (wr_addr_u			)
    ,   .wren               (wr_en_u			)
    ,   .data               (wr_data_u			)
    ,   .rdaddress          (rd_addr_u			)
    ,   .q                  (rd_data_u			)
);

simple_ram#(
        .width              (K     				)
    ,   .widthad            (ADDR_W				)
)simple_ram_v(
        .clk                (clk				)
    ,   .wraddress          (wr_addr_v			)
    ,   .wren               (wr_en_v			)
    ,   .data               (wr_data_v			)
    ,   .rdaddress          (rd_addr_v			)
    ,   .q                  (rd_data_v			)
);

simple_ram#(
        .width              (K     				)
    ,   .widthad            (ADDR_W				)
)simple_ram_A(
        .clk                (clk				)
    ,   .wraddress          (wr_addr_A			)
    ,   .wren               (wr_en_A			)
    ,   .data               (wr_data_A			)
    ,   .rdaddress          (rd_addr_A			)
    ,   .q                  (rd_data_A			)
);

simple_ram#(
        .width              (K     				)
    ,   .widthad            (ADDR_W				)
)simple_ram_B(
        .clk                (clk				)
    ,   .wraddress          (wr_addr_B			)
    ,   .wren               (wr_en_B			)
    ,   .data               (wr_data_B			)
    ,   .rdaddress          (rd_addr_B			)
    ,   .q                  (rd_data_B			)
);

simple_ram#(
        .width              (K     				)
    ,   .widthad            (ADDR_W				)
)simple_ram_C(
        .clk                (clk				)
    ,   .wraddress          (wr_addr_C			)
    ,   .wren               (wr_en_C			)
    ,   .data               (wr_data_C			)
    ,   .rdaddress          (rd_addr_C			)
    ,   .q                  (rd_data_C			)
);

simple_ram#(
        .width              (K     				)
    ,   .widthad            (ADDR_W				)
)simple_ram_D(
        .clk                (clk				)
    ,   .wraddress          (wr_addr_D			)
    ,   .wren               (wr_en_D			)
    ,   .data               (wr_data_D			)
    ,   .rdaddress          (rd_addr_D			)
    ,   .q                  (rd_data_D			)
);


right_shift_operation#(
		.K 					(K					)
	,	.N 					(N					)
)right_shift_operation_inst0(
		.clk				(clk				)
	,	.rst_n				(rst_n				)
	,	.shift_start		(shift0_start		)
	,	.shift_end			(shift0_end			)
	,	.shift_rd_addr		(shift0_rd_addr		)
	,	.shift_rd_data		(shift0_rd_data		)
	,	.shift_wr_addr		(shift0_wr_addr		)
	,	.shift_wr_data		(shift0_wr_data		)
	,	.shift_wr_en		(shift0_wr_en		)
);

right_shift_operation#(
		.K 					(K					)
	,	.N 					(N					)
)right_shift_operation_inst1(
		.clk				(clk				)
	,	.rst_n				(rst_n				)
	,	.shift_start		(shift1_start		)
	,	.shift_end			(shift1_end			)
	,	.shift_rd_addr		(shift1_rd_addr		)
	,	.shift_rd_data		(shift1_rd_data		)
	,	.shift_wr_addr		(shift1_wr_addr		)
	,	.shift_wr_data		(shift1_wr_data		)
	,	.shift_wr_en		(shift1_wr_en		)
);


endmodule
*/



/*

	module Modular_Inverse#(
		parameter Data_Width = 4096
	)(
		input									clk,rst_n,
		input		[Data_Width - 1 : 0]		a,
		input		[Data_Width - 1 : 0]		p,
		input									valid_in,

		output	reg	[Data_Width - 1 : 0]		R,
		output	reg								valid_out,
		output	reg								busy
	);

	parameter   Init  		=	0,   																
				Work1 		=	1,
				Work2 		=	2,															
				Output		=	3;   															
		
		reg     [1 : 0]                 state_c,state_n;
		reg     [Data_Width - 1 : 0]    u, v, x, y;
		wire    [Data_Width     : 0]    u_v_reg, x_y_reg, x_pls_p_reg, y_pls_p_reg;

		assign    u_v_reg     = u - v	;
		assign    x_y_reg     = x - y	;
		assign    x_pls_p_reg = x + p	;
		assign    y_pls_p_reg = y + p	;

		always @(posedge clk ) begin
			if (!rst_n) begin
				state_c	<=	Init;
			end 
			else begin
				state_c	<=	state_n;
			end
		end

		always @(*) begin
			case (state_c)
				Init:
				begin
					if(valid_in)
						state_n	<=	Work1;
					else	
						state_n	<=	Init;
				end
				Work1:begin
					if((u != 'd1) && (v != 'd1))
						state_n	<=	Work2;
					else
						state_n	<=	Output;
				end
				Work2:
					state_n	<=	Work1;
				Output:
					state_n	<=	Init;
				default:state_n<=Init; 
			endcase
		end

		always @(posedge clk ) begin
			if(!rst_n) begin    													
				busy 	<= 1'b0 ;
				u 	   	<= 0	;
				v 	   	<= 0	;
				x 	   	<= 0 	;
				y 	   	<= 0 	;
				R   		<= 	0;	
				valid_out	<=	0;
			end 
			else begin
				if(valid_in)begin
					busy	<= 1'b1   ;
					u 	   	<= a    ;
					v 	   	<= p    ;
					x 	   	<= 256'd1 ;
					y 	   	<= 256'd0 ;
				end 
				case(state_c)
					Init:begin    										
	//					R   		<= 	0;	
						valid_out	<=	0;
					end 
					Work1:begin		
						busy	<= 	1;							
						if(u[0] == 1'b0) 
						begin
							u <= {1'b0,u[Data_Width - 1:1]};								
							x <= (x[0])? x_pls_p_reg[Data_Width:1] : {1'b0,x[Data_Width - 1:1]} ;
						end 
						if(v[0] == 1'd0) 
						begin
							v <= {1'b0,v[Data_Width - 1:1]};
							y <= (y[0])? y_pls_p_reg[Data_Width:1] : {1'b0,y[Data_Width - 1:1]} ;			
						end 
					end
					Work2:begin
						if((u[0])&&(v[0])) 
						begin
							if (u_v_reg[Data_Width]) 
							begin					
								v <= (v - u);
								y <= (x_y_reg[Data_Width])? (y - x):(y - x + p);					
							end 
							else 
							begin				
								u <= (u - v);
								x <= (x_y_reg[Data_Width])? (x - y + p):(x - y);				
							end
						end	
					end 
					Output:begin			
						R   		<= 	(u == 'd1)? x:y ;	
						busy 		<= 	0;
						valid_out	<=	1;	
					end
					default:;
				endcase
			end 
		end
					
	endmodule
*/
