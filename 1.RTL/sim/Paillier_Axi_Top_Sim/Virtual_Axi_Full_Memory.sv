
`timescale 1 ns / 1 ps

	module Virtual_Axi_Full_Memory #(
		// Users to add parameters here
		parameter 	 	  PAILLIER_MODE = 2'b0,
		parameter		  TEST_TIMES = 10
		// User parameters ends
	)(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,

		tvip_axi_if         AXI_FULL_IF
	);
	import  tvip_axi_types_pkg::*;

	// AXI4FULL signals
	reg [`AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	// reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [`AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [`AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;
	// reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
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
	//local parameter for addressing 32 bit / 64 bit `AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2) 
	//ADDR_LSB = 3 for 42 bits (n downto 3)

	localparam integer ADDR_LSB = (`AXI_DATA_WIDTH/32);
	localparam integer OPT_MEM_ADDR_BITS = 24-ADDR_LSB;//the address number = 80Mb/8 = 10485760(24bits)
	localparam integer USER_NUM_MEM = 1;
	//----------------------------------------------
	//-- Signals for user logic memory space example
	//------------------------------------------------
	wire [OPT_MEM_ADDR_BITS:0] mem_address;
	wire [USER_NUM_MEM-1:0] mem_select;
	reg [`AXI_DATA_WIDTH-1:0] mem_data_out[0 : USER_NUM_MEM-1];

	genvar i;
	genvar j;
	genvar mem_byte_index;

	// I/O Connections assignments

	assign AXI_FULL_IF.AXI_AWREADY	= axi_awready;
	assign AXI_FULL_IF.AXI_WREADY	= axi_wready;
	assign AXI_FULL_IF.AXI_BRESP	= axi_bresp;
	// assign S_AXI_BUSER	= axi_buser;
	assign AXI_FULL_IF.AXI_BVALID	= axi_bvalid;
	assign AXI_FULL_IF.AXI_ARREADY	= axi_arready;
	assign AXI_FULL_IF.AXI_RDATA	= axi_rdata;
	assign AXI_FULL_IF.AXI_RRESP	= axi_rresp;
	assign AXI_FULL_IF.AXI_RLAST	= axi_rlast;
	// assign S_AXI_RUSER	= axi_ruser;
	assign AXI_FULL_IF.AXI_RVALID	= axi_rvalid;
	assign AXI_FULL_IF.AXI_BID = AXI_FULL_IF.AXI_AWID;
	assign AXI_FULL_IF.AXI_RID = AXI_FULL_IF.AXI_ARID;
	assign  aw_wrap_size = (`AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign  ar_wrap_size = (`AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	// Implement axi_awready generation

	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// AXI_FULL_IF.AXI_AWVALID and AXI_FULL_IF.AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_awready <= 1'b0;
			axi_awv_awr_flag <= 1'b0;
		end 
		else begin    
			if (~axi_awready && AXI_FULL_IF.AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
				// slave is ready to accept an address and
				// associated control signals
				axi_awready <= 1'b1;
				axi_awv_awr_flag  <= 1'b1; 
				// used for generation of bresp() and bvalid
			end
			else if (AXI_FULL_IF.AXI_WLAST && axi_wready) begin        
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
	// AXI_FULL_IF.AXI_AWVALID and AXI_FULL_IF.AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK ) begin
		if ( S_AXI_ARESETN == 1'b0 ) begin
			axi_awaddr <= 0;
			axi_awlen_cntr <= 0;
			axi_awburst <= 0;
			axi_awlen <= 0;
		end 
	  	else begin    
	      	if (~axi_awready && AXI_FULL_IF.AXI_AWVALID && ~axi_awv_awr_flag) begin
	          	// address latching 
	          	axi_awaddr <= AXI_FULL_IF.AXI_AWADDR[`AXI_ADDR_WIDTH - 1:0];  
	           	axi_awburst <= AXI_FULL_IF.AXI_AWBURST; 
	           	axi_awlen <= AXI_FULL_IF.AXI_AWLEN;     
				// start address of transfer
				axi_awlen_cntr <= 0;
	        end   
	      	else if((axi_awlen_cntr <= axi_awlen) && axi_wready && AXI_FULL_IF.AXI_WVALID) begin
				axi_awlen_cntr <= axi_awlen_cntr + 1;
				case (axi_awburst)
					2'b00: begin// fixed burst
						// The write address for all the beats in the transaction are fixed
						axi_awaddr <= axi_awaddr;          
						//for awsize = 4 bytes (010)
					end   
					2'b01: begin//incremental burst
						// The write address for all the beats in the transaction are increments by awsize
						axi_awaddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
						//awaddr aligned to 4 byte boundary
						axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
						//for awsize = 4 bytes (010)
					end   
					2'b10: begin//Wrapping burst
						// The write address wraps when the address reaches wrap boundary 
						if (aw_wrap_en) begin
							axi_awaddr <= (axi_awaddr - aw_wrap_size); 
						end
						else begin
							axi_awaddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
							axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
						end
					end
					default: begin//reserved (incremental burst for example)
						axi_awaddr <= axi_awaddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
						//for awsize = 4 bytes (010)
					end
				endcase              
	        end
	    end 
	end       
	// Implement axi_wready generation

	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// AXI_FULL_IF.AXI_AWVALID and AXI_FULL_IF.AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if ( ~axi_wready && AXI_FULL_IF.AXI_WVALID && axi_awv_awr_flag)
	        begin
	          // slave can accept the write data
	          axi_wready <= 1'b1;
	        end
	      //else if (~axi_awv_awr_flag)
	      else if (AXI_FULL_IF.AXI_WLAST && axi_wready)
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       
	// Implement write response logic generation

	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, AXI_FULL_IF.AXI_WVALID, axi_wready and AXI_FULL_IF.AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid <= 0;
	      axi_bresp <= 2'b0;
	    //   axi_buser <= 0;
	    end 
	  else
	    begin    
	      if (axi_awv_awr_flag && axi_wready && AXI_FULL_IF.AXI_WVALID && ~axi_bvalid && AXI_FULL_IF.AXI_WLAST )
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	          // 'OKAY' response 
	        end                   
	      else
	        begin
	          if (AXI_FULL_IF.AXI_BREADY && axi_bvalid) 
	          //check if bready is asserted while bvalid is high) 
	          //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	 end   
	// Implement axi_arready generation

	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// AXI_FULL_IF.AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when AXI_FULL_IF.AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && AXI_FULL_IF.AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_arready <= 1'b1;
	          axi_arv_arr_flag <= 1'b1;
	        end
	      else if (axi_rvalid && AXI_FULL_IF.AXI_RREADY && axi_arlen_cntr == axi_arlen)
	      // preparing to accept next address after current read completion
	        begin
	          axi_arv_arr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_araddr latching

	//This process is used to latch the address when both 
	//AXI_FULL_IF.AXI_ARVALID and AXI_FULL_IF.AXI_RVALID are valid. 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_araddr <= 0;
	      axi_arlen_cntr <= 0;
	      axi_arburst <= 0;
	      axi_arlen <= 0;
	      axi_rlast <= 1'b0;
	    //   axi_ruser <= 0;
	    end 
	  else
	    begin    
	      if (~axi_arready && AXI_FULL_IF.AXI_ARVALID && ~axi_arv_arr_flag)
	        begin
	          // address latching 
	          axi_araddr <= AXI_FULL_IF.AXI_ARADDR[`AXI_ADDR_WIDTH - 1:0]; 
	          axi_arburst <= AXI_FULL_IF.AXI_ARBURST; 
	          axi_arlen <= AXI_FULL_IF.AXI_ARLEN;     
	          // start address of transfer
	          axi_arlen_cntr <= 0;
	          axi_rlast <= 1'b0;
	        end   
	      else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && AXI_FULL_IF.AXI_RREADY)        
	        begin
	         
	          axi_arlen_cntr <= axi_arlen_cntr + 1;
	          axi_rlast <= 1'b0;
	        
	          case (axi_arburst)
	            2'b00: // fixed burst
	             // The read address for all the beats in the transaction are fixed
	              begin
	                axi_araddr       <= axi_araddr;        
	                //for arsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The read address for all the beats in the transaction are increments by awsize
	              begin
	                axi_araddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The read address wraps when the address reaches wrap boundary 
	              if (ar_wrap_en) 
	                begin
	                  axi_araddr <= (axi_araddr - ar_wrap_size); 
	                end
	              else 
	                begin
	                axi_araddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_araddr <= axi_araddr[`AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	                //for arsize = 4 bytes (010)
	              end
	          endcase              
	        end
	      else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag )   
	        begin
	          axi_rlast <= 1'b1;
	        end          
	      else if (AXI_FULL_IF.AXI_RREADY)   
	        begin
	          axi_rlast <= 1'b0;
	        end          
	    end 
	end       
	// Implement axi_arvalid generation

	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// AXI_FULL_IF.AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arv_arr_flag && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; 
	          // 'OKAY' response
	        end   
	      else if (axi_rvalid && AXI_FULL_IF.AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end            
	    end
	end    
	// ------------------------------------------
	// -- Example code to access user logic memory region
	// ------------------------------------------

	generate
	  	if (USER_NUM_MEM >= 1)begin
			assign mem_select  = 1;
			assign mem_address = (axi_arv_arr_flag? axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:(axi_awv_awr_flag? axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:0));
		end
	endgenerate

	// implement Block RAM(s)
	// reg  [8-1:0] byte_ram [0:`AXI_DATA_WIDTH/8-1][0 : 33554430];
	reg  [8-1:0] byte_ram [0:`AXI_DATA_WIDTH/8-1][0 : 1023];
	generate 
	  	for(i=0; i<= USER_NUM_MEM-1; i=i+1) begin:BRAM_GEN
			wire mem_rden;
			wire mem_wren;
		
			assign mem_wren = axi_wready && AXI_FULL_IF.AXI_WVALID ;

			assign mem_rden = axi_arv_arr_flag ; //& ~axi_rvalid
			
			for(mem_byte_index=0; mem_byte_index<= (`AXI_DATA_WIDTH/8-1); mem_byte_index=mem_byte_index+1) begin:BYTE_BRAM_GEN
				wire [8-1:0] data_in ;
				wire [8-1:0] data_out;

				//assigning 8 bit data
				assign data_in  = AXI_FULL_IF.AXI_WDATA[(mem_byte_index*8+7) -: 8];
				assign data_out = byte_ram[mem_byte_index][mem_address];

				always @( posedge S_AXI_ACLK ) begin
					if (mem_wren && AXI_FULL_IF.AXI_WSTRB[mem_byte_index]) begin
						byte_ram[mem_byte_index][mem_address] <= data_in;
					end   
				end

				always @( posedge S_AXI_ACLK ) begin
					if (mem_rden) begin
						mem_data_out[i][(mem_byte_index*8+7) -: 8] <= data_out;
					end   
				end
			end

	  	end       
	endgenerate
	//Output register or memory read data

	// always @( mem_data_out, axi_rvalid)
	always @(*)	begin
		if (axi_rvalid) begin
			// Read address mux
			axi_rdata <= mem_data_out[0];
		end
		else begin
			axi_rdata <= 32'h00000000;
		end
	end    


	reg [$clog2(TEST_TIMES):0] paillier_wr_cnt = 0;
	always @(posedge S_AXI_ACLK) begin
		if (AXI_FULL_IF.AXI_AWVALID && AXI_FULL_IF.AXI_AWREADY) begin
			paillier_wr_cnt <= paillier_wr_cnt + 1;
		end
	end
	
	// Add user logic here
generate 
	if(PAILLIER_MODE == 2'b00) begin
		string	file_path_enc_m = "../../../../../5.data/result_enc_m.txt";
		string	file_path_enc_r = "../../../../../5.data/result_enc_r.txt";
		string	file_path_enc_encrypted = "../../../../../5.data/result_enc_encrypted.txt";
		initial begin
			paillier_initial_memory_task(file_path_enc_m, file_path_enc_r, 2048, 2048);
		end

		initial begin
			paillier_memory_monitor_task(file_path_enc_encrypted, 4096);
		end
	end 
	else if(PAILLIER_MODE == 2'b01) begin
		string	file_path_dec_c = "../../../../../5.data/result_enc_encrypted.txt";
		string	file_path_dec_decrypted = "../../../../../5.data/result_enc_m.txt";
		initial begin
			paillier_initial_memory_task(file_path_dec_c, "none", 4096, 0);
		end

		initial begin
			paillier_memory_monitor_task(file_path_dec_decrypted, 2048);
		end
	end
	else if(PAILLIER_MODE == 2'b10) begin
		string	file_path_homomorphic_addition_a 		= "../../../../../5.data/homomorphic_addition_a.txt";
		string	file_path_homomorphic_addition_b 		= "../../../../../5.data/homomorphic_addition_b.txt";
		string	file_path_homomorphic_addition_result 	= "../../../../../5.data/homomorphic_addition_result.txt";
		initial begin
			paillier_initial_memory_task(file_path_homomorphic_addition_a, file_path_homomorphic_addition_b, 4096, 4096);
		end

		initial begin
			paillier_memory_monitor_task(file_path_homomorphic_addition_result, 4096);
		end
	end
	else if(PAILLIER_MODE == 2'b11) begin
		string	file_path_scalar_postive_multiplication_m 		= "../../../../../5.data/scalar_postive_multiplication_m.txt";
		string	file_path_scalar_postive_multiplication_const 	= "../../../../../5.data/scalar_postive_multiplication_const.txt";
		string	file_path_scalar_postive_multiplication_result 	= "../../../../../5.data/scalar_postive_multiplication_result.txt";
		initial begin
			paillier_initial_memory_task(file_path_scalar_postive_multiplication_m, file_path_scalar_postive_multiplication_const, 4096, 2048);
		end

		initial begin
			paillier_memory_monitor_task(file_path_scalar_postive_multiplication_result, 4096);
		end
	end
endgenerate


	// User logic ends
	//Add user task here
	task automatic paillier_initial_memory_task(input string file_path_a, input string file_path_b, input integer DATA_SIZE_1, input integer DATA_SIZE_2);
		integer p;
		integer fp_a, fp_b;
		fp_a = $fopen(file_path_a, "r");
		if (fp_a == 0) begin
			$display("Error opening file: %s", file_path_a);
			$finish;
		end
		if(file_path_b != "none") begin
			fp_b = $fopen(file_path_b, "r");
			if (fp_b == 0) begin
				$display("Error opening file: %s", file_path_b);
				$finish;
			end
		end

		for(p = 0; p < TEST_TIMES; p = p + 1) begin
			write_file_to_memory(fp_a, ((DATA_SIZE_1+DATA_SIZE_2)/`AXI_DATA_WIDTH)*p, DATA_SIZE_1);
			if(file_path_b != "none")
				write_file_to_memory(fp_b, ((DATA_SIZE_1+DATA_SIZE_2)/`AXI_DATA_WIDTH)*p + DATA_SIZE_1/`AXI_DATA_WIDTH, DATA_SIZE_2);
		end

		$fclose(fp_a);
		$fclose(fp_b);
	endtask

	task automatic paillier_memory_monitor_task(input string file_path_result, input integer DATA_SIZE);
		integer p;
		integer fp_result;
		reg [4095:0] memory_data_actual = 0;
		reg [4095:0] memory_data_expect = 0;
		wait(paillier_wr_cnt == TEST_TIMES);
		wait(AXI_FULL_IF.AXI_WREADY & AXI_FULL_IF.AXI_WVALID & AXI_FULL_IF.AXI_WLAST);
		@(posedge S_AXI_ACLK);//Wait until the last result is written.

		fp_result = $fopen(file_path_result, "r");
		if (fp_result == 0) begin
			$display("Error opening file: %s", file_path_result);
			$finish;
		end
		
		for(p = 0; p < TEST_TIMES; p = p + 1) begin
			@(posedge S_AXI_ACLK);//Add for debug.
			memory_data_actual = read_file_from_memory((DATA_SIZE/`AXI_DATA_WIDTH)*p, DATA_SIZE);
			$fscanf(fp_result, "%x ", memory_data_expect);
			assert(memory_data_actual == memory_data_expect)
				$display("Check [%d] passed", p);
			else
				$display("Error: Check [%d] failed", p);
		end
		$fclose(fp_result);
	endtask
	// User task ends

	// Add user function here
	function void write_file_to_memory(input integer fp, input integer start_address, input integer DATA_SIZE);
		reg	[4095:0]	file_data;
		integer p, o;
		$fscanf(fp, "%x ", file_data);
		for(p = start_address; p < start_address + DATA_SIZE/`AXI_DATA_WIDTH; p=p+1) begin
			for(o = 0; o <= (`AXI_DATA_WIDTH/8-1); o=o+1) begin
				byte_ram[o][p]  =  file_data[0+:8];
				file_data       =  file_data>>8;
			end
		end
	endfunction

  	function reg [4095:0] read_file_from_memory(input integer start_address, input integer DATA_SIZE);
		reg [4095:0] memory_data;
		integer p, o;
		for(p = start_address; p < start_address + DATA_SIZE/`AXI_DATA_WIDTH; p = p + 1) begin
			for(o = 0; o <= (`AXI_DATA_WIDTH/8 - 1); o = o + 1) begin
				memory_data = memory_data >> 8;
				memory_data[(DATA_SIZE-1)-:8] = byte_ram[o][p];
			end
		end
		return memory_data;
	endfunction
	// User function ends

	endmodule
