module decodeStage(instrIn, instrOut, nextPcIn, nextPcOut, err, regWrtData, regWrtEn, regWrtAddr, halt, 
	sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB, return, cin, memToReg,
	writeReg, aluSrc, regWrtSrc, brType, aluOp, reg1Data, reg2Data, clk, rst);
	

	// signals from writeback stage
	input regWrtEn;
	input [2:0] regWrtAddr;
	input [15:0] regWrtData;



	input clk, rst;

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
		intReturn, intCin, intMemToReg;
	wire [2:0] intAluSrc, intRegWrtSrc, intBrType;
	wire [3:0] intAluOp;
	wire [15:0] intReg1Data, intReg2Data;



	assign intErr = |hasErr | regErr | intCtrlErr;
	// assign nextPcOut = nextPcIn;
	// assign instrOut = instrIn;

	controlBlock ctrlBlk(.opCode(instrIn[15:11]), .func(instrIn[1:0]), 
		.halt(intHalt), .sign(intSign), .pcOffSel(intPcOffSel), 
		.regWrt(intRegWrt), .memWrt(intMemWrt), .memToReg(intMemToReg), .memEn(intMemEn), 
		.jump(intJump), .invA(intInvA), .invB(intInvB), .aluSrc(intAluSrc), .err(intCtrlErr), 
		.regDst(regDst), .regWrtSrc(intRegWrtSrc), .aluOp(intAluOp), .cin(intCin), 
		.return(intReturn), .brType(intBrType));


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



	dff fPC[15:0](.d(nextPcIn), .q(nextPcOut), .clk(clk), .rst(rst));
	dff fInst[15:0](.d(instrIn), .q(instrOut), .clk(clk), .rst(rst));
	dff reg1F[15:0](.d(intReg1Data), .q(reg1Data), .clk(clk), .rst(rst));
	dff reg2F[15:0](.d(intReg2Data), .q(reg2Data), .clk(clk), .rst(rst));


	dff haltF(.d(intHalt & ~(nextPcIn == 16'h0)), .q(halt), .clk(clk), .rst(rst));
	dff errF(.d(intErr), .q(err), .clk(clk), .rst(rst));
	dff signF(.d(intSign), .q(sign), .clk(clk), .rst(rst));
	dff pcOffF(.d(intPcOffSel), .q(pcOffSel), .clk(clk), .rst(rst));
	dff regWrtF(.d(intRegWrt), .q(regWrt), .clk(clk), .rst(rst));
	dff memWrtF(.d(intMemWrt), .q(memWrt), .clk(clk), .rst(rst));
	dff memEnF(.d(intMemEn), .q(memEn), .clk(clk), .rst(rst));
	dff jmpF(.d(intJump), .q(jump), .clk(clk), .rst(rst));
	dff invAF(.d(intInvA), .q(invA), .clk(clk), .rst(rst));
	dff invBF(.d(intInvB), .q(invB), .clk(clk), .rst(rst));
	dff retF(.d(intReturn), .q(return), .clk(clk), .rst(rst));
	dff cinF(.d(intCin), .q(cin), .clk(clk), .rst(rst));
	dff mem2RF(.d(intMemToReg), .q(memToReg), .clk(clk), .rst(rst));


	dff aluSrcF[2:0] (.d(intAluSrc), .q(aluSrc), .clk(clk), .rst(rst));
	dff regWrtSrcF[2:0] (.d(intRegWrtSrc), .q(regWrtSrc), .clk(clk), .rst(rst));
	dff brTyF[2:0] (.d(intBrType), .q(brType), .clk(clk), .rst(rst));
	dff wrtRegF[2:0] (.d(intWriteReg), .q(writeReg), .clk(clk), .rst(rst));


	dff aluOpF[3:0] (.d(intAluOp), .q(aluOp), .clk(clk), .rst(rst));



endmodule