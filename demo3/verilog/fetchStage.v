module fetchStage(clk, rst, halt, doBranch, branchPc, nextPc, instr, stall, err, stallOut, flushPipe);
	input clk, rst, halt, doBranch, stall, flushPipe;
	input [15:0] branchPc;
	output err, stallOut;
	output [15:0] instr, nextPc;

	wire done, intMemStall, memErr, intStall, willBr, needBr;
	wire [15:0] pcToIncr, curPc, preInstr, tempInstr, tempCurInstr, actInstr, pcIncr, nPc, addr, intNextPc, brPc, intBrPc;


	reg hasErr;
	reg [15:0] usePc;

	assign memStall =  intMemStall;

	// assign stallOut = memStall;
	// assign stallOut = stall | memStall;



	assign err = memErr;//hasErr | memErr;

	// dont update pc if we are halting or stalling 

	// if halt = 1 -> mem wEn = 0
	// if stall = 1 -> mem wEn = 0


	register pcReg(.clk(clk), .rst(rst), .wData(nPc), .rData(curPc), .wEn( (~halt & done) | doBranch));
	stallmem iMem(.DataOut(preInstr), .Done(done), .Stall(intMemStall), .CacheHit(iCacheHit), .err(memErr), 
		.Addr(pcToIncr), .Rd(1'h1), .Wr(1'h0), .createdump(halt), .clk(clk), .rst(rst), .DataIn(usePc));
	// incr2 incrPC(.in(usePc), .out(preNextPc));
	incr2 incrPC(.in(pcToIncr), .out(pcIncr));

	// assign newPc = (doBranch) ? branchPc : tempNextPc;

	/* pcReg =  branchPc if doBranch
				curPc if stall
				preNextPc else
				branchPc if doBranch & stall
	*/


	// maybe need this for cache
	// assign addr = (done) ? pcIncr : pcToIncr;





	// assign pcToIncr = (needBr | doBranch) ? branchPc : curPc;


	assign pcToIncr = (needBr) ? brPc :
						(doBranch) ? branchPc : 
						curPc;

	// assign usePc = (doBranch) ? branchPc : curPc;

	// if branch, pcToIncr needs to be branchPC
	// else needs to be curPc

	// nextPc
	assign nPc = (stall) ? curPc : pcIncr;
	assign intNextPc = (~done) ? nextPc : nPc;

	dffEn fPC[15:0](.d(intNextPc), .q(nextPc), .clk(clk), .rst(rst), .en(done));
	dffEn fInst[15:0](.d(preInstr), .q(tempInstr), .clk(clk), .rst(rst), .en(done));
	

	assign instr = (doBranch) ? 16'h0800 : tempInstr; // prevents us from getting a halt while everything is resetting



	// if stall pc we fetch is same as last cycle (usePc)
	// else its either pcIncr or branchPc (depending on branch)


	// always@(*) begin
	//     hasErr = 1'h0;
	//     case({doBranch, intStall})
	//         2'b00: usePc = pcIncr;
	//         2'b01: usePc = curPc;
	//         2'b10: usePc = branchPc;
	//         2'b11: usePc = branchPc;
	//         default: hasErr = 1'h1;
	//     endcase

	// end

	// if branch lookup instruction at branchPC instead of curPC
	// assign usePc = (doBranch) ? branchPc : curPc;

	// newPc is the next pc we will push through pipeline
	// preNextPc is curPc + 2 or the next instruction
	// tempNextPc is either curPc + 2 or curPc, depending on if we stall


	// if doing branch, need newPc = branchPC

	// if we are going to stall, we want to keep the pc the same (nops are inserted in decode stage)
	// assign tempNextPc = (stall) ? usePc : preNextPc;
	// assign actInstr = (stall) ? tempInstr : preInstr;
	//assign tempCurInstr = stall ? preInstr: tempInstr;

	// if we are take a branch we need to clear the pipeline
	// when doBranch = 1, preInstr needs to be instr at 
	assign willBr = (~done) ? needBr | doBranch : doBranch;
	

	assign intBrPc	 = (doBranch) ? branchPc : 
						(~done) ? brPc : 
						branchPc;

	dffEn brPF[15:0](.d(intBrPc), .q(brPc), .clk(clk), .rst(rst), .en(1'h1));
	

	dff brF(.d(willBr), .q(needBr), .clk(clk), .rst(rst));
	dff memStallF(.d(memStall), .q(stallOut), .clk(clk), .rst(rst));
	// assign instr = (flushPipe) ? 16'h0800 : actInstr;
	// assign instr = tempInstr;
   // assign haltEn = preInstr == 16'h0;

endmodule
