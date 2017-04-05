/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
	// Outputs
	err, 
	// Inputs
	clk, rst
	);

	input clk;
	input rst;

	output err;

	// None of the above lines can be modified

	// OR all the err ouputs for every sub-module and assign it as this
	// err output
	
	// As desribed in the homeworks, use the err signal to trap corner
	// cases that you think are illegal in your statemachines
	
	
	/* your code here */
	localparam NOBR = 3'h0;
	localparam EQZ = 3'h1;
	localparam NEZ = 3'h2;
	localparam LTZ = 3'h3;
	localparam GEQZ = 3'h4;

	// wire haltBuf, cin, sign, invA, invB, ofl, zero, return, jump, regWrt, memWrt,
	// 		memEn, halt, haltEn, pcOffSel, regErr, n;
	// wire [1:0] regDst;
	// wire [2:0] regWrtSrc, aluSrc, read1Sel, read2Sel, brType;
	// wire [3:0] aluOp;
	// wire [15:0] pc, newPc, pcIncr, jumpPc, aluOut, memOut, reg1Data, 
			// reg2Data, instr, a, base, offset;
	// reg doBranch;
	// reg[2:0] writeRegSel;
	// reg [4:0] hasErr;
	// reg [15:0] writeData, b, setVal;
	// need control module
	// and alu
	// regs
	// 2 memories, 1 for intruction, 1 for storage
	wire [15:0] fInstr, dInstr, fNextPc, dNextPc, regWrtData, dReg1Data, dReg2Data, branchPc;
	wire eErr, regWrtEn, dHalt, sign, pcOffSel, dRegWrt,dMemWrt, dMemEn, jump, invA, invB, return, cin, memToReg;
	wire [2:0] regWrtAddr, dWriteReg, aluSrc, regWrtSrc, brType;
	wire [3:0] aluOp;
	// wire decodeErr, eErr, memErr, wbErr;

	// assign err =  ~rst & (decodeErr | exErr | memErr | wbErr);


	/********************** Fetch Stage **********************/
	
	// register pcReg(.clk(clk), .rst(rst), .wData(newPc), .rData(pc), .wEn(~haltEn));

	// memory2c iMem(.data_out(instr), .addr(pc), .enable(1'h1), .wr(1'h0), .createdump(err|haltEn), 
		// .clk(clk), .rst(rst));

	// incr2 incrPC(.in(pc), .out(pcIncr));

	// dff haltFlp(.clk(clk), .rst(rst), .d(halt), .q(haltBuf));

	// assign haltEn = (rst) ? 1'h0 : haltEn | halt; // always 1 once if asserted once

	// assign newPc = (jump | doBranch) ? jumpPc : pcIncr;

	fetchStage fetch(.clk(clk), .rst(rst), .halt(halt), .doBranch(doBranch), 
		.branchPc(branchPc), .nextPc(fNextPc), .instr(fInstr));
	

	decodeStage decode(.instrIn(fInstr), .instrOut(dInstr), .nextPcIn(fNextPc), .nextPcOut(dNextPc), 
		.err(eErr), .regWrtData(regWrtData), .regWrtEn(regWrtEn), .regWrtAddr(regWrtAddr), 
		.halt(dHalt), .sign(sign), .pcOffSel(pcOffSel), .regWrt(dRegWrt), .memWrt(dMemWrt), 
		.memEn(dMemEn), .jump(jump), .invA(invA), .invB(invB), .return(return), .cin(cin), 
		.memToReg(memToReg), .writeReg(dWriteReg), .aluSrc(aluSrc), 
		.regWrtSrc(regWrtSrc), .brType(brType), .aluOp(aluOp), .reg1Data(dReg1Data), 
		.reg2Data(dReg2Data), .clk(clk), .rst(rst));


	// This need to move to execute stage
	// always@(*) begin
	// 	doBranch = 1'h0;
	// 	hasErr[0] = 1'h0;
	// 	case(brType)
	// 		NOBR: doBranch = 0;
	// 		EQZ: doBranch = zero;
	// 		NEZ: doBranch = ~zero;
	// 		LTZ: doBranch = n;
	// 		GEQZ: doBranch = ~n | zero;
	// 		default: hasErr[0] = 1'h1;
	// 	endcase
	// end

	/**********************************************************/



	/********************** Decode Stage **********************/
	////////////////// Hazard Control ////////////////////



	//////////////////////////////////////////////////////

	///////////////// Control Block /////////////////////

	// controlBlock ctrl(.opCode(instr[15:11]), .func(instr[1:0]), 
	// 		.halt(halt), .sign(sign), .pcOffSel(pcOffSel), 
	// 		.regWrt(regWrt), .memWrt(memWrt), .memToReg(), .memEn(memEn), 
	// 		.jump(jump), .invA(invA), .invB(invB), .aluSrc(aluSrc), .err(err), 
	// 		.regDst(regDst), .regWrtSrc(regWrtSrc), .aluOp(aluOp), .cin(cin), 
	// 		.return(return), .brType(brType));

	//////////////////////////////////////////////////////

	// Mux for Write Register Select input
	// always@(*) begin
	// 	hasErr[1] = 0;
	// 	case(regDst)
	// 		2'h0: writeRegSel = instr[7:5];
	// 		2'h1: writeRegSel = instr[10:8];
	// 		2'h2: writeRegSel = instr[4:2];
	// 		2'h3: writeRegSel = 3'h7;
	// 		default: hasErr[1] = 1'h1;
	// 	endcase
	// end

	// Write data Mux
	// Move to writeBackStage
	// always @(*) begin
	// 	hasErr[2] = 0;
	// 	writeData = 16'h0;
	// 	case(regWrtSrc)
	// 		3'h0: writeData = memOut;
	// 		3'h1: writeData = aluOut;
	// 		3'h2: writeData = pcIncr;
	// 		3'h3: writeData = setVal; // probably update this name
	// 		3'h4: writeData = {{4'h8{instr[7]}},instr[7:0]};
	// 		3'h5: writeData = {reg1Data[7:0], instr[7:0]};
	// 		3'h6: writeData = {reg1Data[0], reg1Data[1], reg1Data[2], reg1Data[3], reg1Data[4], reg1Data[5], reg1Data[6], reg1Data[7], reg1Data[8], reg1Data[9], reg1Data[10], reg1Data[11], reg1Data[12], reg1Data[13], reg1Data[14], reg1Data[15]}; 
	// 		default: hasErr[2] = 1'h1;
	// 	endcase
	// end

	// assign read1Sel = instr[10:8];
	// assign read2Sel = instr[7:5];
	// rf_bypass register(.read1data(reg1Data), .read2data(reg2Data), .err(regErr), 
	//    .clk(clk), .rst(rst), .read1regsel(read1Sel), .read2regsel(read2Sel), 
	//    .writeregsel(writeRegSel), .writedata(writeData), .write(regWrt));

	// rf register(.read1data(reg1Data), .read2data(reg2Data), .err(regErr), 
	// 	.clk(clk), .rst(rst), .read1regsel(read1Sel), .read2regsel(read2Sel), 
	// 	.writeregsel(writeRegSel), .writedata(writeData), .write(regWrt));

	/**********************************************************/


	//////////////////////////////////////////////////////

	// move to execute stage
	// always@(*) begin
	// 	hasErr[3] = 1'h0;
	// 	case(instr[12:11])
	// 		3'h0: setVal = (zero) ? 16'h1: 16'h0;
	// 		3'h1: setVal = (aluOut[15] ^ ofl) ? 16'h1: 16'h0;
	// 		3'h2: setVal = (zero | (aluOut[15] ^ ofl)) ? 16'h1: 16'h0;
	// 		3'h3: setVal = (ofl) ? 16'h1: 16'h0;
	// 		default: hasErr[3] = 1'h1;
	// 	endcase
	// end

	/****************** Execute Stage ************************/

	/////////// PC Update Logic ///////////
	// assign base = (return) ? reg1Data : pcIncr;

	// assign offset = (pcOffSel) ? {{3'h5{instr[10]}}, instr[10:0]} : {{4'h8{instr[7]}}, instr[7:0]};

	// cla16Bit adder(.A(base), .B(offset), .Cin(1'h0), .S(jumpPc));



	///////////////////////////////////////



	// assign a = reg1Data;

	// ALU B input mux
	// always@(*) begin
	// 	hasErr[4] = 1'h0;
	// 	b = 16'h0;
	// 	case(aluSrc)
	// 		3'h0: b = {{4'd11{instr[4]}}, instr[4:0]};
	// 		3'h1: b = {{4'd11{1'h0}}, instr[4:0]};
	// 		3'h2: b = {{4'd8{instr[7:0]}}, instr[7:0]};
	// 		3'h3: b = {{4'd8{1'h0}}, instr[7:0]};
	// 		3'h4: b = reg2Data;
	// 		3'h5: b = 16'h0;
	// 		default: hasErr[4] = 1'h1;
	// 	endcase
	// end

	// alu alu(.A(a), .B(b), .Cin(cin), .Op(aluOp), .invA(invA), .invB(invB), 
	// 	.sign(sign), .Out(aluOut), .Ofl(ofl), .Zero(zero), .N(n));


	/**********************************************************/




	/****************** Memory Stage *********************/
	// memory2c mem(.data_out(memOut), .data_in(reg2Data), .addr(aluOut), .enable(memEn), .createdump(err|haltEn), 
	// 	.wr(memWrt), .clk(clk), .rst(rst));

	/**********************************************************/

	// Write back doesn't exist
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
