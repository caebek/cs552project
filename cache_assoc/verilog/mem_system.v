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
   
   output reg [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;

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
	localparam WAIT_2 = 4'hF;



	reg [3:0] nextState;
	wire [3:0] curState;
	reg hasErr;


	reg validIn, comp, cacheWrt, memRd, memWrt, done, stall, needData, intHit;
	reg [1:0] cacheOrMem;
	reg [2:0] cacheOff, memOff;
	// reg [3:0] offset;
	reg [4:0] tagIn;
	reg [7:0] index;
	reg [15:0] cacheIn, memIn, memAddr;


	wire iHit, dHit, iDirty, dDirty,  iValid, dValid,  iCacheErr, dCacheErr, memStall, memErr, useData, intWay, way;
	wire [15:0] iCacheOut, dCacheOut, memOut, writeData;
	wire [4:0] iTagOut, dTagOut; 

	assign err = iCacheErr | dCacheErr | memErr | (|hasErr);
	// assign CacheHit = hit;// & valid;
	assign Done = done;
	assign Stall = stall;


  cache #(0 + mem_type) c0(// Outputs
							.tag_out              (iTagOut),
							.data_out             (iCacheOut),
							.hit                  (iHit),
							.dirty                (iDirty),
							.valid                (iValid),
							.err                  (iCacheErr),
							// Inputs
							.enable               (1'h1),
							.clk                  (clk),
							.rst                  (rst),
							.createdump           (createdump),
							.tag_in               (tagIn),
							.index                (index),
							.offset               (cacheOff),
							.data_in              (cacheIn),
							.comp                 (comp),
							.write                (cacheWrt),
							.valid_in             (validIn));

   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (dTagOut),
                          .data_out             (dCacheOut),
                          .hit                  (dHit),
                          .dirty                (dDirty),
                          .valid                (dValid),
                          .err                  (dCacheErr),
                          // Inputs
                          .enable               (1'h1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
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
							.createdump        (createdump),
							.addr              (memAddr),
							.data_in           (memIn),
							.wr                (memWrt),
							.rd                (memRd));



	// cache miss and valid data 

	// your code here
	always@(*) begin
		cacheOrMem = 2'b00; // 01 mem 10 cache, 11 err, 00 DataOut = 0 
		hasErr = 1'h0;
		done = 0;
		stall = 0;
		comp = 1'h0;
		cacheWrt = 1'h0;
		index = Addr[10:3];
		tagIn = Addr[15:11];
		cacheOff = Addr[2:0];
		DataOut = 16'h0;
		cacheIn = 16'h0;
		memRd = 1'h0;
		memWrt = 1'h0;
		memIn = 16'h0;
		memAddr = 16'h0;
		intHit = 1'h0;
		// CacheHit = 1'h0;
		case(curState)
			WAIT_REQ: begin
				nextState = {Wr, Rd};
				needData = 1'h0;

			end
			CHECK_RD: begin
					// index = Addr[10:3];
					// Tag_In = Addr[15:11];
					// cacheOff = Addr[2:0];
					needData = iHit & iValid;

					comp = 1'h1;
					// done = hit & valid;
					// TODO maybe no valid
					done = 1'h0;
					stall = 1'h1;
					intHit = (iHit & iValid) | (dHit & dValid);
					// stall	= ~(hit & valid);
					DataOut	 = done ? (iHit & iValid) ? iCacheOut : dCacheOut : 16'h0;
					// nextState = (hit & valid & Rd & ~Wr) ? CHECK_RD : 
					// 				(hit & valid & ~Rd & Wr) ? CHECK_WRT :
					// 				(hit & valid & ~Rd & ~Wr) ? WAIT_REQ : 
					// 				(~hit & valid & dirty) ? WB_1 :
					// 				MEM_RD_1;
					nextState = (iHit & iValid) ? WAIT_2 : 
									(~iHit & iValid & iDirty) ? WB_1 :
									MEM_RD_1;
			end
			CHECK_WRT: begin
				comp = 1'h1;
				cacheIn	= writeData;
				cacheWrt	= 1'h1;
				// needData = 1'h0;
				// TODO Maybe not here
				needData = iHit & iValid; 

				//TODO maybe no valid
				intHit = (iHit & iValid) | (dHit & dValid);
				done = 1'h0;
				stall = 1'h1;
				// nextState = (hit & valid & Rd & ~Wr) ? CHECK_RD : 
				// 				(hit & valid & ~Rd & Wr) ? CHECK_WRT :
				// 				(hit & valid & ~Rd & ~Wr) ? WAIT_REQ : 
				// 				(~hit & valid & dirty) ? WB_1 :
				// 				MEM_RD_1;

				nextState = (iHit & iValid) ? WAIT_2 :
								(~iHit & iValid & iDirty) ? WB_1 : 
								MEM_RD_1;
			end
			WB_1: begin
				memWrt = 1'h1;
				memOff = 3'b000;
				cacheOff = 3'b000;
				memIn = iCacheOut;
				memAddr = {iTagOut, index, memOff};
				nextState = WB_2;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
				
			end
			WB_2: begin
				memWrt = 1'h1;
				memOff = 3'b010;
				cacheOff = 3'b010;
				memIn = iCacheOut;
				memAddr = {iTagOut, index, memOff};
				nextState = WB_3;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			WB_3: begin
				
				memWrt = 1'h1;
				memOff = 3'b100;
				cacheOff = 3'b100;
				memIn = iCacheOut;
				memAddr = {iTagOut, index, memOff};
				nextState = WB_4;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			WB_4: begin
				
				memWrt = 1'h1;
				memOff = 3'b110;
				cacheOff = 3'b110;
				memIn = iCacheOut;
				memAddr = {iTagOut, index, memOff};
				nextState = MEM_RD_1;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			MEM_RD_1: begin
				memRd = 1'h1;

				done = 1'h0;
				stall = 1'h1;
				memOff = 3'b000;

				memAddr = {tagIn, index, memOff};
				needData = 1'h0;


				nextState = MEM_RD_2;

			end
			MEM_RD_2: begin
				memRd = 1'h1;

				done = 1'h0;
				stall = 1'h1;
				memOff = 3'b010;
				memAddr = {tagIn, index, memOff};
				needData = 1'h0;


				nextState = MEM_RD_3;
				
			end		
			MEM_RD_3: begin
				memRd = 1'h1;
				cacheWrt = 1'h1;

				memOff = 3'b100;
				cacheOff = 3'b000;
				needData = 1'h0;

				memAddr = {tagIn, index, memOff};

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;

				// memIn = iCacheOut;
				nextState = MEM_RD_4;
			end
			MEM_RD_4: begin
				memRd = 1'h1;
				cacheWrt = 1'h1;

				memOff = 3'b110;
				cacheOff = 3'b010;

				memAddr = {tagIn, index, memOff};

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;
				needData = 1'h0;

				// memIn = iCacheOut;
				nextState = LOAD_3;
				
			end
			LOAD_3: begin
				// memRd = 1'h1;
				cacheWrt = 1'h1;

				cacheOff = 3'b100;
				// memAddr = {iTagOut, index, offset};
				needData = 1'h0;

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;
				needData = 1'h0;


				// memIn = iCacheOut;
				nextState = LOAD_4;
				
			end
			LOAD_4: begin
				// memRd = 1'h1;
				cacheWrt = 1'h1;

				cacheOff = 3'b110;
				// memAddr = {iTagOut, index, offset};

				cacheIn = memOut;
				// done = Rd & ~Wr;
				done = 1'h0;
				// stall = Wr & ~Rd;
				stall = 1'h1;
				validIn = 1'h1;
				// DataOut = (Rd & ~Wr) ? iCacheOut : 16'h0;
				needData = 1'h1;
				nextState = {Wr, Rd};

				nextState = (Rd & ~Wr) ? WAIT_2 : 
						  (Wr & ~Rd) ? CACHE_WRT :
						  (~Wr & ~Rd) ? WAIT_2 : ERR; 
						  // (~Wr & ~Rd) ? WAIT_REQ : ERR;
				
				
			end
			CACHE_WRT: begin
				cacheWrt = 1'h1;
				comp = 1'h1;
				// offset = 3'b100;
				// memAddr = {iTagOut, index, offset};
				needData = 1'h0;

				cacheIn = DataIn;
				// done = 1'h1;
				done = 1'h0;
				// stall = 1'h0;
				stall = 1'h1;
				
				// nextState = {Wr, Rd};
				nextState = WAIT_2;
				// validIn = 1'h1;
				
			end
			WAIT_2: begin
				done = 1'h1;
				stall = 1'h0;
				// CacheHit = hit & valid;
				nextState = {Wr,Rd};
				DataOut = useData ? (iHit & iValid) ? iCacheOut : dCacheOut : 16'h0;
				needData = 1'h0;
			end
			ERR: begin
				needData = 1'h0;
				hasErr = 1'h1;
				nextState = WAIT_REQ;
			end
			default: hasErr = 1'h1;
		endcase
	end


	always @ (*) begin
		

	end







	dff flop(.d(needData), .q(useData), .clk(clk), .rst(rst));
	dff hitFlop(.d(intHit), .q(CacheHit), .clk(clk), .rst(rst));
	dff stateFlop [3:0](.d(nextState), .q(curState), .clk(clk), .rst(rst));
	dff dataFlop [15:0](.d(DataIn), .q(writeData), .clk(clk), .rst(rst));


	dff victimway (.d(intWay), .q(way), .clk(clk), .rst(rst));
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
