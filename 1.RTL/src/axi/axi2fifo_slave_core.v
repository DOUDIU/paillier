//----------------------------------------------------------------
//  Copyright (c) 2010-2012 by Ando Ki.
//  All right reserved.
//----------------------------------------------------------------
// AHB Slave to synchronous FIFO
//----------------------------------------------------------------
// VERSION: 2012.02.17.
//----------------------------------------------------------------
// Macros and parameters:
//----------------------------------------------------------------
// Note:
//----------------------------------------------------------------
// Signal naming convention:
//    * forward: address and control information goes out
//    * bakward: data information comes in
//    * fwr_ : forward and fifo-write
//    * brd_ : backward and fifo-read
//----------------------------------------------------------------
`timescale 1ns/1ns

module axi2fifo_slave_core#(
        parameter FIFO_AW=5
    ,   parameter ADDR_BASE = 32'h78000000
    ,   parameter K = 128
    ,   parameter N = 16
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of ID for for write address, write data, read address and read data
    ,   parameter integer C_S_AXI_ID_WIDTH	= 1
    // Width of S_AXI data bus
    ,   parameter integer C_S_AXI_DATA_WIDTH	= 32
    // Width of S_AXI address bus
    ,   parameter integer C_S_AXI_ADDR_WIDTH	= 32
    // Width of optional user defined signal in write address channel
    ,   parameter integer C_S_AXI_AWUSER_WIDTH	= 0
    // Width of optional user defined signal in read address channel
    ,   parameter integer C_S_AXI_ARUSER_WIDTH	= 0
    // Width of optional user defined signal in write data channel
    ,   parameter integer C_S_AXI_WUSER_WIDTH	= 0
    // Width of optional user defined signal in read data channel
    ,   parameter integer C_S_AXI_RUSER_WIDTH	= 0
    // Width of optional user defined signal in write response channel
    ,   parameter integer C_S_AXI_BUSER_WIDTH	= 0
)(

//----------------------------------------------------
// AXI slave port
        input   wire                                S_AXI_ACLK
    ,   input   wire                                S_AXI_ARESETN

    ,   input   wire [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_AWID
    ,   input   wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR
    ,   input   wire [7 : 0]                        S_AXI_AWLEN
    ,   input   wire [2 : 0]                        S_AXI_AWSIZE
    ,   input   wire [1 : 0]                        S_AXI_AWBURST
    ,   input   wire                                S_AXI_AWLOCK
    ,   input   wire [3 : 0]                        S_AXI_AWCACHE
    ,   input   wire [2 : 0]                        S_AXI_AWPROT
    ,   input   wire [3 : 0]                        S_AXI_AWQOS
    ,   input   wire [3 : 0]                        S_AXI_AWREGION
    ,   input   wire [C_S_AXI_AWUSER_WIDTH-1 : 0]   S_AXI_AWUSER
    ,   input   wire                                S_AXI_AWVALID
    ,   output  wire                                S_AXI_AWREADY

    ,   input   wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA
    ,   input   wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB
    ,   input   wire                                S_AXI_WLAST
    ,   input   wire [C_S_AXI_WUSER_WIDTH-1 : 0]    S_AXI_WUSER
    ,   input   wire                                S_AXI_WVALID
    ,   output  wire                                S_AXI_WREADY

    ,   output  wire [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_BID
    ,   output  wire [1 : 0]                        S_AXI_BRESP
    ,   output  wire [C_S_AXI_BUSER_WIDTH-1 : 0]    S_AXI_BUSER
    ,   output  wire                                S_AXI_BVALID
    ,   input   wire                                S_AXI_BREADY

    ,   input   wire [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_ARID
    ,   input   wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR
    ,   input   wire [7 : 0]                        S_AXI_ARLEN
    ,   input   wire [2 : 0]                        S_AXI_ARSIZE
    ,   input   wire [1 : 0]                        S_AXI_ARBURST
    ,   input   wire                                S_AXI_ARLOCK
    ,   input   wire [3 : 0]                        S_AXI_ARCACHE
    ,   input   wire [2 : 0]                        S_AXI_ARPROT
    ,   input   wire [3 : 0]                        S_AXI_ARQOS
    ,   input   wire [3 : 0]                        S_AXI_ARREGION
    ,   input   wire [C_S_AXI_ARUSER_WIDTH-1 : 0]   S_AXI_ARUSER
    ,   input   wire                                S_AXI_ARVALID
    ,   output  wire                                S_AXI_ARREADY

    ,   output  wire [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_RID
    ,   output  wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA
    ,   output  wire [1 : 0]                        S_AXI_RRESP
    ,   output  wire                                S_AXI_RLAST
    ,   output  wire [C_S_AXI_RUSER_WIDTH-1 : 0]    S_AXI_RUSER
    ,   output  wire                                S_AXI_RVALID
    ,   input   wire                                S_AXI_RREADY
//----------------------------------------------------
// FIFO forward: address related
    ,   output  wire               fwr_clk  
    ,   input   wire               fwr_rdy  
    ,   output  reg                fwr_vld  
    ,   output  reg  [31   :0]     fwr_dat  
    ,   input   wire               fwr_full
    ,   input   wire [FIFO_AW:0]   fwr_cnt // how many rooms available
//----------------------------------------------------
// FIFO backward: data related
    ,   output  wire               brd_clk  
    ,   output  reg                brd_rdy  
    ,   input   wire               brd_vld  
    ,   input   wire [31   :0]     brd_dat  
    ,   input   wire               brd_empty
    ,   input   wire [FIFO_AW:0]   brd_cnt // how many items available
//----------------------------------------------------
// FIFO backward: data related
    ,   output  wire               rsa_start
    ,   input   wire               rsa_finish          
);


	// AXI4FULL signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;
	// aw_wrap_en determines wrap boundary and enables wrapping
	wire aw_wrap_en;
	// ar_wrap_en determines wrap boundary and enables wrapping
	wire ar_wrap_en;
	// aw_wrap_size is the size of the write transfer, the
	// write address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  aw_wrap_size ; 
	// ar_wrap_size is the size of the read transfer, the
	// read address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  ar_wrap_size ; 
	// The axi_awv_awr_flag flag marks the presence of write address valid
	reg axi_awv_awr_flag;
	//The axi_arv_arr_flag flag marks the presence of read address valid
	reg axi_arv_arr_flag; 
	// The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	reg [7:0] axi_awlen_cntr;
	//The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;
	//local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2) 
	//ADDR_LSB = 3 for 42 bits (n downto 3)

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32);
	localparam integer OPT_MEM_ADDR_BITS = 24-ADDR_LSB;//the address number = 80Mb/8 = 10485760(24bits)
	localparam integer USER_NUM_MEM = 1;
	//----------------------------------------------
	//-- Signals for user logic memory space example
	//------------------------------------------------
	wire [OPT_MEM_ADDR_BITS:0] mem_address;
	wire [USER_NUM_MEM-1:0] mem_select;
	reg [C_S_AXI_DATA_WIDTH-1:0] mem_data_out[0 : USER_NUM_MEM-1];

	genvar i;
	genvar j;
	genvar mem_byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BUSER	= axi_buser;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RLAST	= axi_rlast;
	assign S_AXI_RUSER	= axi_ruser;
	assign S_AXI_RVALID	= axi_rvalid;
	assign S_AXI_BID = S_AXI_AWID;
	assign S_AXI_RID = S_AXI_ARID;
	assign  aw_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign  ar_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	// Implement axi_awready generation

	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_awready <= 1'b0;
			axi_awv_awr_flag <= 1'b0;
		end 
		else begin    
			if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
				// slave is ready to accept an address and
				// associated control signals
				axi_awready <= 1'b1;
				axi_awv_awr_flag  <= 1'b1; 
				// used for generation of bresp() and bvalid
			end
			else if (S_AXI_WLAST && axi_wready) begin  
				// preparing to accept next address after current write burst tx completion
				axi_awv_awr_flag  <= 1'b0;
			end
			else begin
				axi_awready <= 1'b0;
			end
		end 
	end       
	// Implement axi_awaddr latching

	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_awaddr <= 0;
			axi_awlen_cntr <= 0;
			axi_awburst <= 0;
			axi_awlen <= 0;
		end 
	  	else begin    
			if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag) begin
				// address latching 
				axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];  
				axi_awburst <= S_AXI_AWBURST; 
				axi_awlen <= S_AXI_AWLEN;     
				// start address of transfer
				axi_awlen_cntr <= 0;
			end
	      	else if((axi_awlen_cntr <= axi_awlen) && axi_wready && S_AXI_WVALID) begin
				axi_awlen_cntr <= axi_awlen_cntr + 1;
				case (axi_awburst)
					2'b00: // fixed burst
					// The write address for all the beats in the transaction are fixed
					begin
						axi_awaddr <= axi_awaddr;          
						//for awsize = 4 bytes (010)
					end   
					2'b01: //incremental burst
					// The write address for all the beats in the transaction are increments by awsize
					begin
						axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
						//awaddr aligned to 4 byte boundary
						axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
						//for awsize = 4 bytes (010)
					end   
					2'b10: //Wrapping burst
						// The write address wraps when the address reaches wrap boundary 
						if (aw_wrap_en) begin
							axi_awaddr <= (axi_awaddr - aw_wrap_size); 
						end
						else begin
							axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
							axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
						end
					default: //reserved (incremental burst for example)
					begin
						axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
						//for awsize = 4 bytes (010)
					end
				endcase              
	        end
	    end 
	end       
	// Implement axi_wready generation

	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK ) begin
	  	if ( S_AXI_ARESETN == 1'b0 ) begin
	      	axi_wready <= 1'b0;
	    end 
	  	else begin    
			if ( ~axi_wready && S_AXI_WVALID && axi_awv_awr_flag) begin
				// slave can accept the write data
				axi_wready <= 1'b1;
			end
			//else if (~axi_awv_awr_flag)
			else if (S_AXI_WLAST && axi_wready) begin
				axi_wready <= 1'b0;
			end
	    end 
	end       
	// Implement write response logic generation

	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_bvalid <= 0;
			axi_bresp <= 2'b0;
			axi_buser <= 0;
		end
		else begin    
			if (axi_awv_awr_flag && axi_wready && S_AXI_WVALID && ~axi_bvalid && S_AXI_WLAST ) begin
				axi_bvalid <= 1'b1;
				axi_bresp  <= 2'b0; 
				// 'OKAY' response 
			end
			else begin
				if (S_AXI_BREADY && axi_bvalid) begin
				//check if bready is asserted while bvalid is high)
				//(there is a possibility that bready is always asserted high)
					axi_bvalid <= 1'b0; 
				end
			end
		end
	end   
	// Implement axi_arready generation

	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @(posedge S_AXI_ACLK) begin
	  	if (S_AXI_ARESETN == 1'b0) begin
			axi_arready <= 1'b0;
			axi_arv_arr_flag <= 1'b0;
		end 
	  	else begin    
			if (~axi_arready && S_AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
				axi_arready <= 1'b1;
				axi_arv_arr_flag <= 1'b1;
			end
			else if (axi_rvalid && S_AXI_RREADY && axi_arlen_cntr == axi_arlen) begin
			// preparing to accept next address after current read completion
				axi_arv_arr_flag  <= 1'b0;
			end
			else begin
				axi_arready <= 1'b0;
			end
	    end 
	end       
	// Implement axi_araddr latching

	//This process is used to latch the address when both 
	//S_AXI_ARVALID and S_AXI_RVALID are valid. 
	always @(posedge S_AXI_ACLK) begin
		if (S_AXI_ARESETN == 1'b0) begin
			axi_araddr <= 0;
			axi_arlen_cntr <= 0;
			axi_arburst <= 0;
			axi_arlen <= 0;
			axi_rlast <= 1'b0;
			axi_ruser <= 0;
		end 
		else begin    
			if (~axi_arready && S_AXI_ARVALID && ~axi_arv_arr_flag) begin
					// address latching 
					axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0]; 
					axi_arburst <= S_AXI_ARBURST; 
					axi_arlen <= S_AXI_ARLEN;     
					// start address of transfer
					axi_arlen_cntr <= 0;
					axi_rlast <= 1'b0;
			end
			else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY) begin
				axi_arlen_cntr <= axi_arlen_cntr + 1;
				axi_rlast <= 1'b0;
				case (axi_arburst)
					2'b00: begin// fixed burst
					// The read address for all the beats in the transaction are fixed
						axi_araddr       <= axi_araddr;        
						//for arsize = 4 bytes (010)
					end   
					2'b01: begin//incremental burst
					// The read address for all the beats in the transaction are increments by awsize
						axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
						//araddr aligned to 4 byte boundary
						axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
						//for awsize = 4 bytes (010)
					end   
					2'b10: begin//Wrapping burst
					// The read address wraps when the address reaches wrap boundary 
						if (ar_wrap_en) begin
							axi_araddr <= (axi_araddr - ar_wrap_size); 
						end
						else begin
							axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
							//araddr aligned to 4 byte boundary
							axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
						end
					end
					default: begin//reserved (incremental burst for example)
						axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
						//for arsize = 4 bytes (010)
					end
				endcase              
			end
			else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag ) begin
				axi_rlast <= 1'b1;
			end
			else if (S_AXI_RREADY) begin
				axi_rlast <= 1'b0;
			end
		end 
	end       
	// Implement axi_arvalid generation

	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  

	always @(posedge S_AXI_ACLK) begin
		if(S_AXI_ARESETN == 1'b0) begin
			axi_rvalid <= 0;
			axi_rresp  <= 0;
		end
		else begin
			if (axi_arv_arr_flag && ~axi_rvalid) begin
				axi_rvalid <= 1'b1;
				axi_rresp  <= 2'b0; 
				// 'OKAY' response
			end   
			else if (axi_rvalid && S_AXI_RREADY) begin
				axi_rvalid <= 1'b0;
			end            
		end
	end    
	// ------------------------------------------
	// -- Example code to access user logic memory region
	// ------------------------------------------

	wire mem_rden;
	wire mem_wren;
	generate
	  	if (USER_NUM_MEM >= 1) begin
			assign mem_wren = axi_wready && S_AXI_WVALID ;
			assign mem_rden = axi_arv_arr_flag ; //& ~axi_rvalid
	      	assign mem_select  = 1;
	      	assign mem_address = ( axi_arv_arr_flag ? axi_araddr[OPT_MEM_ADDR_BITS : 0] : (axi_awv_awr_flag ? axi_awaddr[OPT_MEM_ADDR_BITS : 0] : 0) );
	    end
	endgenerate

    //----------------------------------------------------
    reg [31:0]  REG_STATE [0:1];

	always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
		if(!S_AXI_ARESETN)begin
			fwr_vld <= 1'b0;
			fwr_dat <= 32'h00000000;
		end
		else if(mem_wren & (mem_address[7:0] == 8'h10) & (!fwr_full)) begin
			fwr_vld <= 1'b1;
			fwr_dat <= S_AXI_WDATA;
		end
		else begin
			fwr_vld <= 1'b0;
			fwr_dat <= 32'h00000000;
		end
	end

	always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
		if(!S_AXI_ARESETN)begin
			REG_STATE[0] <= 1'b0;
		end
		else if(mem_wren & (mem_address[7:0] == 8'h00)) begin
			REG_STATE[0] <= S_AXI_WDATA;
		end
	end

	assign rsa_start = (REG_STATE[0] != 0) & (fwr_cnt==(K*N/32));

	always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
		if(!S_AXI_ARESETN)begin
            REG_STATE[1] <=  0;
        end
        else if(rsa_finish)begin
            REG_STATE[1] <=  1;
        end
    end

	always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
		if(!S_AXI_ARESETN)begin
			axi_rdata <= 1'b0;
		end
		else if(mem_rden & (mem_address[7:0] == 8'h04)) begin
			axi_rdata <= REG_STATE[1];
		end
		else if(mem_rden & (mem_address[7:0] == 8'h10) & REG_STATE[1]) begin
			axi_rdata <= brd_dat;
		end
		else begin
			axi_rdata <= 1'b0;
		end
	end

	always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
		if(!S_AXI_ARESETN)begin
			brd_rdy <= 1'b0;
		end
		else if((axi_rvalid & S_AXI_RREADY) & (mem_address[7:0] == 8'h10) & (!brd_empty) & REG_STATE[1]) begin
			brd_rdy <= 1'b1;
		end
		else begin
			brd_rdy <= 1'b0;
		end
	end





/*
	// implement Block RAM(s)
	generate 
	  for(i=0; i<= USER_NUM_MEM-1; i=i+1)
	    begin:BRAM_GEN
	      wire mem_rden;
	      wire mem_wren;
	
	      assign mem_wren = axi_wready && S_AXI_WVALID ;
	
	      assign mem_rden = axi_arv_arr_flag ; //& ~axi_rvalid
	     
	      for(mem_byte_index=0; mem_byte_index<= (C_S_AXI_DATA_WIDTH/8-1); mem_byte_index=mem_byte_index+1)
	      begin:BYTE_BRAM_GEN
	        wire [8-1:0] data_in ;
	        wire [8-1:0] data_out;
	        reg  [8-1:0] byte_ram [0 : 1655359];

			integer  j;
	     
	        //assigning 8 bit data
	        assign data_in  = S_AXI_WDATA[(mem_byte_index*8+7) -: 8];
	        assign data_out = byte_ram[mem_address];
	     
	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_wren && S_AXI_WSTRB[mem_byte_index])
	            begin
	              byte_ram[mem_address] <= data_in;
	            end   
	        end

	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_rden)
	            begin
	              mem_data_out[i][(mem_byte_index*8+7) -: 8] <= data_out;
	            end   
	        end    
	               
	    end
	  end       
	endgenerate
	//Output register or memory read data

	// always @( mem_data_out, axi_rvalid)
	always @(*)
	begin
	  if (axi_rvalid) 
	    begin
	      // Read address mux
	      axi_rdata <= mem_data_out[0];
	    end   
	  else
	    begin
	      axi_rdata <= 32'h00000000;
	    end       
	end    

	// Add user logic here

	// User logic ends
*/

endmodule
