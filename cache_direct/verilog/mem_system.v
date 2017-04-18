/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
	// Outputs
	DataOut, Done, Stall, CacheHit, err,
	// Inputs
	Addr, DataIn, Rd, Wr, createdump, clk, rst
	);
	
	input [15:0] Addr;
	input [15:0] DataIn;
	input        Rd;
	input        Wr;
	input        createdump;
	input        clk;
	input        rst;
	
	output [15:0] DataOut;
	output Done;
	output Stall;
	output CacheHit;
	output err;

	/* data_mem = 1, inst_mem = 0 *
	 * needed for cache parameter */
	parameter mem_type = 0;


	localparam WAIT_REQ = 4'h0;
	localparam CHECK_RD = 4'h1;
	localparam CHECK_WRT = 4'h2;
	localparam ERR = 4'h3;
	localparam WB_1 = 4'h4;
	localparam WB_2 = 4'h5;
	localparam WB_3 = 4'h6;
	localparam WB_4 = 4'h7;
	localparam MEM_RD_1 =4'h8;
	localparam MEM_RD_2 = 4'h9;
	localparam MEM_RD_3 = 4'hA;
	localparam MEM_RD_4 = 4'hB;
	localparam LOAD_3 = 4'hC;
	localparam LOAD_4 = 4'hD;
	localparam CACHE_WRT = 4'hE;



	reg [3:0] curState, nextState;
	reg hasErr;


	reg hit, dirty, validOut, validIn, cacheErr, comp, cacheWrt, memRd, memWrt, memStall, memErr;
	reg {2;0] cacheOff;
	reg [3:0] stall;
	reg [4:0] tagOut, tagIn;
	reg [7:0] index;
	reg [15:0] cacheOut, memOut, cacheIn, memIn, memAddr;


	assign err = cacheErr | memErr | (|hasErr);

	



	cache #(0 + mem_type) c0(// Outputs
							.tag_out              (tagOut),
							.data_out             (cacheOut),
							.hit                  (hit),
							.dirty                (dirty),
							.valid                (valid),
							.err                  (cacheErr),
							// Inputs
							.enable               (1'h1),
							.clk                  (clk),
							.rst                  (rst),
							.createdump           (err),
							.tag_in               (tagIn),
							.index                (index),
							.offset               (cacheOff),
							.data_in              (cacheIn),
							.comp                 (comp),
							.write                (cacheWrt),
							.valid_in             (validIn));

	four_bank_mem mem(// Outputs
							.data_out          (memOut),
							.stall             (memStall),
							.busy              (busy),
							.err               (memErr),
							// Inputs
							.clk               (clk),
							.rst               (rst),
							.createdump        (err),
							.addr              (memAddr),
							.data_in           (memIn),
							.wr                (memWrt),
							.rd                (memRd));



	// cache miss and valid data 

	// your code here
	always@(*) begin
		hasErr[0] = 1'h0;
		Done = 0;
		Stall = 0;
		comp = 1'h0;
		cacheWrt = 1'h0;
		memRd = 1'h0;
		memWrt = 1'h0;
		index = Addr[10:3];
		tagIn = Addr[15:11];
		cacheOff = Addr[2:0];
		case(curState)
			WAIT_REQ: begin
					nextState = {WRT, RD};
			end
			CHECK_RD: begin
					// index = Addr[10:3];
					// Tag_In = Addr[15:11];
					// cacheOff = Addr[2:0];
					comp = 1'h1;
					Done = hit & valid;
					Stall	= ~(hit & valid);
					DataOut	 = Done ? cacheOut : 16'h0;
					nextState = (hit & valid) ? WAIT_REQ : 
									(~hit & valid & dirty) ? WB_1 :
									MEM_RD_1;
			end
			CHECK_WRT: begin
				comp = 1'h1;
				cacheIn	= DataIn;
				cacheWrt	= 1'h1;
				Done = hit & valid;
				Stall = ~(hit & valid);
				nextState = (hit & valid) ? WAIT_REQ :
								(~hit & valid & dirty) ? WB_1 : 
								MEM_RD_1;
			end
			WB_1: begin
				memWrt = 1'h1;
				offset = 3'b000;
				memIn = cacheOut;
				memAddr = {tagOut, index, offset};
				nextState = WB_2;
			end
			WB_2: begin
				
			end
			WB_3: begin
				
			end
			WB_4: begin
				
			end
			MEM_RD_1: begin
				
			end
			MEM_RD_2: begin
				
			end
			MEM_RD_3: begin
				
			end
			MEM_RD_4: begin
				
			end
			LOAD_3: begin
				
			end
			LOAD_4: begin
				
			end
			CACHE_WRT: begin
				
			end
			ERR: begin
				
			end
			default: hasErr[0] = 1'h1;
		endcase
	end




	dff [3:0]stateFlop(.d(nextState), .q(curState), .clk(clk), .rst(rst));



	
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
