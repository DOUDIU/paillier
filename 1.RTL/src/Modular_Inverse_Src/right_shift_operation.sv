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
