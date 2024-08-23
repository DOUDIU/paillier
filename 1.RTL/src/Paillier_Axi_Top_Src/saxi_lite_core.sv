	module saxi_lite_core(
		// Users to add ports here
		output wire 		paillier_start,
		output wire [1:0]	paillier_mode,

		input wire 			paillier_finished,

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,

		tvip_axi_if		AXI_LITE_IF
	);
	import  tvip_axi_types_pkg::*;

	// AXI4LITE signals
	reg [`AXI_LITE_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [`AXI_LITE_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [`AXI_LITE_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit `AXI_LITE_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (`AXI_LITE_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [`AXI_LITE_DATA_WIDTH-1:0]	slv_reg0;
	reg [`AXI_LITE_DATA_WIDTH-1:0]	slv_reg1;
	reg [`AXI_LITE_DATA_WIDTH-1:0]	slv_reg2;
	reg [`AXI_LITE_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [`AXI_LITE_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign AXI_LITE_IF.AXI_AWREADY	= axi_awready;
	assign AXI_LITE_IF.AXI_WREADY	= axi_wready;
	assign AXI_LITE_IF.AXI_BRESP	= axi_bresp;
	assign AXI_LITE_IF.AXI_BVALID	= axi_bvalid;
	assign AXI_LITE_IF.AXI_ARREADY	= axi_arready;
	assign AXI_LITE_IF.AXI_RDATA	= axi_rdata;
	assign AXI_LITE_IF.AXI_RRESP	= axi_rresp;
	assign AXI_LITE_IF.AXI_RVALID	= axi_rvalid;


	// Add user logic here
	assign paillier_start = slv_reg0[0];
	assign paillier_mode = slv_reg0[2:1];

	reg	paillier_finished_d1;
	reg paillier_finished_d2;

	reg paillier_finished_reg;

	always @(posedge S_AXI_ACLK) begin
		if (S_AXI_ARESETN == 1'b0) begin
			paillier_finished_d1 <= 1'b0;
			paillier_finished_d2 <= 1'b0;
		end
		else begin
			paillier_finished_d1 <= paillier_finished;
			paillier_finished_d2 <= paillier_finished_d1;
		end
	end

	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
		if (S_AXI_ARESETN == 1'b0) begin
			paillier_finished_reg <= 0;
		end
		else if (!paillier_finished_d2 & paillier_finished_d1) begin
			paillier_finished_reg <= 1;
		end
		else if(slv_reg0[0]) begin
			paillier_finished_reg <= 0;
		end
	end

	// User logic ends


	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// AXI_LITE_IF.AXI_AWVALID and AXI_LITE_IF.AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @(posedge S_AXI_ACLK) begin
		if (S_AXI_ARESETN == 1'b0) begin
			axi_awready <= 1'b0;
			aw_en <= 1'b1;
		end
		else begin    
			if (~axi_awready && AXI_LITE_IF.AXI_AWVALID && AXI_LITE_IF.AXI_WVALID && aw_en) begin
				// slave is ready to accept write address when 
				// there is a valid write address and write data
				// on the write address and data bus. This design 
				// expects no outstanding transactions. 
				axi_awready <= 1'b1;
				aw_en <= 1'b0;
			end
			else if (AXI_LITE_IF.AXI_BREADY && axi_bvalid) begin
				aw_en <= 1'b1;
				axi_awready <= 1'b0;
			end
			else begin
				axi_awready <= 1'b0;
			end
		end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// AXI_LITE_IF.AXI_AWVALID and AXI_LITE_IF.AXI_WVALID are valid. 

	always @(posedge S_AXI_ACLK) begin
		if (S_AXI_ARESETN == 1'b0) begin
			axi_awaddr <= 0;
		end
		else begin    
			if (~axi_awready && AXI_LITE_IF.AXI_AWVALID && AXI_LITE_IF.AXI_WVALID && aw_en) begin
				// Write Address latching 
				axi_awaddr <= AXI_LITE_IF.AXI_AWADDR;
			end
		end 
	end

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// AXI_LITE_IF.AXI_AWVALID and AXI_LITE_IF.AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK ) begin
		if (S_AXI_ARESETN == 1'b0) begin
			axi_wready <= 1'b0;
		end 
		else begin
			if (~axi_wready && AXI_LITE_IF.AXI_WVALID && AXI_LITE_IF.AXI_AWVALID && aw_en) begin
				// slave is ready to accept write data when 
				// there is a valid write address and write data
				// on the write address and data bus. This design 
				// expects no outstanding transactions. 
				axi_wready <= 1'b1;
			end
			else begin
				axi_wready <= 1'b0;
			end
		end
	end

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, AXI_LITE_IF.AXI_WVALID, axi_wready and AXI_LITE_IF.AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && AXI_LITE_IF.AXI_WVALID && axi_awready && AXI_LITE_IF.AXI_AWVALID;

	always @(posedge S_AXI_ACLK) begin
		if (S_AXI_ARESETN == 1'b0) begin
			slv_reg0 <= 0;
			slv_reg1 <= 0;
			slv_reg2 <= 0;
			slv_reg3 <= 0;
		end 
		else begin
			if (slv_reg_wren) begin
				case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
					2'h0: begin
						for ( byte_index = 0; byte_index <= (`AXI_LITE_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
							if ( AXI_LITE_IF.AXI_WSTRB[byte_index] == 1 ) begin
								// Respective byte enables are asserted as per write strobes 
								// Slave register 0
								slv_reg0[(byte_index*8) +: 8] <= AXI_LITE_IF.AXI_WDATA[(byte_index*8) +: 8];
							end
						end
					end
					2'h1: begin
						for ( byte_index = 0; byte_index <= (`AXI_LITE_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
							if ( AXI_LITE_IF.AXI_WSTRB[byte_index] == 1 ) begin
								// Respective byte enables are asserted as per write strobes 
								// Slave register 1
								slv_reg1[(byte_index*8) +: 8] <= AXI_LITE_IF.AXI_WDATA[(byte_index*8) +: 8];
							end  
						end
					end
					2'h2: begin
						for ( byte_index = 0; byte_index <= (`AXI_LITE_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
							if ( AXI_LITE_IF.AXI_WSTRB[byte_index] == 1 ) begin
								// Respective byte enables are asserted as per write strobes 
								// Slave register 2
								slv_reg2[(byte_index*8) +: 8] <= AXI_LITE_IF.AXI_WDATA[(byte_index*8) +: 8];
							end  
						end
					end
					2'h3: begin
						for ( byte_index = 0; byte_index <= (`AXI_LITE_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
							if ( AXI_LITE_IF.AXI_WSTRB[byte_index] == 1 ) begin
								// Respective byte enables are asserted as per write strobes 
								// Slave register 3
								slv_reg3[(byte_index*8) +: 8] <= AXI_LITE_IF.AXI_WDATA[(byte_index*8) +: 8];
							end  
						end
					end
					default : begin
						slv_reg0 <= slv_reg0;
						slv_reg1 <= slv_reg1;
						slv_reg2 <= slv_reg2;
						slv_reg3 <= slv_reg3;
					end
				endcase
			end
		end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, AXI_LITE_IF.AXI_WVALID, axi_wready and AXI_LITE_IF.AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_bvalid  <= 0;
			axi_bresp   <= 2'b0;
		end 
		else begin    
			if (axi_awready && AXI_LITE_IF.AXI_AWVALID && ~axi_bvalid && axi_wready && AXI_LITE_IF.AXI_WVALID) begin
				// indicates a valid write response is available
				axi_bvalid <= 1'b1;
				axi_bresp  <= 2'b0; // 'OKAY' response 
			end                   // work error responses in future
			else begin
				if (AXI_LITE_IF.AXI_BREADY && axi_bvalid) begin
					//check if bready is asserted while bvalid is high) 
					//(there is a possibility that bready is always asserted high)   
					axi_bvalid <= 1'b0; 
				end
			end
		end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// AXI_LITE_IF.AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when AXI_LITE_IF.AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_arready <= 1'b0;
			axi_araddr  <= 32'b0;
		end 
		else begin    
			if (~axi_arready && AXI_LITE_IF.AXI_ARVALID) begin
				// indicates that the slave has acceped the valid read address
				axi_arready <= 1'b1;
				// Read address latching
				axi_araddr  <= AXI_LITE_IF.AXI_ARADDR;
			end
			else begin
				axi_arready <= 1'b0;
			end
		end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// AXI_LITE_IF.AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_rvalid <= 0;
			axi_rresp  <= 0;
		end 
		else begin    
			if (axi_arready && AXI_LITE_IF.AXI_ARVALID && ~axi_rvalid) begin
				// Valid read data is available at the read data bus
				axi_rvalid <= 1'b1;
				axi_rresp  <= 2'b0; // 'OKAY' response
			end
			else if (axi_rvalid && AXI_LITE_IF.AXI_RREADY) begin
				// Read data is accepted by the master
				axi_rvalid <= 1'b0;
			end
		end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & AXI_LITE_IF.AXI_ARVALID & ~axi_rvalid;
	always @(*) begin
		// Address decoding for reading registers
		case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
			2'h0   : reg_data_out <= slv_reg0;
			2'h1   : reg_data_out <= slv_reg1 | paillier_finished_reg;
			2'h2   : reg_data_out <= slv_reg2;
			2'h3   : reg_data_out <= slv_reg3;
			default : reg_data_out <= 0;
		endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_rdata  <= 0;
		end 
		else begin    
			// When there is a valid read address (AXI_LITE_IF.AXI_ARVALID) with 
			// acceptance of read address by the slave (axi_arready), 
			// output the read dada 
			if (slv_reg_rden) begin
				axi_rdata <= reg_data_out;     // register read data
			end
		end
	end    

	endmodule
