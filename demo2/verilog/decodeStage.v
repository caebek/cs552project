module decodeStage(instr, nextPc, err, regWrtData, regWrtEn, regWrtAddr, halt, 
	sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB, return, cin, memToReg,
	writeReg, aluSrc, regWrtDataSrc, brType, aluOp, reg1Data, reg2Data, clk, rst);
	inout [15:0] nextPc, instr;
	// signals from writeback stage 
	input [15:0] regWrtData;
	input regWrtEn, clk, rst;
	input [2:0] regWrtAddr;

	output err, halt, sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB,
		return, cin, memToReg;

	output [2:0] aluSrc, regWrtDataSrc, brType, writeReg;
	output [3:0] aluOp;

	output [15:0] reg1Data, reg2Data;

	reg [1:0] hasErr;

	wire regErr, ctrlErr;
	wire [1:0] regDst;
	wire [2:0] read1Sel, read2Sel;

	assign err = |hasErr | regErr | ctrlErr;


	controlBlock ctrlBlk(.opCode(instr[15:11]), .func(instr[1:0]), 
		.halt(halt), .sign(sign), .pcOffSel(pcOffSel), 
		.regWrt(regWrt), .memWrt(memWrt), .memToReg(memToReg), .memEn(memEn), 
		.jump(jump), .invA(invA), .invB(invB), .aluSrc(aluSrc), .err(ctrlErr), 
		.regDst(regDst), .regWrtSrc(regWrtDataSrc), .aluOp(aluOp), .cin(cin), 
		.return(return), .brType(brType));


	// determine which reg to write to here but we need to pass
	// through the pipeline so it happens in order
	// could possibly move this to another stage if that makes sense
	always@(*) begin
		hasErr[0] = 0;
		case(regDst)
			2'h0: writeReg = instr[7:5];
			2'h1: writeReg = instr[10:8];
			2'h2: writeReg = instr[4:2];
			2'h3: writeReg = 3'h7;
			default: hasErr[0] = 1'h1;
		endcase
	end

	assign read1Sel = instr[10:8];
	assign read2Sel = instr[7:5];

	rf register(.read1data(reg1Data), .read2data(reg2Data), .err(regErr), 
		.clk(clk), .rst(rst), .read1regsel(read1Sel), .read2regsel(read2Sel), 
		.writeregsel(regWrtAddr), .writedata(regWrtData), .write(regWrtEn));

endmodule