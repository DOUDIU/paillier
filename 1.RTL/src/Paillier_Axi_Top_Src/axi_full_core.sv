`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/07 13:57:50
// Design Name: 
// Module Name: fifo2axi-f
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


module axi_full_core#(
	 	parameter BLOCK_COUNT 	=	18
	,	parameter K 			=	128
	,	parameter N				=	32

	// Base address of targeted slave
	,   parameter  TARGET_RD_ADDR	= 0
	,   parameter  TARGET_WR_ADDR	= 0
)(
//----------------------------------------------------
// AXI-FULL master port
        input							M_AXI_ACLK
    ,   input							M_AXI_ARESETN
	,	tvip_axi_if         			AXI_FULL_IF

//----------------------------------------------------
// paillier control interface
	,	input 							paillier_start
	,	input 			[1	:0]			paillier_mode
	,	input 			[31	:0]			paillier_counts
	,	output	   						paillier_finished

//----------------------------------------------------
// paillier accelerator interface
    ,   output	reg		[1  :0]			task_cmd					[0 : BLOCK_COUNT - 1]
    ,   output	reg						task_req					[0 : BLOCK_COUNT - 1]
    ,   input							task_end					[0 : BLOCK_COUNT - 1]

    ,   output	reg		[K-1:0]			enc_m_data					[0 : BLOCK_COUNT - 1]
    ,   output	reg						enc_m_valid					[0 : BLOCK_COUNT - 1]
    ,   output	reg		[K-1:0]			enc_r_data					[0 : BLOCK_COUNT - 1]
    ,   output	reg		       			enc_r_valid					[0 : BLOCK_COUNT - 1]

    ,   output	reg		[K-1:0]			dec_c_data					[0 : BLOCK_COUNT - 1]
    ,   output	reg		       			dec_c_valid					[0 : BLOCK_COUNT - 1]

    ,   output	reg		[K-1:0]			homo_add_c1					[0 : BLOCK_COUNT - 1]
    ,   output	reg		       			homo_add_c1_valid			[0 : BLOCK_COUNT - 1]
    ,   output	reg		[K-1:0]			homo_add_c2					[0 : BLOCK_COUNT - 1]
    ,   output	reg		       			homo_add_c2_valid			[0 : BLOCK_COUNT - 1]

    ,   output	reg		[K-1:0]			scalar_mul_c1				[0 : BLOCK_COUNT - 1]
    ,   output	reg		       			scalar_mul_c1_valid			[0 : BLOCK_COUNT - 1]
    ,   output	reg		[K-1:0]			scalar_mul_const			[0 : BLOCK_COUNT - 1]
    ,   output	reg		       			scalar_mul_const_valid		[0 : BLOCK_COUNT - 1]

//----------------------------------------------------
// backward fifo read interface
    ,	output 	               			rd_rdy                  	[0 : BLOCK_COUNT - 1]
    ,	input			[K-1:0]       	rd_dout                 	[0 : BLOCK_COUNT - 1]
    ,	input			[$clog2(N):0] 	rd_cnt                  	[0 : BLOCK_COUNT - 1]
);
	import  tvip_axi_types_pkg::*;
	integer		i,j,k;
	genvar		o,p,q;

	typedef enum logic [1:0]{
		PAILLIER_ENCRYPTION         ,
		PAILLIER_DECRYPTION         ,
		PAILLIER_HOMOMORPHIC_ADD    ,
		PAILLIER_SCALAR_MUL         
	}PAILLIER_MODE;

	// Add user definition here
	reg		[31  						: 0]	loop_counter;
	reg											loop_end;

	reg		[BLOCK_COUNT - 1 			: 0]	block_is_busy;
	reg		[$clog2(BLOCK_COUNT) - 1 	: 0]	block_is_busy_next;
	reg		[`AXI_ADDR_WIDTH-1	 	 	: 0]	block_target_addr	[0:BLOCK_COUNT-1];
	reg 	[$clog2(BLOCK_COUNT) - 1 	: 0]	block_lowest_zero_bit;
	reg 										all_block_is_busy;

	wire 	[BLOCK_COUNT - 1 			: 0]	fifo_is_full;
	reg		[$clog2(BLOCK_COUNT) - 1 	: 0]	fifo_is_busy_next;
	reg 										all_fifo_is_empty;
	reg 	[$clog2(BLOCK_COUNT) - 1 	: 0]	fifo_lowest_zero_bit;

	reg		[1 							: 0]	single_task_read_cnt;

	reg											paillier_finished_reg;
	assign 	paillier_finished		=			paillier_finished_reg;

	always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
		if (M_AXI_ARESETN == 0) begin
			block_lowest_zero_bit 	<=	0;
			all_block_is_busy 		<= 	0;
		end
		else begin
			block_lowest_zero_bit 	<=	find_lowest_zero_bit(block_is_busy);
			all_block_is_busy 		<= 	&block_is_busy;
		end
	end

	generate
		for(o=0; o<BLOCK_COUNT; o=o+1) begin
			assign fifo_is_full[o] 	=	(rd_cnt[o] >= N - 1);
		end
	endgenerate
	always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
		if (M_AXI_ARESETN == 0) begin
			all_fifo_is_empty		<=	0;
			fifo_lowest_zero_bit 	<=	0;
		end
		else begin
			all_fifo_is_empty 		<=	&(~fifo_is_full);
			fifo_lowest_zero_bit 	<=	find_lowest_zero_bit(~fifo_is_full);
		end
	end

	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction                                                     

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	 localparam integer C_TRANSACTIONS_NUM = clogb2(`AXI_BURST_LEN-1);

	// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
	// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
	 localparam integer C_MASTER_LENGTH	= 12;
	// total number of burst transfers is master length divided by burst length and burst size
	 localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((`AXI_BURST_LEN*`AXI_DATA_WIDTH/8)-1);
	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.

	typedef enum logic [4:0] {
		IDLE_WAIT				,
		STA_ENCRYPTION			,
		STA_DECRYPTION			,
		STA_HOMOMORPHIC_ADD		,
		STA_SCALAR_MUL			,
		STA_ENCRYPTION_D1		,
		STA_ENCRYPTION_RD		,
		STA_ENCRYPTION_WR 		,
		STA_DECRYPTION_D1		,
		STA_DECRYPTION_RD		,
		STA_DECRYPTION_WR		,
		STA_HOMOMORPHIC_ADD_D1	,
		STA_HOMOMORPHIC_ADD_RD	,
		STA_HOMOMORPHIC_ADD_WR	,
		STA_SCALAR_MUL_D1		,
		STA_SCALAR_MUL_RD		,
		STA_SCALAR_MUL_WR		
	} FSM_STATE;

	FSM_STATE	state_now;
	FSM_STATE	state_next;

	// AXI4LITE signals
	//AXI4 internal temp signals
	wire [`AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	wire [`AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;
	reg  [`AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arvalid;
	reg  	axi_rready;
	//write beat count in a burst
	reg  [C_TRANSACTIONS_NUM : 0] 	write_index;
	//read beat count in a burst
	reg  [C_TRANSACTIONS_NUM : 0] 	read_index;
	//size of `AXI_BURST_LEN length burst in bytes
	wire [C_TRANSACTIONS_NUM+4 : 0] 	burst_size_bytes;
	//The burst counters are used to track the number of burst transfers of `AXI_BURST_LEN burst length needed to transfer 2^C_MASTER_LENGTH bytes of data.
	reg  [C_NO_BURSTS_REQ : 0] 	write_burst_counter;
	reg  [C_NO_BURSTS_REQ : 0] 	read_burst_counter;
	reg  	start_single_burst_write;
	reg  	start_single_burst_read;
	reg  	writes_done;
	reg  	reads_done;
	reg  	error_reg;
	reg  	read_mismatch;
	reg  	burst_write_active;
	reg  	burst_read_active;
	reg  [`AXI_DATA_WIDTH-1 : 0] 	expected_rdata;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	read_resp_error;
	wire  	wnext;
	wire  	rnext;
	reg  	init_txn_ff;
	reg  	init_txn_ff2;
	reg  	init_txn_edge;
	wire  	init_txn_pulse;


	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign AXI_FULL_IF.AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign AXI_FULL_IF.AXI_AWADDR	= TARGET_WR_ADDR + axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign AXI_FULL_IF.AXI_AWLEN	= `AXI_BURST_LEN - 1;
	//Size should be `AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign AXI_FULL_IF.AXI_AWSIZE	= clogb2((`AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign AXI_FULL_IF.AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign AXI_FULL_IF.AXI_AWCACHE	= 4'b0010;
	assign AXI_FULL_IF.AXI_AWPROT	= 3'h0;
	assign AXI_FULL_IF.AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign AXI_FULL_IF.AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign AXI_FULL_IF.AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign AXI_FULL_IF.AXI_WSTRB	= {(`AXI_DATA_WIDTH/8){1'b1}};
	assign AXI_FULL_IF.AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign AXI_FULL_IF.AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign AXI_FULL_IF.AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign AXI_FULL_IF.AXI_ARID	= 'b0;
	assign AXI_FULL_IF.AXI_ARADDR	= TARGET_RD_ADDR + axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign AXI_FULL_IF.AXI_ARLEN	= `AXI_BURST_LEN - 1;
	//Size should be `AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign AXI_FULL_IF.AXI_ARSIZE	= clogb2((`AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign AXI_FULL_IF.AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign AXI_FULL_IF.AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign AXI_FULL_IF.AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign AXI_FULL_IF.AXI_RREADY	= axi_rready;
	//Burst size in bytes
	assign burst_size_bytes	= `AXI_BURST_LEN * `AXI_DATA_WIDTH / 8;
	// assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;

	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and 
	// command information for the entire transaction.  It is a single beat
	// of information.

	// The AXI4 Write address channel in this example will continue to initiate
	// write commands as fast as it is allowed by the slave/interconnect.
	// The address will be incremented on each accepted address transaction,
	// by burst_size_byte to point to the next address. 

	always @(posedge M_AXI_ACLK) begin                                                                    
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                            
			axi_awvalid <= 1'b0;                                           
		end                                                              
	    // If previously not valid , start next transaction                
	    else if (~axi_awvalid && start_single_burst_write) begin                                                            
			axi_awvalid <= 1'b1;                                           
		end                                                              
	    /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid      
	    must wait until transaction is accepted */                         
	    else if (AXI_FULL_IF.AXI_AWREADY && axi_awvalid) begin                                                            
	        axi_awvalid <= 1'b0;                                           
		end                                                              
	    else begin                                                             
	      	axi_awvalid <= axi_awvalid;  
		end                                    
	end                                                                

	                                                                       
	// // Next address after AWREADY indicates previous address acceptance    
	// always @(posedge M_AXI_ACLK) begin                                                                
	// 	if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin                                                            
	// 		axi_awaddr <= 1'b0;                                             
	// 	end                                                              
	// 	else if (AXI_FULL_IF.AXI_AWREADY && axi_awvalid) begin
	// 		axi_awaddr	<=	block_target_addr[fifo_is_busy_next];
	// 	end                                                              
	// 	else begin                                                           
	// 		axi_awaddr <= axi_awaddr;
	// 	end                                        
	// end

	assign	axi_awaddr	=	axi_awvalid ? block_target_addr[fifo_is_busy_next] : 0;

	//--------------------
	//Write Data Channel
	//--------------------

	//The write data will continually try to push write data across the interface.

	//The amount of data accepted will depend on the AXI slave and the AXI
	//Interconnect settings, such as if there are FIFOs enabled in interconnect.

	//Note that there is no explicit timing relationship to the write address channel.
	//The write channel has its own throttling flag, separate from the AW channel.

	//Synchronization between the channels must be determined by the user.

	//The simpliest but lowest performance would be to only issue one address write
	//and write data burst at a time.

	//In this example they are kept in sync by using the same address increment
	//and burst sizes. Then the AW and W channels have their transactions measured
	//with threshold counters as part of the user logic, to make sure neither 
	//channel gets too far ahead of each other.

	//Forward movement occurs when the write channel is valid and ready

	assign wnext = AXI_FULL_IF.AXI_WREADY & axi_wvalid;                                   
	                                                                                    
	// WVALID logic, similar to the axi_awvalid always block above                      
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                                         
			axi_wvalid <= 1'b0;                                                         
		end                                                                           
		// If previously not valid, start next transaction                              
		//else if (~axi_wvalid && start_single_burst_write) begin                      
		else if (~axi_wvalid && AXI_FULL_IF.AXI_AWREADY && axi_awvalid) begin                                                                         
			axi_wvalid <= 1'b1;                                                         
		end                                                                           
		/* If WREADY and too many writes, throttle WVALID                               
		Once asserted, VALIDs cannot be deasserted, so WVALID                           
		must wait until burst is complete with WLAST */                                 
		else if (wnext && axi_wlast) begin                                                    
			axi_wvalid <= 1'b0;           
		end                                                
		else begin                                                                            
			axi_wvalid <= axi_wvalid;
		end                                                     
	end                                                                               


	//WLAST generation on the MSB of a counter underflow                                
	// WVALID logic, similar to the axi_awvalid always block above                      
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                                         
			axi_wlast <= 1'b0;                                                          
		end                                                                           
		// axi_wlast is asserted when the write index                                   
		// count reaches the penultimate count to synchronize                           
		// with the last write data when write_index is b1111                           
		// else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)  
		else if (((write_index == `AXI_BURST_LEN-2 && `AXI_BURST_LEN >= 2) && wnext) || (`AXI_BURST_LEN == 1 )) begin                                                                         
			axi_wlast <= 1'b1;                                                          
		end                                                                           
		// Deassrt axi_wlast when the last write data has been                          
		// accepted by the slave with a valid response                                  
		else if (wnext) begin                                                               
			axi_wlast <= 1'b0; 
		end                                                           
		else if (axi_wlast && `AXI_BURST_LEN == 1) begin                                 
			axi_wlast <= 1'b0;                             
		end                               
		else begin                                                                            
			axi_wlast <= axi_wlast;               
		end                                        
	end                                                                               


	/* Burst length counter. Uses extra counter register bit to indicate terminal       
	 count to reduce decode logic */                                                    
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 || start_single_burst_write == 1'b1) begin                                                                         
			write_index <= 0;                                                           
		end                                                                           
		else if (wnext && (write_index != `AXI_BURST_LEN-1)) begin                                                                         
			write_index <= write_index + 1;                                             
		end                                                                           
		else begin
			write_index <= write_index;
		end                                               
	end                                                                               


	/* Write Data Generator                                                             
	 Data pattern is only a simple incrementing count from 0 for each burst  */         
	// always @(posedge M_AXI_ACLK) begin
	// 	if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
	// 		for(i = 0; i < BLOCK_COUNT; i = i + 1) begin
	// 			rd_rdy[i] <= 0;
	// 		end
	// 	end
	// 	else if (wnext && axi_wlast) begin
	// 	 	rd_rdy[fifo_is_busy_next] <= 0;
	// 	end
	// 	else if (AXI_FULL_IF.AXI_AWREADY && axi_awvalid) begin
	// 		rd_rdy[fifo_is_busy_next] <= 1;
	// 	end
	// 	else if (wnext) begin         
	// 		rd_rdy[fifo_is_busy_next] <= 1;
	// 	end
	// 	else begin
	// 		rd_rdy[fifo_is_busy_next] <= 0;
	// 	end
	// end

	generate 
		for(o = 0; o < BLOCK_COUNT; o = o + 1) begin
			assign	rd_rdy[o]	=	(o == fifo_is_busy_next) ? wnext : 0; 
		end
	endgenerate
	assign axi_wdata = rd_dout[fifo_is_busy_next];

	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur when all of the data and the write address
	//has arrived and been accepted by the slave.

	//The write issuance (number of outstanding write addresses) is started by 
	//the Address Write transfer, and is completed by a BREADY/BRESP.

	//While negating BREADY will eventually throttle the AWREADY signal, 
	//it is best not to throttle the whole data channel this way.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error 
	//into the ERROR output. 

	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                             
			axi_bready <= 1'b0;                                             
		end                                                               
	    // accept/acknowledge bresp with axi_bready by the master           
	    // when AXI_FULL_IF.AXI_BVALID is asserted by slave                           
	    else if (AXI_FULL_IF.AXI_BVALID && ~axi_bready) begin                                                             
			axi_bready <= 1'b1;                                             
		end                                                               
	    // deassert after one clock cycle                                   
	    else if (axi_bready) begin                                                             
			axi_bready <= 1'b0;                                             
		end                                                               
	    // retain the previous value                                        
	    else begin                                                               
	      	axi_bready <= axi_bready;  
		end                                       
	end                                                                   
	                                                                        
	                                                                        
	//Flag any write response errors                                        
	assign write_resp_error = axi_bready & AXI_FULL_IF.AXI_BVALID & AXI_FULL_IF.AXI_BRESP[1]; 


	//----------------------------
	//Read Address Channel
	//----------------------------

	//The Read Address Channel (AW) provides a similar function to the
	//Write Address channel- to provide the tranfer qualifiers for the burst.

	//In this example, the read address increments in the same
	//manner as the write address channel.

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                          
			axi_arvalid <= 1'b0;                                         
		end                                                            
		// If previously not valid, start next transaction              
		else if (~axi_arvalid && start_single_burst_read) begin                                                          
			axi_arvalid <= 1'b1;                                         
		end                                                            
		else if (AXI_FULL_IF.AXI_ARREADY && axi_arvalid) begin                                                          
			axi_arvalid <= 1'b0;                                         
		end                                                            
		else begin                                                        
			axi_arvalid <= axi_arvalid;          
		end                          
	end                                                                


	// Next address after ARREADY indicates previous address acceptance  
	always @(posedge M_AXI_ACLK) begin
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
	        axi_araddr <= 'b0;
		end
		else if ((state_now == IDLE_WAIT) & paillier_start) begin
			axi_araddr	<=	'b0;
		end
	    else if (AXI_FULL_IF.AXI_ARREADY && axi_arvalid) begin
			case(state_now)
				STA_ENCRYPTION_RD: begin
					axi_araddr	<=	axi_araddr + (burst_size_bytes >> 1);//The function of ">>" is for encryption.
				end
				STA_DECRYPTION_RD: begin
					axi_araddr	<=	axi_araddr + burst_size_bytes;//The function of ">>" is for decryption.
				end
				STA_HOMOMORPHIC_ADD_RD: begin
					axi_araddr	<=	axi_araddr + burst_size_bytes;
				end
				STA_SCALAR_MUL_RD: begin
					axi_araddr	<=	single_task_read_cnt == 0 ? (axi_araddr + burst_size_bytes) : (axi_araddr + (burst_size_bytes >> 1));
				end
				default: begin
					axi_araddr	<=	axi_araddr + burst_size_bytes;
				end
			endcase
		end
	    else begin
	      	axi_araddr <= axi_araddr;
		end
	end


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	// Forward movement occurs when the channel is valid and ready   
	assign rnext = AXI_FULL_IF.AXI_RVALID && axi_rready;                            


	// Burst length counter. Uses extra counter register bit to indicate    
	// terminal count to reduce decode logic                                
	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 || start_single_burst_read) begin                                                             
			read_index <= 0;                                                
		end                                                               
	    else if (rnext && (read_index != `AXI_BURST_LEN-1)) begin                                                             
	     	read_index <= read_index + 1;                                   
		end                                                               
	    else begin                                                               
	      	read_index <= read_index;  
		end                                       
	end

	/*                                                                      
	 The Read Data channel returns the results of the read request          
	                                                                        
	 In this example the data checker is always able to accept              
	 more data, so no need to throttle the RREADY signal                    
	 */                                                                     
	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                             
			axi_rready <= 1'b0;                                             
		end                                                               
	    // accept/acknowledge rdata/rresp with axi_rready by the master     
	    // when AXI_FULL_IF.AXI_RVALID is asserted by slave                           
	    else if (AXI_FULL_IF.AXI_RVALID) begin                                      
			if (AXI_FULL_IF.AXI_RLAST && axi_rready) begin                                  
	            axi_rready <= 1'b0;                  
			end                                    
			else begin                                 
				axi_rready <= 1'b1;                 
			end                                   
		end
	    // retain the previous value                 
	end                                            
                                                                      
	//Flag any read response errors                                         
	assign read_resp_error = axi_rready & AXI_FULL_IF.AXI_RVALID & AXI_FULL_IF.AXI_RRESP[1];  


	//----------------------------------
	//Example design error register
	//----------------------------------

	//Register and hold any read/write interface errors

	always @(posedge M_AXI_ACLK) begin                                                              
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin                                                          
			error_reg <= 1'b0;                                           
		end                                                            
		else if (write_resp_error || read_resp_error) begin                                                          
			error_reg <= 1'b1;                                           
		end                                                            
		else begin                                                            
			error_reg <= error_reg;        
		end                                
	end                                                                


	//--------------------------------
	//Example design throttling
	//--------------------------------

	// For maximum port throughput, this user example code will try to allow
	// each channel to run as independently and as quickly as possible.

	// However, there are times when the flow of data needs to be throtted by
	// the user application. This example application requires that data is
	// not read before it is written and that the write channels do not
	// advance beyond an arbitrary threshold (say to prevent an 
	// overrun of the current read address by the write address).

	// From AXI4 Specification, 13.13.1: "If a master requires ordering between 
	// read and write transactions, it must ensure that a response is received 
	// for the previous transaction before issuing the next transaction."

	// This example accomplishes this user application throttling through:
	// -Reads wait for writes to fully complete
	// -Address writes wait when not read + issued transaction counts pass 
	// a parameterized threshold
	// -Writes wait when a not read + active data burst count pass 
	// a parameterized threshold

	// write_burst_counter counter keeps track with the number of burst transaction initiated            
	// against the number of burst transactions the master needs to initiate                                   
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin                                                                                                 
			write_burst_counter <= 'b0;                                                                         
		end                                                                                                   
		else if (AXI_FULL_IF.AXI_AWREADY && axi_awvalid) begin
			write_burst_counter <= write_burst_counter + 1'b1;
		end
		else if(writes_done)begin                                                                                                  
			write_burst_counter <= 0;         
		end                                                  
	end                                                                                                       

	// read_burst_counter counter keeps track with the number of burst transaction initiated                   
	// against the number of burst transactions the master needs to initiate                                   
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin                                                                                                 
			read_burst_counter <= 'b0;                                                                          
		end                                                                                                   
		else if (AXI_FULL_IF.AXI_ARREADY && axi_arvalid) begin                                    
			read_burst_counter <= read_burst_counter + 1'b1;
		end                                                                                                   
		else if(reads_done)begin                                                                                                  
			read_burst_counter <= 0;     
		end                                                        
	end

                                   
	always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
		if(!M_AXI_ARESETN) begin
			loop_end	<= 0;
		end
		else if(loop_counter == paillier_counts) begin
			loop_end	<= 1;
		end
		else begin
			loop_end	<= 0;
		end
	end

	//implement master command interface state machine

	always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
		if(!M_AXI_ARESETN) begin
			state_now 	<= IDLE_WAIT;
		end
		else begin
			state_now	<= state_next;
		end
	end

	always@(*) begin
		case (state_now)	
			IDLE_WAIT: begin
				// This state is responsible to wait for user defined C_M_START_COUNT                           
				// number of clock cycles.
				if (paillier_start) begin                 
					case (paillier_mode)                                                                               
						2'b00: 	 state_next	= STA_ENCRYPTION;
						2'b01: 	 state_next	= STA_DECRYPTION;
						2'b10: 	 state_next	= STA_HOMOMORPHIC_ADD;
						2'b11: 	 state_next	= STA_SCALAR_MUL;
						default: state_next	= IDLE_WAIT;
					endcase
				end                                                                                           
				else begin
					state_next	=	IDLE_WAIT;
				end
			end

			STA_ENCRYPTION: begin
				if ((!loop_end) & ((!all_block_is_busy) | (single_task_read_cnt != 0))) begin
					//switch when the loop counter is not equal to paillier_counts, meanwhile
					//all blocks is not busy or single read rask is not finished
					state_next	=	STA_ENCRYPTION_RD;
				end
				else if (!all_fifo_is_empty) begin
					state_next	=	STA_ENCRYPTION_WR;
				end
				else if ((loop_end) & (!block_is_busy)) begin
					//switch when all block is not busy and the loop counter is equal to paillier_counts
					state_next	=	IDLE_WAIT;
				end
				else begin
					state_next	=	STA_ENCRYPTION;
				end
			end
			STA_ENCRYPTION_D1: begin
				state_next	=	STA_ENCRYPTION;
			end
			STA_ENCRYPTION_RD: begin
				if (reads_done) begin
					state_next	=	STA_ENCRYPTION_D1;
				end
				else begin
					state_next	=	STA_ENCRYPTION_RD;
				end
			end
			STA_ENCRYPTION_WR: begin
				if (writes_done) begin
					state_next	=	STA_ENCRYPTION;
				end
				else begin
					state_next	=	STA_ENCRYPTION_WR;
				end
			end

			STA_DECRYPTION: begin
				if ((!loop_end) & (!all_block_is_busy)) begin
					//switch when the loop counter is not equal to paillier_counts, meanwhile
					//all blocks is not busy or single read rask is not finished
					state_next	=	STA_DECRYPTION_RD;
				end
				else if (!all_fifo_is_empty) begin
					state_next	=	STA_DECRYPTION_WR;
				end
				else if ((loop_end) & (!block_is_busy)) begin
					//switch when all block is not busy and the loop counter is equal to paillier_counts
					state_next	=	IDLE_WAIT;
				end
				else begin
					state_next	=	STA_DECRYPTION;
				end
			end
			STA_DECRYPTION_D1: begin
				state_next	=	STA_DECRYPTION;
			end
			STA_DECRYPTION_RD: begin
				if (reads_done) begin
					state_next	=	STA_DECRYPTION_D1;
				end
				else begin
					state_next	=	STA_DECRYPTION_RD;
				end
			end
			STA_DECRYPTION_WR: begin
				if (writes_done) begin
					state_next	=	STA_DECRYPTION;
				end
				else begin
					state_next	=	STA_DECRYPTION_WR;
				end
			end

			STA_HOMOMORPHIC_ADD: begin
				if ((!loop_end) & ((!all_block_is_busy) | (single_task_read_cnt != 0))) begin
					//switch when the loop counter is not equal to paillier_counts, meanwhile
					//all blocks is not busy or single read rask is not finished
					state_next	=	STA_HOMOMORPHIC_ADD_RD;
				end
				else if (!all_fifo_is_empty) begin
					state_next	=	STA_HOMOMORPHIC_ADD_WR;
				end
				else if ((loop_end) & (!block_is_busy)) begin
					//switch when all block is not busy and the loop counter is equal to paillier_counts
					state_next	=	IDLE_WAIT;
				end
				else begin
					state_next	=	STA_HOMOMORPHIC_ADD;
				end
			end
			STA_HOMOMORPHIC_ADD_D1: begin
				state_next	=	STA_HOMOMORPHIC_ADD;
			end
			STA_HOMOMORPHIC_ADD_RD: begin
				if (reads_done) begin
					state_next	=	STA_HOMOMORPHIC_ADD_D1;
				end
				else begin
					state_next	=	STA_HOMOMORPHIC_ADD_RD;
				end
			end
			STA_HOMOMORPHIC_ADD_WR: begin
				if (writes_done) begin
					state_next	=	STA_HOMOMORPHIC_ADD;
				end
				else begin
					state_next	=	STA_HOMOMORPHIC_ADD_WR;
				end
			end

			STA_SCALAR_MUL: begin
				if ((!loop_end) & ((!all_block_is_busy) | (single_task_read_cnt != 0))) begin
					//switch when the loop counter is not equal to paillier_counts, meanwhile
					//all blocks is not busy or single read rask is not finished
					state_next	=	STA_SCALAR_MUL_RD;
				end
				else if (!all_fifo_is_empty) begin
					state_next	=	STA_SCALAR_MUL_WR;
				end
				else if ((loop_end) & (!block_is_busy)) begin
					//switch when all block is not busy and the loop counter is equal to paillier_counts
					state_next	=	IDLE_WAIT;
				end
				else begin
					state_next	=	STA_SCALAR_MUL;
				end
			end
			STA_SCALAR_MUL_D1: begin
				state_next	=	STA_SCALAR_MUL;
			end
			STA_SCALAR_MUL_RD: begin
				if (reads_done) begin
					state_next	=	STA_SCALAR_MUL_D1;
				end
				else begin
					state_next	=	STA_SCALAR_MUL_RD;
				end
			end
			STA_SCALAR_MUL_WR: begin
				if (writes_done) begin
					state_next	=	STA_SCALAR_MUL;
				end
				else begin
					state_next	=	STA_SCALAR_MUL_WR;
				end
			end
			default: begin
				state_next	= IDLE_WAIT;
			end
		endcase
	end

	always@(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 1'b0 ) begin                                                                                                 
			// reset condition                                                                                  
			// All the signals are assigned default values under reset condition               
			start_single_burst_write <= 1'b0;                                                                   
			start_single_burst_read  <= 1'b0;

			loop_counter			<=	0;

			block_is_busy			<=	0;
			block_is_busy_next		<=	0;

			fifo_is_busy_next		<=	0;

			single_task_read_cnt	<=	0;
			paillier_finished_reg 	<=	0;
			for(j = 0; j < BLOCK_COUNT;	j = j + 1) begin
				task_req	[j]	<=	0;
				task_cmd	[j]	<=	0;
			end
			for(j = 0; j < BLOCK_COUNT;	j = j + 1) begin
				enc_m_data	[j]	<=	0;
				enc_m_valid	[j]	<=	0;
				enc_r_data	[j]	<=	0;
				enc_r_valid	[j]	<=	0;
			end
			for(j = 0; j < BLOCK_COUNT;	j = j + 1) begin
				dec_c_data			[j]	<=	0;
				dec_c_valid			[j]	<=	0;
			end
			for(j = 0; j < BLOCK_COUNT;	j = j + 1) begin
				homo_add_c1			[j]	<=	0;
				homo_add_c1_valid	[j]	<=	0;
				homo_add_c2			[j]	<=	0;
				homo_add_c2_valid	[j]	<=	0;
			end
			for(j = 0; j < BLOCK_COUNT;	j = j + 1) begin
				scalar_mul_c1			[j]	<=	0;
				scalar_mul_c1_valid		[j]	<=	0;
				scalar_mul_const		[j]	<=	0;
				scalar_mul_const_valid	[j]	<=	0;
			end
			for(j = 0; j < BLOCK_COUNT;	j = j + 1) begin
				block_target_addr[j]	<=	0;
			end
		end
		else begin
			// state transition                                                                                 
			case (state_now)
				IDLE_WAIT : begin
					loop_counter	<=	0;

					if(state_next != IDLE_WAIT) begin
						paillier_finished_reg	<=	0;
					end
				end

				STA_ENCRYPTION: begin
					if(state_next == STA_ENCRYPTION_RD) begin
						if(single_task_read_cnt == 0) begin
							task_cmd[block_lowest_zero_bit]					<=	PAILLIER_ENCRYPTION[1:0];
							task_req[block_lowest_zero_bit]					<=	1;
							block_is_busy_next 								<=	block_lowest_zero_bit;
						end
					end

					if(state_next == STA_ENCRYPTION_WR) begin
						fifo_is_busy_next	<=	fifo_lowest_zero_bit;//keep the current read fifo
					end

					if(state_next == IDLE_WAIT) begin
						paillier_finished_reg	<=	1;
					end
				end

				STA_ENCRYPTION_RD: begin
					task_cmd[block_lowest_zero_bit]			<=	0;
					task_req[block_lowest_zero_bit]			<=	0;
					block_target_addr[block_is_busy_next]	<=	loop_counter << 9;//target wr address = loop_counter * 4096 / 8
					if(AXI_FULL_IF.AXI_RVALID && axi_rready) begin
						enc_m_data	[block_is_busy_next]	<=	read_index < 16 ? (single_task_read_cnt ==	0 ?	AXI_FULL_IF.AXI_RDATA : 0) : 0;//The code "read_index < 16?" is employed to extend the valid signal to 32 cycles.
						enc_m_valid	[block_is_busy_next]	<=	single_task_read_cnt ==	0 ?	1 : 0;
						enc_r_data	[block_is_busy_next]	<=	read_index < 16 ? (single_task_read_cnt !=	0 ?	AXI_FULL_IF.AXI_RDATA : 0) : 0;//The code "read_index < 16?" is employed to extend the valid signal to 32 cycles.
						enc_r_valid	[block_is_busy_next]	<=	single_task_read_cnt !=	0 ?	1 : 0;
					end
					else begin
						enc_m_data	[block_is_busy_next]	<=	0;
						enc_m_valid	[block_is_busy_next]	<=	0;
						enc_r_data	[block_is_busy_next]	<=	0;
						enc_r_valid	[block_is_busy_next]	<=	0;
					end
					if(!reads_done) begin
						if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin
							start_single_burst_read <= 1'b1;
						end
						else begin
							start_single_burst_read <= 1'b0; //Negate to generate a pulse
						end
					end
					if(reads_done) begin
						loop_counter			<=	loop_counter + (single_task_read_cnt == 1);// Carry after the last data is read.
						single_task_read_cnt	<=	single_task_read_cnt < 1  ? single_task_read_cnt + 1 : 0;
						block_is_busy 			<= 	block_is_busy | (1 << block_is_busy_next);
					end
				end

				STA_ENCRYPTION_WR: begin
					if (!writes_done) begin
						if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active) begin
							start_single_burst_write <= 1'b1;
						end
						else begin
							start_single_burst_write <= 1'b0; //Negate to generate a pulse
						end
					end
					if(writes_done) begin
						block_is_busy	<= 	block_is_busy & (~(1 << fifo_is_busy_next));
					end
				end

				STA_DECRYPTION: begin
					if(state_next == STA_DECRYPTION_RD) begin
						task_cmd[block_lowest_zero_bit]					<=	PAILLIER_DECRYPTION;
						task_req[block_lowest_zero_bit]					<=	1;
						block_is_busy_next 								<=	block_lowest_zero_bit;
					end

					if(state_next == STA_DECRYPTION_WR) begin
						fifo_is_busy_next	<=	fifo_lowest_zero_bit;//keep the current read fifo
					end

					if(state_next == IDLE_WAIT) begin
						paillier_finished_reg	<=	1;
					end
				end

				STA_DECRYPTION_RD: begin
					task_cmd[block_lowest_zero_bit]			<=	0;
					task_req[block_lowest_zero_bit]			<=	0;
					block_target_addr[block_is_busy_next]	<=	loop_counter << 8;//target wr address = loop_counter * 2048 / 8
					if(AXI_FULL_IF.AXI_RVALID && axi_rready) begin
						dec_c_data	[block_is_busy_next]	<=	AXI_FULL_IF.AXI_RDATA;
						dec_c_valid	[block_is_busy_next]	<=	1;
					end
					else begin
						dec_c_data	[block_is_busy_next]	<=	0;
						dec_c_valid	[block_is_busy_next]	<=	0;
					end
					if(!reads_done) begin
						if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin
							start_single_burst_read <= 1'b1;
						end
						else begin
							start_single_burst_read <= 1'b0; //Negate to generate a pulse
						end
					end
					if(reads_done) begin
						loop_counter			<=	loop_counter + 1;
						block_is_busy 			<= 	block_is_busy | (1 << block_is_busy_next);
					end
				end

				STA_DECRYPTION_WR: begin
					if (!writes_done) begin
						if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active) begin
							start_single_burst_write <= 1'b1;
						end
						else begin
							start_single_burst_write <= 1'b0; //Negate to generate a pulse
						end
					end
					if(writes_done) begin
						block_is_busy	<= 	block_is_busy & (~(1 << fifo_is_busy_next));
					end
				end

				STA_HOMOMORPHIC_ADD: begin
					if(state_next == STA_HOMOMORPHIC_ADD_RD) begin
						if(single_task_read_cnt == 0) begin
							task_cmd[block_lowest_zero_bit]					<=	PAILLIER_HOMOMORPHIC_ADD;
							task_req[block_lowest_zero_bit]					<=	1;
							block_is_busy_next 								<=	block_lowest_zero_bit;
						end
					end

					if(state_next == STA_HOMOMORPHIC_ADD_WR) begin
						fifo_is_busy_next	<=	fifo_lowest_zero_bit;//keep the current read fifo
					end

					if(state_next == IDLE_WAIT) begin
						paillier_finished_reg	<=	1;
					end
				end

				STA_HOMOMORPHIC_ADD_RD: begin
					task_cmd[block_lowest_zero_bit]			<=	0;
					task_req[block_lowest_zero_bit]			<=	0;
					block_target_addr[block_is_busy_next]	<=	loop_counter << 9;//target wr address = loop_counter * 4096 / 8
					if(AXI_FULL_IF.AXI_RVALID && axi_rready) begin
						homo_add_c1			[block_is_busy_next]	<=	single_task_read_cnt !=	0 ?	AXI_FULL_IF.AXI_RDATA : 0;
						homo_add_c1_valid	[block_is_busy_next]	<=	single_task_read_cnt !=	0 ?	1 : 0;
						homo_add_c2			[block_is_busy_next]	<=	single_task_read_cnt ==	0 ?	AXI_FULL_IF.AXI_RDATA : 0;
						homo_add_c2_valid	[block_is_busy_next]	<=	single_task_read_cnt ==	0 ?	1 : 0;
					end
					else begin
						homo_add_c1			[block_is_busy_next]	<=	0;
						homo_add_c1_valid	[block_is_busy_next]	<=	0;
						homo_add_c2			[block_is_busy_next]	<=	0;
						homo_add_c2_valid	[block_is_busy_next]	<=	0;
					end
					if(!reads_done) begin
						if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin
							start_single_burst_read <= 1'b1;
						end
						else begin
							start_single_burst_read <= 1'b0; //Negate to generate a pulse
						end
					end
					if(reads_done) begin
						loop_counter			<=	loop_counter + (single_task_read_cnt == 1);// Carry after the last data is read.
						single_task_read_cnt	<=	single_task_read_cnt < 1  ? single_task_read_cnt + 1 : 0;
						block_is_busy 			<= 	block_is_busy | (1 << block_is_busy_next);
					end
				end

				STA_HOMOMORPHIC_ADD_WR: begin
					if (!writes_done) begin
						if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active) begin
							start_single_burst_write <= 1'b1;
						end
						else begin
							start_single_burst_write <= 1'b0; //Negate to generate a pulse
						end
					end
					if(writes_done) begin
						block_is_busy	<= 	block_is_busy & (~(1 << fifo_is_busy_next));
					end
				end

				STA_SCALAR_MUL: begin
					if(state_next == STA_SCALAR_MUL_RD) begin
						if(single_task_read_cnt == 0) begin
							task_cmd[block_lowest_zero_bit]					<=	PAILLIER_SCALAR_MUL;
							task_req[block_lowest_zero_bit]					<=	1;
							block_is_busy_next 								<=	block_lowest_zero_bit;
						end
					end

					if(state_next == STA_SCALAR_MUL_WR) begin
						fifo_is_busy_next	<=	fifo_lowest_zero_bit;//keep the current read fifo
					end

					if(state_next == IDLE_WAIT) begin
						paillier_finished_reg	<=	1;
					end
				end

				STA_SCALAR_MUL_RD: begin
					task_cmd[block_lowest_zero_bit]			<=	0;
					task_req[block_lowest_zero_bit]			<=	0;
					block_target_addr[block_is_busy_next]	<=	loop_counter << 9;//target wr address = loop_counter * 4096 / 8
					if(AXI_FULL_IF.AXI_RVALID && axi_rready) begin
						scalar_mul_c1			[block_is_busy_next]	<=	single_task_read_cnt ==	0 ?	AXI_FULL_IF.AXI_RDATA : 0;
						scalar_mul_c1_valid		[block_is_busy_next]	<=	single_task_read_cnt ==	0 ?	1 : 0;
						scalar_mul_const		[block_is_busy_next]	<=	read_index < 16 ? (single_task_read_cnt !=	0 ?	AXI_FULL_IF.AXI_RDATA : 0) : 0;//The code "read_index < 16?" is employed to extend the valid signal to 32 cycles.
						scalar_mul_const_valid	[block_is_busy_next]	<=	single_task_read_cnt !=	0 ?	1 : 0;
					end
					else begin
						scalar_mul_c1			[block_is_busy_next]	<=	0;
						scalar_mul_c1_valid		[block_is_busy_next]	<=	0;
						scalar_mul_const		[block_is_busy_next]	<=	0;
						scalar_mul_const_valid	[block_is_busy_next]	<=	0;
					end
					if(!reads_done) begin
						if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin
							start_single_burst_read <= 1'b1;
						end
						else begin
							start_single_burst_read <= 1'b0; //Negate to generate a pulse
						end
					end
					if(reads_done) begin
						loop_counter			<=	loop_counter + (single_task_read_cnt == 1);// Carry after the last data is read.
						single_task_read_cnt	<=	single_task_read_cnt < 1  ? single_task_read_cnt + 1 : 0;
						block_is_busy 			<= 	block_is_busy | (1 << block_is_busy_next);
					end
				end

				STA_SCALAR_MUL_WR: begin
					if (!writes_done) begin
						if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active) begin
							start_single_burst_write <= 1'b1;
						end
						else begin
							start_single_burst_write <= 1'b0; //Negate to generate a pulse
						end
					end
					if(writes_done) begin
						block_is_busy	<= 	block_is_busy & (~(1 << fifo_is_busy_next));
					end
				end

				default: begin
				end                                                                                             
			endcase                                                                                             
		end                                                                                                   
	end //MASTER_EXECUTION_PROC                                                                               


	// burst_write_active signal is asserted when there is a burst write transaction                          
	// is initiated by the assertion of start_single_burst_write. burst_write_active                          
	// signal remains asserted until the burst write is accepted by the slave                                 
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
			burst_write_active <= 1'b0;
		//The burst_write_active is asserted when a write burst transaction is initiated                        
		else if (start_single_burst_write)
			burst_write_active <= 1'b1;
		else if (AXI_FULL_IF.AXI_BVALID && axi_bready)
			burst_write_active <= 0;
	end                                                                                                       
	 // Check for last write completion.

	 // This logic is to qualify the last write count with the final write
	 // response. This demonstrates how to confirm that a write has been
	 // committed.

	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
			writes_done <= 1'b0;
		//The writes_done should be associated with a bready response
		else if (AXI_FULL_IF.AXI_BVALID && (write_burst_counter == 1) && axi_bready)
			writes_done <= 1'b1;
		else                                                                                                    
			writes_done <= 0;                                                                           
	end                                                                                                     
	                                                                                                            
	// burst_read_active signal is asserted when there is a burst write transaction                           
	// is initiated by the assertion of start_single_burst_write. start_single_burst_read                     
	// signal remains asserted until the burst read is accepted by the master                                 
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
			burst_read_active <= 1'b0;                                                                            
																												
		//The burst_write_active is asserted when a write burst transaction is initiated                        
		else if (start_single_burst_read)                                                                       
			burst_read_active <= 1'b1;                                                                            
		else if (AXI_FULL_IF.AXI_RVALID && axi_rready && AXI_FULL_IF.AXI_RLAST)                                                     
			burst_read_active <= 0;                                                                               
	end                                                                                                     


	// Check for last read completion.                                                                         
																											
	// This logic is to qualify the last read count with the final read                                        
	// response. This demonstrates how to confirm that a read has been                                         
	// committed.                                                                                              
																											
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
			reads_done <= 1'b0;
		//The reads_done should be associated with a rready response
		else if (AXI_FULL_IF.AXI_RVALID && axi_rready && (read_index == `AXI_BURST_LEN-1) && (read_burst_counter == 1))
			reads_done <= 1'b1;                                                                                   
		else                                                                                                    
			reads_done <= 0;                                                                             
	end                                                                                                     

	// Add user logic here
	function logic [$clog2(BLOCK_COUNT)-1:0] find_lowest_zero_bit(logic [BLOCK_COUNT-1:0] data);
		logic [$clog2(BLOCK_COUNT)-1:0] index;
		index = 0;
		for(int i = 0; i < BLOCK_COUNT; i++) begin
			if(!data[i]) begin
				index = i;
				break;
			end
		end
		return index;
	endfunction
	// User logic ends

	endmodule