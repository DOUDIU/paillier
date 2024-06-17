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

reg		[K*N-1		:	0]		u, v, x, y, A, B, C, D;

reg 	[3			:	0]		state_now;
reg		[3			:	0]		state_next;

reg		[ADDR_W - 1	:	0]		wr_cnt;

reg		[K - 1 		: 	0]		result_data;
reg								result_valid;

assign	r			=			result_data;
assign	valid_out	=			result_valid;



reg								shift_req_v			;
reg								shift_req_C			;
reg								shift_req_D			;

reg								shift_start			;
reg								shift_end			;
reg		[ADDR_W - 1	:	0]		shift_rd_addr		;
reg		[K - 1 		: 	0]		shift_rd_data		;
reg		[ADDR_W - 1	:	0]		shift_wr_addr		;
reg		[K - 1 		: 	0]		shift_wr_data		;
reg								shift_wr_en			;




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
			if(x[0] | y[0]) begin
				state_next	=	STA_INITIAL;
			end
			else begin
				state_next	=	STA_SHIFT;
			end
		end
		STA_INITIAL:begin
			// state_next	=	STA_LOOP_STEP1;
			state_next	=	STA_IDLE;
		end
		STA_LOOP_STEP1:begin
			state_next	=	STA_LOOP_STEP2;
		end
		STA_LOOP_STEP2:begin
			if(u!=0) begin
				state_next	=	STA_LOOP_STEP1;
			end
			else begin
				state_next	=	STA_END;
			end
		end
		STA_END:begin
			if(wr_cnt == N-1) begin
				state_next	=	STA_IDLE;
			end
			else begin
				state_next	=	STA_END;
			end
		end
		default: begin 
			state_next	=	STA_IDLE;
		end
	endcase
end



always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		result_data		<=	0;
		result_valid	<=	0;
		u				<=	0;
		v				<=	0;
		x				<=	0;
		y				<=	0;
		A				<=	0;
		B				<=	0;
		C				<=	0;
		D				<=	0;
	end
	else begin
		case(state_now)
			STA_IDLE:begin
				wr_cnt	<=	0;
			end
			STA_STORAGE:begin
				if(valid_in) begin
					wr_cnt			<=	wr_cnt + 1;
					x[wr_cnt*K+:K]	<=	a;
					y[wr_cnt*K+:K]	<=	p;
				end
			end
			STA_SHIFT:begin
				if(!(x[0] | y[0])) begin
					x	<=	x >> 1;
					y	<=	y >> 1;
				end
			end
			STA_INITIAL:begin
				if(!x[0]) begin
					u	<=	y;
					v	<=	x;
					A	<=	0;
					B	<=	1;
					C	<=	1;
					D	<=	0;
				end
				else begin
					u	<=	x;
					v	<=	y;
					A	<=	1;
					B	<=	0;
					C	<=	0;
					D	<=	1;
				end
			end
			STA_LOOP_STEP1:begin
				if(!v[0]) begin
					v 	<=	v >> 1;
					if(!C[0] & !D[0]) begin
						C	<=	C >> 1;
						D	<=	D >> 1;
					end
					else begin
						C	<=	(C + y) >> 1;
						D	<=	(D - x) >> 1;
					end
				end
			end
			STA_LOOP_STEP2:begin
				if(u > v) begin
					u	<=	v;
					v 	<=	u - v;
					A 	<=	C;
					C 	<=	A - C;
					B	<=	D;
					D	<=	B - D;
				end
				else begin
					v	<=	v - u;
					C	<=	C - A;
					D	<=	D - B;
				end
			end
			STA_END: begin
				wr_cnt			<=	wr_cnt + 1;
				result_data		<=	A[wr_cnt*K+:K];
				result_valid	<=	1;
			end
			default:begin
			end
		endcase
	end
end

simple_ram#(
        .width              ( K                 )
    ,   .widthad            ( ADDR_W+1          )//0-63,0-32 will be used
)simple_ram_u(//caution:>>>>> addr32 must be 0 <<<<<
        .clk                (clk				)
    ,   .wraddress          (wr_cnt				)//0-31
    ,   .wren               (valid_in			)
    ,   .data               (a					)
    ,   .rdaddress          ()//0-32 will be read out
    ,   .q                  ()
);

simple_ram#(
        .width              ( K                 )
    ,   .widthad            ( ADDR_W+1          )//0-63,0-32 will be used
)simple_ram_v(//caution:>>>>> addr32 must be 0 <<<<<
        .clk                (clk				)
    ,   .wraddress          (wr_cnt				)//0-31
    ,   .wren               (valid_in			)
    ,   .data               (p					)
    ,   .rdaddress          ()//0-32 will be read out
    ,   .q                  ()
);



right_shift_operation#(
		.K 					(K				)
	,	.N 					(N				)
)right_shift_operation_inst(
		.clk				(clk			)
	,	.rst_n				(rst_n			)
	,	.shift_start		(shift_start	)
	,	.shift_end			(shift_end		)
	,	.shift_rd_addr		(shift_rd_addr	)
	,	.shift_rd_data		(shift_rd_data	)
	,	.shift_wr_addr		(shift_wr_addr	)
	,	.shift_wr_data		(shift_wr_data	)
	,	.shift_wr_en		(shift_wr_en	)
);





endmodule



module right_shift_operation#(
		parameter	K 		= 	128
	,	parameter	N 		= 	32
	,	parameter	ADDR_W	=	$clog2(N)
)(
		input					clk
	,	input					rst_n
	,	input					shift_start
	,	output	reg				shift_end
	,	output	[ADDR_W-1: 	0]	shift_rd_addr
	,	input	[K - 1 	: 	0]	shift_rd_data
	,	output	[ADDR_W-1: 	0]	shift_wr_addr
	,	output	[K - 1 	: 	0]	shift_wr_data
	,	output					shift_wr_en
);

localparam 	STA_IDLE	=	0,
			STA_START	=	1,
			STA_END		=	2;

reg		[3:0]			state_now;
reg		[3:0]			state_next;

reg						shift_keep		;
reg		[ADDR_W-1: 	0]	rd_addr			;
reg		[ADDR_W-1: 	0]	wr_addr			;
reg		[K - 1 	 :	0]	wr_data			;
reg						wr_en			;


assign		shift_rd_addr		=		rd_addr		;
assign		shift_wr_addr		=		wr_addr		;
assign		shift_wr_data		=		wr_data		;
assign		shift_wr_en			=		wr_en		;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state_now	<=	STA_IDLE;
	end
	else begin
		state_now	<=	state_next;
	end
end

always@(*) begin
	state_next		<=		STA_IDLE;
	case(state_now)
		STA_IDLE: begin
			if(shift_start) begin
				state_next		<=	STA_START;
			end
			else begin
				state_next		<=	STA_IDLE;
			end
		end
		STA_START: begin
			if(shift_wr_addr == N - 1) begin
				state_next		<=	STA_END;
			end
			else begin
				state_next		<=	STA_START;
			end
		end
		STA_END: begin
			state_next		<=		STA_IDLE;
		end
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		shift_keep	<=	0;
		rd_addr		<=	0;
		wr_addr		<=	0;
		wr_data		<=	0;
		wr_en		<=	0;
		shift_end	<=	0;
	end
	else begin
		case(state_now)
			STA_IDLE: begin
				shift_keep	<=	0;
				rd_addr		<=	N - 1;
				wr_addr		<=	0;
				wr_data		<=	0;
				wr_en		<=	0;
				shift_end	<=	0;
			end
			STA_START: begin
				rd_addr		<=	rd_addr - 1;
				shift_keep	<=	shift_rd_data[0];
				wr_addr		<=	rd_addr;
				wr_data		<=	{shift_keep,shift_rd_data[1+:K-1]};
				wr_en		<=	1;
			end
			STA_END: begin
				shift_end	<=	1;
				shift_keep	<=	0;
				rd_addr		<=	N - 1;
				wr_addr		<=	0;
				wr_data		<=	0;
				wr_en		<=	0;
			end
		endcase
	end
end


endmodule





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
