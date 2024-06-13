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
