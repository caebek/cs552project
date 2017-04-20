module decodeStage(instrIn, instrOut, nextPcIn, nextPcOut, err, regWrtData, regWrtEn, regWrtAddr, halt, 
	sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB, return, cin, memToReg,
	writeReg, aluSrc, regWrtSrc, brType, aluOp, reg1Data, reg2Data, clk, rst, stall, doBranch, hazStall);
	

	// signals from writeback stage
	input regWrtEn, hazStall;
	input [2:0] regWrtAddr;
	input [15:0] regWrtData;



	input clk, rst, stall, doBranch;

	// Pass through sigs
	input [15:0] nextPcIn, instrIn;


	// outputs originating from this module
	output err, halt, sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB,
		return, cin, memToReg;
	output [2:0] aluSrc, regWrtSrc, brType, writeReg;
	output [3:0] aluOp;
	output [15:0] reg1Data, reg2Data;

	// Pass through outputs
	output [15:0] nextPcOut, instrOut;

	reg hasErr;
	reg [2:0] intWriteReg;


	wire regErr, intCtrlErr;
	wire [1:0] regDst;
	wire [2:0] read1Sel, read2Sel;

	// Internal wires that input into the flip flops
	wire intErr, intHalt, intSign, intPcOffSel, intRegWrt, intMemWrt, intMemEn, intJump, intInvA, intInvB,
		intReturn, intCin, intMemToReg, ffRst, tempRegWrt, tempMemWrt, tempMemEn, tempJump, tempHalt;
	wire [2:0] intAluSrc, intRegWrtSrc, intBrType;
	wire [3:0] intAluOp;
	wire [15:0] intReg1Data, intReg2Data, tempInstr, iOut, nPC;



	assign intErr = |hasErr | regErr | intCtrlErr;
	// assign nextPcOut = nextPcIn;
	// assign instrOut = instrIn;

	controlBlock ctrlBlk(.opCode(instrIn[15:11]), .func(instrIn[1:0]), 
		.halt(intHalt), .sign(intSign), .pcOffSel(intPcOffSel), 
		.regWrt(intRegWrt), .memWrt(intMemWrt), .memToReg(intMemToReg), .memEn(intMemEn), 
		.jump(intJump), .invA(intInvA), .invB(intInvB), .aluSrc(intAluSrc), .err(intCtrlErr), 
		.regDst(regDst), .regWrtSrc(intRegWrtSrc), .aluOp(intAluOp), .cin(intCin), 
		.return(intReturn), .brType(intBrType), .stall(stall));


	// determine which reg to write to here but we need to pass
	// through the pipeline so it happens in order
	// could possibly move this to another stage if that makes sense
	always@(*) begin
		hasErr = 0;
		case(regDst)
			2'h0: intWriteReg = instrIn[7:5];
			2'h1: intWriteReg = instrIn[10:8];
			2'h2: intWriteReg = instrIn[4:2];
			2'h3: intWriteReg = 3'h7;
			default: hasErr = 1'h1;
		endcase
	end

	assign read1Sel = instrIn[10:8];
	assign read2Sel = instrIn[7:5];

	rf_bypass register(.read1data(intReg1Data), .read2data(intReg2Data), .err(regErr), 
		.clk(clk), .rst(rst), .read1regsel(read1Sel), .read2regsel(read2Sel), 
		.writeregsel(regWrtAddr), .writedata(regWrtData), .write(regWrtEn));


	assign tempInstr = /*(hazStall) ? 16'h0800 : */instrIn;
	// assign instrOut = s iOut;

	assign nPc = nextPcIn;
	
	dffEn fPC[15:0](.d(nPc), .q(nextPcOut), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn fInst[15:0](.d(tempInstr), .q(instrOut), .clk(clk), .rst(rst), .en(~stall | hazStall));
	dffEn reg1F[15:0](.d(intReg1Data), .q(reg1Data), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn reg2F[15:0](.d(intReg2Data), .q(reg2Data), .clk(clk), .rst(ffRst), .en(~stall));

	// important sigs to change during stall
	// halt
	// regWrt
	// memWrt
	// memEn
	// jump

	assign halt = stall ? 1'h0 : tempHalt;
	assign regWrt = stall ? 1'h0 : tempRegWrt;
	assign memWrt = hazStall ? tempMemWrt : stall ? 1'h0 : tempMemWrt;
	assign memEn = hazStall ? tempMemEn : stall ? 1'h0 : tempMemEn;
	assign jump = stall ? 1'h0 : tempJump;


	// assign  = hazStall ? 16'h0800 : iOut;

	dffEn haltF(.d(intHalt & ~(nextPcIn == 16'h0)), .q(tempHalt), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn errF(.d(intErr), .q(err), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn signF(.d(intSign), .q(sign), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn pcOffF(.d(intPcOffSel), .q(pcOffSel), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn regWrtF(.d(intRegWrt), .q(tempRegWrt), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn memWrtF(.d(intMemWrt), .q(tempMemWrt), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn memEnF(.d(intMemEn), .q(tempMemEn), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn jmpF(.d(intJump), .q(tempJump), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn invAF(.d(intInvA), .q(invA), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn invBF(.d(intInvB), .q(invB), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn retF(.d(intReturn), .q(return), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn cinF(.d(intCin), .q(cin), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn mem2RF(.d(intMemToReg), .q(memToReg), .clk(clk), .rst(ffRst), .en(~stall));


	dffEn aluSrcF[2:0] (.d(intAluSrc), .q(aluSrc), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn regWrtSrcF[2:0] (.d(intRegWrtSrc), .q(regWrtSrc), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn brTyF[2:0] (.d(intBrType), .q(brType), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn wrtRegF[2:0] (.d(intWriteReg), .q(writeReg), .clk(clk), .rst(ffRst), .en(~stall));


	dffEn aluOpF[3:0] (.d(intAluOp), .q(aluOp), .clk(clk), .rst(ffRst), .en(~stall));

	assign ffRst = rst | doBranch;

endmodule