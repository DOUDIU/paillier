//----------------------------------------------------------------
//  Copyright (c) 2015 by Ando Ki.
//  All right reserved.
//  http://www.dynalith.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//----------------------------------------------------------------
// bfm_axi.v
//----------------------------------------------------------------
// VERSION: 2015.08.15.
//----------------------------------------------------------------
//  [MACROS]
//    AMBA_AXI4       - AMBA AXI4
//    AMBA_AXI_CACHE  -
//    AMBA_AXI_PROT   -
//----------------------------------------------------------------
`define AMBA_AXI4
`timescale 1ns/1ns

module bfm_axi #(
        parameter   MST_ID          =   0                   // Master ID
    ,   parameter   WIDTH_CID       =   4
    ,   parameter   WIDTH_ID        =   4                   // ID width in bits
    ,   parameter   WIDTH_AD        =   32                  // address width
    ,   parameter   WIDTH_DA        =   32                  // data width
    ,   parameter   WIDTH_DS        =   (WIDTH_DA/8)        // data strobe width
    ,   parameter   WIDTH_DSB       =   clogb2(WIDTH_DS)    // data strobe width
    ,   parameter   START_ADDR      =   32'h0000_0000       // start address
)(
        input  wire                 ARESETn
    ,   input  wire                 ACLK
    ,   output wire [WIDTH_CID-1:0] MID
    //-----------------------------------------------------------
    ,   output reg  [WIDTH_ID-1:0]  AWID
    ,   output reg  [WIDTH_AD-1:0]  AWADDR
`ifdef AMBA_AXI4
    ,   output reg  [ 7:0]          AWLEN
    ,   output reg                  AWLOCK
`else
    ,   output reg  [ 3:0]          AWLEN
    ,   output reg  [ 1:0]          AWLOCK
`endif
    ,   output reg  [ 2:0]          AWSIZE
    ,   output reg  [ 1:0]          AWBURST
`ifdef AMBA_AXI_CACHE
    ,   output reg  [ 3:0]          AWCACHE
`endif
`ifdef AMBA_AXI_PROT
    ,   output reg  [ 2:0]          AWPROT
`endif
    ,   output reg                  AWVALID
    ,   input  wire                 AWREADY
`ifdef AMBA_AXI4
    ,   output reg  [ 3:0]          AWQOS
    ,   output reg  [ 3:0]          AWREGION
`endif
    //-----------------------------------------------------------
    ,   output reg  [WIDTH_ID-1:0]  WID
    ,   output reg  [WIDTH_DA-1:0]  WDATA
    ,   output reg  [WIDTH_DS-1:0]  WSTRB
    ,   output reg                  WLAST
    ,   output reg                  WVALID
    ,   input  wire                 WREADY
    //-----------------------------------------------------------
    ,   input  wire [WIDTH_ID-1:0]  BID
    ,   input  wire [ 1:0]          BRESP
    ,   input  wire                 BVALID
    ,   output reg                  BREADY
    //-----------------------------------------------------------
    ,   output reg  [WIDTH_ID-1:0]  ARID
    ,   output reg  [WIDTH_AD-1:0]  ARADDR
`ifdef AMBA_AXI4
    ,   output reg  [ 7:0]          ARLEN
    ,   output reg                  ARLOCK
`else
    ,   output reg  [ 3:0]          ARLEN
    ,   output reg  [ 1:0]          ARLOCK
`endif
    ,   output reg  [ 2:0]          ARSIZE
    ,   output reg  [ 1:0]          ARBURST
`ifdef AMBA_AXI_CACHE
    ,   output reg  [ 3:0]          ARCACHE
`endif
`ifdef AMBA_AXI_PROT
    ,   output reg  [ 2:0]          ARPROT
`endif
    ,   output reg                  ARVALID
    ,   input  wire                 ARREADY
`ifdef AMBA_AXI4
    ,   output reg  [ 3:0]          ARQOS
    ,   output reg  [ 3:0]          ARREGION
`endif
    //-----------------------------------------------------------
    ,   input  wire [WIDTH_ID-1:0]  RID
    ,   input  wire [WIDTH_DA-1:0]  RDATA
    ,   input  wire [ 1:0]          RRESP
    ,   input  wire                 RLAST
    ,   input  wire                 RVALID
    ,   output reg                  RREADY
);
    //-----------------------------------------------------------
    assign MID = MST_ID;
    //-----------------------------------------------------------
    reg        DONE = 1'b0;
    //-----------------------------------------------------------
    initial begin
        AWID        = 0;
        AWADDR      = ~0;
        AWLEN       = 0;
        AWLOCK      = 0;
        AWSIZE      = 0;
        AWBURST     = 0;
        `ifdef AMBA_AXI_CACHE
        AWCACHE     = 0;
        `endif
        `ifdef AMBA_AXI_PROT
        AWPROT      = 0;
        `endif
        AWVALID     = 0;
        `ifdef AMBA_AXI4
        AWQOS       = 0;
        AWREGION    = 0;
        `endif
        WID         = 0;
        WDATA       = ~0;
        WSTRB       = 0;
        WLAST       = 0;
        WVALID      = 0;
        BREADY      = 0;
        ARID        = 0;
        ARADDR      = ~0;
        ARLEN       = 0;
        ARLOCK      = 0;
        ARSIZE      = 0;
        ARBURST     = 0;
        `ifdef AMBA_AXI_CACHE
        ARCACHE     = 0;
        `endif
        `ifdef AMBA_AXI_PROT
        ARPROT      = 0;
        `endif
        ARVALID     = 0;
        `ifdef AMBA_AXI4
        ARQOS       = 0;
        ARREGION    = 0;
        `endif
        RREADY      = 0; 
        wait (ARESETn==1'b0);
        wait (ARESETn==1'b1);
        repeat (5) @ (posedge ACLK);
        //-----------------------------------------------------
        rsa2048_Wtest(START_ADDR);
        //read the result of (x^y mod m)
        rsa2048_Rtest(START_ADDR);
        //-----------------------------------------------------
        repeat (10) @ (posedge ACLK);
        $finish(0);
    end
    //-----------------------------------------------------------
    `include "bfm_axi_tasks.v"
    `include "bfm_axi_test_tasks.v"


    reg     [31     :0]     data_got;
    reg     [31     :0]     data_burst[0:1023];
    //-----------------------------------------------------
    reg  [2047:0]   me_x = 2048'hABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744;    
    //result =  16a5831ec2bccf96f3dd402cfa8eb055fef8d90b1be065063a3a7d54b4b4401002db743257c5c4a19b6cbe12c20790a189ec1a2974d4dba9a6ff5292f09a4de8a5c125768c671e6ad9eded25be7adcdd0eec2bef085af63512003869d9fc2f976404db8a55b435111a76c802aa74e372c38af53bf484299f14499f54f9c408104de8214a9d05711fded05643b36e2d6bed9d534fa6640d9e6f50b7a54a49de5546dab86f113e9fa0d46919174ac833268bbb3dbf71f2b4971497093e7299e20f919836f876c5cabec8035c83b59488fcc8984848b8501ca07a55850ec8c87347084324500f4e411eb072536ba69903531021a3957bfb7be5f80feab34add3e16
    //-----------------------------------------------------
    task rsa2048_Wtest;
        input [31:0] base_addr;  // start address
    //------------------
        integer i, error;
        reg [31:0] data, got;
    begin
        //write x
        for (i=0; i<(2048/32); i=i+1) begin
            data = me_x[31:0];
            write_task_my(1, (base_addr+8'h10), data, 1, 1, 0);
            me_x = me_x >> 32;
        end
        //start RSA2048
        write_task_my(1, base_addr+0, 32'hffff_ffff, 1, 1, 0); 
        //wait for RSA2048 done
        data_got = 0;
        while(data_got == 0) begin
            read_task_my(1, (base_addr+8'h04), 1, 1, 0, data_got);
        end
    end
    endtask


   // Test scenario comes here.
   task rsa2048_Rtest;
        input [31:0] base_addr;  // start address
	//------------------
        integer i;
        reg [31:0] got;
        reg [2047 : 0] data_received;
        begin
            for (i=0; i<2048/32; i=i+1) begin
                read_task_my(1, (base_addr+8'h10), 1, 1, 0, got);
                data_received = {got, data_received[2047:32]};
            end
            $display("received data: %x ", data_received);
        end
   endtask

    //----------------------------------------------------------------
    task read_task_my;
        input  [31:0]         id;
        input  [WIDTH_AD-1:0] addr;
        input  [31:0]         size; // 1 ~ 128 byte in a beat
        input  [31:0]         leng; // 1 ~ 16  beats in a burst
        input  [31:0]         type; // burst type
        output [WIDTH_DA-1:0] data;
    begin
        fork
        read_address_channel_my(id,addr,size,leng,type);
        read_data_channel_my(id,addr,data, size,leng,type);
        join
    end
    endtask
    //----------------------------------------------------------------
    task read_address_channel_my;
        input [31:0]         id;
        input [WIDTH_AD-1:0] addr;
        input [31:0]         size; // 1 ~ 128 byte in a beat
        input [31:0]         leng; // 1 ~ 16  beats in a burst
        input [31:0]         type; // burst type
    begin
        @ (posedge ACLK);
        ARID    <= #1 id;
        ARADDR  <= #1 addr;
        ARLEN   <= #1 leng-1;
        ARLOCK  <= #1 'b0;
        ARSIZE  <= #1 get_size(size);
        ARBURST <= #1  type[1:0];
        `ifdef AMBA_AXI_PROT
        ARPROT  <= #1 'h0; // data, secure, normal
        `endif
        ARVALID <= #1 'b1;
        @ (posedge ACLK);
        while (ARREADY==1'b0) @ (posedge ACLK);
        ARVALID <= #1 'b0;
        @ (negedge ACLK);
    end
    endtask
    //----------------------------------------------------------------
    task read_data_channel_my;
        input [31:0]         id;
        input [WIDTH_AD-1:0] addr;
        output [WIDTH_DA-1:0] data;
        input [31:0]         size; // 1 ~ 128 byte in a beat
        input [31:0]         leng; // 1 ~ 16  beats in a burst
        input [31:0]         type; // burst type
        reg   [WIDTH_AD-1:0] naddr;
        reg   [WIDTH_DS-1:0] strb;
        reg   [WIDTH_DA-1:0] maskT;
        reg   [WIDTH_DA-1:0] dataR;
        integer idx, idy, idz;
    begin
        idz = 0;
        naddr  = addr;
        @ (posedge ACLK);
        RREADY <= #1 1'b1;
        for (idx=0; idx<leng; idx=idx+1) begin
            @ (posedge ACLK);
            while (RVALID==1'b0) @ (posedge ACLK);
            strb = get_strb(naddr, size);
            data = RDATA;
            // dataR = RDATA;
            // for (idy=0; idy<WIDTH_DS; idy=idy+1) begin
            //     //if (strb[idy]) dataRB[naddr-addr+idy] = dataR&8'hFF;
            //     if (strb[idy]) begin
            //         dataRB[idz] = dataR&8'hFF; // justified
            //         idz = idz + 1;
            //     end
            //     dataR = dataR>>8;
            // end
            if (id!=RID) begin
                $display($time,,"%m Error id/RID mis-match for read-data-channel", id, RID);
            end
            if (idx==leng-1) begin
                if (RLAST==1'b0) begin
                    $display($time,,"%m Error RLAST expected for read-data-channel");
                end
            end else begin
                @ (negedge ACLK);
                naddr = get_next_addr( naddr  // current address
                                    , size  // num of bytes in a beat
                                    , type);// type of burst
            end
        end
        RREADY <= #1 'b0;
        @ (negedge ACLK);
    end
    endtask





    //----------------------------------------------------------------
    task write_task_my;
        input [31:0]         id;
        input [WIDTH_AD-1:0] addr;
        input [WIDTH_DA-1:0] data;
        input [31:0]         size; // 1 ~ 128 byte in a beat
        input [31:0]         leng; // 1 ~ 16  beats in a burst
        input [31:0]         type; // burst type
    begin
        fork
        write_address_channel_my(id,addr,size,leng,type);
        write_data_channel_my(id,addr,data,size,leng,type);
        write_resp_channel_my(id);
        join
    end
    endtask
    //----------------------------------------------------------------
    task write_address_channel_my;
        input [31:0]         id;
        input [WIDTH_AD-1:0] addr;
        input [31:0]         size; // 1 ~ 128 byte in a beat
        input [31:0]         leng; // 1 ~ 16  beats in a burst
        input [31:0]         type; // burst type
    begin
        @ (posedge ACLK);
        AWID    <= #1 id;
        AWADDR  <= #1 addr;
        AWLEN   <= #1 leng-1;
        AWLOCK  <= #1 'b0;
        AWSIZE  <= #1 get_size(size);
        AWBURST <= #1  type[1:0];
        `ifdef AMBA_AXI_PROT
        AWPROT  <= #1 'h0; // data, secure, normal
        `endif
        AWVALID <= #1 'b1;
        @ (posedge ACLK);
        while (AWREADY==1'b0) @ (posedge ACLK);
        AWVALID <= #1 'b0;
        @ (negedge ACLK);
    end
    endtask
    //----------------------------------------------------------------
    task write_data_channel_my;
        input [31:0]         id;
        input [WIDTH_AD-1:0] addr;
        input [WIDTH_DA-1:0] data;
        input [31:0]         size; // 1 ~ 128 byte in a beat
        input [31:0]         leng; // 1 ~ 16  beats in a burst
        input [31:0]         type; // burst type
        reg   [WIDTH_AD-1:0] naddr;
        integer idx;
    begin
        naddr  = addr;
        @ (posedge ACLK);
        WID    <= #1 id;
        WVALID <= #1 1'b1;
        for (idx=0; idx<leng; idx=idx+1) begin
            WDATA <= #1 data;
            WSTRB <= #1 get_strb(naddr, size);
            WLAST <= #1 (idx==(leng-1));
            naddr <= get_next_addr(naddr, size, type);
            @ (posedge ACLK);
            while (WREADY==1'b0) @ (posedge ACLK);
        end
        WLAST  <= #1 'b0;
        WVALID <= #1 'b0;
        @ (negedge ACLK);
    end
    endtask
    //----------------------------------------------------------------
    task write_resp_channel_my;
        input [31:0] id;
    begin
        BREADY <= #1 'b1;
        @ (posedge ACLK);
        while (BVALID==1'b0) @ (posedge ACLK);
        if (id!=BID) begin
            $display($time,,"%m Error id mis-match for write-resp-channel 0x%x/0x%x", id, BID);
        end else begin
            case (BRESP)
            2'b00: begin
                    `ifdef DEBUG
                    $display($time,,"%m OK response for write-resp-channel: OKAY");
                    `endif
                    end
            2'b01: $display($time,,"%m OK response for write-resp-channel: EXOKAY");
            2'b10: $display($time,,"%m Error response for write-resp-channel: SLVERR");
            2'b11: $display($time,,"%m Error response for write-resp-channel: DECERR");
            endcase
        end
        BREADY <= #1 'b0;
        @ (negedge ACLK);
    end
    endtask
    //-----------------------------------------------------------
    function integer clogb2;
    input [31:0] value;
    begin
    value = value - 1;
    for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
        value = value >> 1;
    end
    endfunction
    //-----------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2013.02.03: Started by Ando Ki (adki@dynalith.com)
//----------------------------------------------------------------
