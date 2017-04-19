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

   	localparam WAIT_REQ = 5'h0;
	localparam CHECK_RD = 5'h1;
	localparam CHECK_WRT = 5'h2;
	localparam ERR = 5'h3;
	localparam iWB_1 = 5'h4;
	localparam iWB_2 = 5'h5;
	localparam iWB_3 = 5'h6;
	localparam iWB_4 = 5'h7;
	localparam iMEM_RD_1 = 5'h8;
	localparam iMEM_RD_2 = 5'h9;
	localparam iMEM_RD_3 = 5'hA;
	localparam iMEM_RD_4 = 5'hB;
	localparam iLOAD_3 = 5'hC;
	localparam iLOAD_4 = 5'hD;
	localparam iCACHE_WRT = 5'hE;
	localparam iWAIT_2 = 5'hF;

	localparam dWB_1 = 5'h14;
	localparam dWB_2 = 5'h15;
	localparam dWB_3 = 5'h16;
	localparam dWB_4 = 5'h17;
	localparam dMEM_RD_1 =5'h18;
	localparam dMEM_RD_2 = 5'h19;
	localparam dMEM_RD_3 = 5'h1A;
	localparam dMEM_RD_4 = 5'h1B;
	localparam dLOAD_3 = 5'h1C;
	localparam dLOAD_4 = 5'h1D;
	localparam dCACHE_WRT = 5'h1E;
	localparam dWAIT_2 = 5'h1F;



	reg [4:0] nextState;
	wire [4:0] curState;
	reg hasErr;


	reg validIn, iComp, iCacheWrt, dComp, dCacheWrt, memRd, memWrt, done, stall, needData, intHit;
	reg [1:0] cacheOrMem;
	reg [2:0] cacheOff, memOff;
	// reg [3:0] offset;
	reg [4:0] tagIn;
	reg [7:0] index;
	reg [15:0] cacheIn, memIn, memAddr;


	wire iHit, dHit, iDirty, dDirty,  iValid, dValid,  iCacheErr, dCacheErr, memStall, memErr, useData, intWay, way, hit, dirty, valid, victim, wasRdWrt;
	wire [15:0] iCacheOut, dCacheOut, memOut, writeData;
	wire [4:0] iTagOut, dTagOut; 

	assign err = iCacheErr | dCacheErr | memErr | (|hasErr);
	// assign CacheHit = hit;// & valid;
	assign Done = done;
	assign Stall = stall;

	assign victim = (~iValid & ~dValid) ? 1'h0 : //both invalid
					(~iValid) ? 1'h0 : // just i invalid
					(~dValid) ? 1'h1 : // just d invalid
					intWay; // both valid, so "randomly" pick

  cache #(0 + memtype) c0(// Outputs
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
							.comp                 (iComp),
							.write                (iCacheWrt),
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
                          .comp                 (dComp),
                          .write                (dCacheWrt),
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


	assign hit = iHit | dHit;
	assign valid = iValid | dValid;
	assign dirty = iDirty | dDirty;

	always@(*) begin
		cacheOrMem = 2'b00; // 01 mem 10 cache, 11 err, 00 DataOut = 0 
		hasErr = 1'h0;
		done = 0;
		stall = 0;
		iComp = 1'h0;
		dComp = 1'h0;
		iCacheWrt = 1'h0;
		dCacheWrt = 1'h0;
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
					needData = hit & valid;//(iHit & iValid) | (dHit & dValid);

					iComp = 1'h1;
					dComp = 1'h1;
					// done = hit & valid;
					// TODO maybe no valid
					done = 1'h0;
					stall = 1'h1;
					intHit = hit & valid;//(iHit & iValid) | (dHit & dValid);
					// stall	= ~(hit & valid);
					// DataOut	 = done ? (iHit & iValid) ? iCacheOut : dCacheOut : 16'h0;
					// nextState = (hit & valid & Rd & ~Wr) ? CHECK_RD : 
					// 				(hit & valid & ~Rd & Wr) ? CHECK_WRT :
					// 				(hit & valid & ~Rd & ~Wr) ? WAIT_REQ : 
					// 				(~hit & valid & dirty) ? WB_1 :
					// 				MEM_RD_1;
					// nextState = (hit & valid) ? WAIT_2 : 
					// 				(~hit & valid & dirty) ? WB_1 :
					// 				MEM_RD_1;

					nextState = (iHit & iValid) ? iWAIT_2 :
								(dHit & dValid) ? dWAIT_2 :
								(victim) ? 
									(dValid & dDirty) ? dWB_1 : dMEM_RD_1: 
									(iValid & iDirty) ? iWB_1 : iMEM_RD_1 ;


								// (~iHit & iValid & iDirty & (~dValid | dValid & ~dDirty)) ? dMEM_RD_1 : 
								// (~dHit & dValid & dDirty) ? dWB_1 :
								// (victim) ? dMEM_RD_1 : iMEM_RD_1; 

			end
			CHECK_WRT: begin
				iComp = 1'h1;
				dComp = 1'h1;
				cacheIn	= writeData;
				iCacheWrt = 1'h1;
				dCacheWrt = 1'h1;
				// needData = 1'h0;
				// TODO Maybe not here
				needData = hit & valid;//iHit & iValid; 

				//TODO maybe no valid
				intHit = hit & valid;//(iHit & iValid) | (dHit & dValid);
				done = 1'h0;
				stall = 1'h1;
				// nextState = (hit & valid & Rd & ~Wr) ? CHECK_RD : 
				// 				(hit & valid & ~Rd & Wr) ? CHECK_WRT :
				// 				(hit & valid & ~Rd & ~Wr) ? WAIT_REQ : 
				// 				(~hit & valid & dirty) ? WB_1 :
				// 				MEM_RD_1;

				// nextState = (hit & valid) ? WAIT_2 :
				// 				(~hit & valid & dirty) ? WB_1 : 
				// 				MEM_RD_1;
				// nextState = (iHit & iValid) ? iWAIT_2 :
				// 			(dHit & dValid) ? dWAIT_2 :
				// 			(~iHit & iValid & iDirty) ? iWB_1 : 
				// 			(~dHit & dValid & dDirty) ? dWB_1 :
				// 			(victim) ? dMEM_RD_1 : iMEM_RD_1;
				nextState = (iHit & iValid) ? iWAIT_2 :
							(dHit & dValid) ? dWAIT_2 :
							(victim) ? 
								(dValid & dDirty) ? dWB_1 : dMEM_RD_1: 
								(iValid & iDirty) ? iWB_1 : iMEM_RD_1 ;

			end
			iWB_1: begin
				memWrt = 1'h1;
				memOff = 3'b000;
				cacheOff = 3'b000;
				memIn = iCacheOut;
				memAddr = {iTagOut, index, memOff};
				nextState = iWB_2;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
				
			end
			iWB_2: begin
				memWrt = 1'h1;
				memOff = 3'b010;
				cacheOff = 3'b010;
				memIn = iCacheOut;
				// memAddr = {iTagOut, index, memOff} : {dTagOut, index, memOff};
				memAddr = {iTagOut, index, memOff};
				nextState = iWB_3;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			iWB_3: begin
				
				memWrt = 1'h1;
				memOff = 3'b100;
				cacheOff = 3'b100;
				memIn = iCacheOut;
				// memAddr = {iTagOut, index, memOff};
				memAddr = {iTagOut, index, memOff};

				nextState = iWB_4;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			iWB_4: begin
				
				memWrt = 1'h1;
				memOff = 3'b110;
				cacheOff = 3'b110;
				memIn = iCacheOut;
				memAddr = {iTagOut, index, memOff};
				nextState = iMEM_RD_1;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			iMEM_RD_1: begin
				memRd = 1'h1;

				done = 1'h0;
				stall = 1'h1;
				memOff = 3'b000;

				memAddr = {tagIn, index, memOff};
				needData = 1'h0;


				nextState = iMEM_RD_2;

			end
			iMEM_RD_2: begin
				memRd = 1'h1;

				done = 1'h0;
				stall = 1'h1;
				memOff = 3'b010;
				memAddr = {tagIn, index, memOff};
				needData = 1'h0;


				nextState = iMEM_RD_3;
				
			end		
			iMEM_RD_3: begin
				memRd = 1'h1;
				iCacheWrt = 1'h1;

				memOff = 3'b100;
				cacheOff = 3'b000;
				needData = 1'h0;

				memAddr = {tagIn, index, memOff};

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;

				// memIn = iCacheOut;
				nextState = iMEM_RD_4;
			end
			iMEM_RD_4: begin
				memRd = 1'h1;
				iCacheWrt = 1'h1;

				memOff = 3'b110;
				cacheOff = 3'b010;

				memAddr = {tagIn, index, memOff};

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;
				needData = 1'h0;

				// memIn = iCacheOut;
				nextState = iLOAD_3;
				
			end
			iLOAD_3: begin
				// memRd = 1'h1;
				iCacheWrt = 1'h1;

				cacheOff = 3'b100;
				// memAddr = {iTagOut, index, offset};
				needData = 1'h0;

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;
				needData = 1'h0;


				// memIn = iCacheOut;
				nextState = iLOAD_4;
				
			end
			iLOAD_4: begin
				// memRd = 1'h1;
				iCacheWrt = 1'h1;

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

				nextState = (Rd & ~Wr) ? iWAIT_2 : 
						  (Wr & ~Rd) ? iCACHE_WRT :
						  (~Wr & ~Rd) ? iWAIT_2 : ERR; 
						  // (~Wr & ~Rd) ? WAIT_REQ : ERR;
				
				
			end
			iCACHE_WRT: begin
				iCacheWrt = 1'h1;
				iComp = 1'h1;
				// offset = 3'b100;
				// memAddr = {iTagOut, index, offset};
				needData = 1'h0;

				cacheIn = DataIn;
				// done = 1'h1;
				done = 1'h0;
				// stall = 1'h0;
				stall = 1'h1;
				
				// nextState = {Wr, Rd};
				nextState = iWAIT_2;
				// validIn = 1'h1;
				
			end
			iWAIT_2: begin
				done = 1'h1;
				stall = 1'h0;
				// CacheHit = hit & valid;
				nextState = {Wr,Rd};
				DataOut = useData ? iCacheOut : 16'h0;
				needData = 1'h0;
			end


			/**************************************************************************/
			dWB_1: begin
				memWrt = 1'h1;
				memOff = 3'b000;
				cacheOff = 3'b000;
				memIn = dCacheOut;
				memAddr = {dTagOut, index, memOff};
				nextState = dWB_2;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
				
			end
			dWB_2: begin
				memWrt = 1'h1;
				memOff = 3'b010;
				cacheOff = 3'b010;
				memIn = dCacheOut;
				// memAddr = {iTagOut, index, memOff} : {dTagOut, index, memOff};
				memAddr = {dTagOut, index, memOff};
				nextState = dWB_3;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			dWB_3: begin
				
				memWrt = 1'h1;
				memOff = 3'b100;
				cacheOff = 3'b100;
				memIn = dCacheOut;
				// memAddr = {iTagOut, index, memOff};
				memAddr = {dTagOut, index, memOff};

				nextState = dWB_4;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			dWB_4: begin
				
				memWrt = 1'h1;
				memOff = 3'b110;
				cacheOff = 3'b110;
				memIn = dCacheOut;
				memAddr = {dTagOut, index, memOff};
				nextState = dMEM_RD_1;
				needData = 1'h0;

				done = 1'h0;
				stall = 1'h1;
			end
			dMEM_RD_1: begin
				memRd = 1'h1;

				done = 1'h0;
				stall = 1'h1;
				memOff = 3'b000;

				memAddr = {tagIn, index, memOff};
				needData = 1'h0;


				nextState = dMEM_RD_2;

			end
			dMEM_RD_2: begin
				memRd = 1'h1;

				done = 1'h0;
				stall = 1'h1;
				memOff = 3'b010;
				memAddr = {tagIn, index, memOff};
				needData = 1'h0;


				nextState = dMEM_RD_3;
				
			end		
			dMEM_RD_3: begin
				memRd = 1'h1;
				dCacheWrt = 1'h1;

				memOff = 3'b100;
				cacheOff = 3'b000;
				needData = 1'h0;

				memAddr = {tagIn, index, memOff};

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;

				// memIn = iCacheOut;
				nextState = dMEM_RD_4;
			end
			dMEM_RD_4: begin
				memRd = 1'h1;
				dCacheWrt = 1'h1;

				memOff = 3'b110;
				cacheOff = 3'b010;

				memAddr = {tagIn, index, memOff};

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;
				needData = 1'h0;

				// memIn = iCacheOut;
				nextState = dLOAD_3;
				
			end
			dLOAD_3: begin
				// memRd = 1'h1;
				dCacheWrt = 1'h1;

				cacheOff = 3'b100;
				// memAddr = {iTagOut, index, offset};
				needData = 1'h0;

				cacheIn = memOut;
				done = 1'h0;
				stall = 1'h1;
				validIn = 1'h0;
				needData = 1'h0;


				// memIn = iCacheOut;
				nextState = dLOAD_4;
				
			end
			dLOAD_4: begin
				// memRd = 1'h1;
				dCacheWrt = 1'h1;

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

				nextState = (Rd & ~Wr) ? dWAIT_2 : 
						  (Wr & ~Rd) ? dCACHE_WRT :
						  (~Wr & ~Rd) ? dWAIT_2 : ERR; 
						  // (~Wr & ~Rd) ? WAIT_REQ : ERR;
				
				
			end
			dCACHE_WRT: begin
				dCacheWrt = 1'h1;
				dComp = 1'h1;
				// offset = 3'b100;
				// memAddr = {iTagOut, index, offset};
				needData = 1'h0;

				cacheIn = DataIn;
				// done = 1'h1;
				done = 1'h0;
				// stall = 1'h0;
				stall = 1'h1;
				
				// nextState = {Wr, Rd};
				nextState = iWAIT_2;
				// validIn = 1'h1;
				
			end
			dWAIT_2: begin
				done = 1'h1;
				stall = 1'h0;
				// CacheHit = hit & valid;
				nextState = {Wr,Rd};
				DataOut = useData ? dCacheOut : 16'h0;
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

	assign intWay = (Rd | Wr) ? ~way : way;


	dff flop(.d(needData), .q(useData), .clk(clk), .rst(rst));
	dff hitFlop(.d(intHit), .q(CacheHit), .clk(clk), .rst(rst));
	dff stateFlop [4:0](.d(nextState), .q(curState), .clk(clk), .rst(rst));
	dff dataFlop [15:0](.d(DataIn), .q(writeData), .clk(clk), .rst(rst));


	dff victimway (.d(intWay), .q(way), .clk(clk), .rst(rst));
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
