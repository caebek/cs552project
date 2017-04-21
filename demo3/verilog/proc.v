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

	wire fErr, dErr, eErr, mErr, regWrtEn, dHalt, halt, sign, pcOffSel, dRegWrt, eRegWrt, dMemWrt, eMemWrt, 
			dMemEn, eMemEn, jump, invA, invB, return, cin, memToReg, doBranch, memFwdA, memFwdB, wbFwdA, wbFwdB, 
			stall, jumpOut, iMemStall, flushPipe, clearPipe, prevMFwdA, prevMFwdB, prevWFwdA, prevWFwdB, hazStall, extraStall, prevJump;
	wire [2:0] regWrtAddr, dWriteReg, eWriteReg, aluSrc, regWrtSrc, eRegWrtSrc, brType, writeReg, regA, regB, regRt, regRs, mRegWrtSrc, memFwdCheckReg;
	wire [3:0] aluOp;
	wire [4:0] dOp;
	wire [15:0] fInstr, dInstr, eInstr, fNextPc, dNextPc, eNextPc, dReg1Data, regADataFlop, regBDataFlop,
			eReg1Data, dReg2Data, eReg2Data, jumpPc, setVal, aluOut, memOut, regWriteData, fwdData, writeData, useA, useB, savedData;
	reg [1:0] hasErr;
	reg [15:0] regAData, regBData;
	
	assign err =  ~rst & (dErr | eErr | mErr | (|hasErr) | fErr);

	// Outputs of each stage are already flopped
	


	fetchStage fetch(.clk(clk), .rst(rst), .halt(halt & ~pipeStall), .doBranch(doBranch | jumpOut), 
		.branchPc(jumpPc), .nextPc(fNextPc), .instr(fInstr), .stall(fStall | hazStall), .err(fErr), .stallOut(iMemStall),
		.flushPipe(flushPipe));


	decodeStage decode(.instrIn(fInstr), .instrOut(dInstr), .nextPcIn(fNextPc), .nextPcOut(dNextPc), 
		.err(dErr), .regWrtData(writeData), .regWrtEn(regWrtEn), .regWrtAddr(writeReg), 
		.halt(dHalt), .sign(sign), .pcOffSel(pcOffSel), .regWrt(dRegWrt), .memWrt(dMemWrt), 
		.memEn(dMemEn), .jump(jump), .invA(invA), .invB(invB), .return(return), .cin(cin), 
		.memToReg(memToReg), .writeReg(dWriteReg), .aluSrc(aluSrc), 
		.regWrtSrc(regWrtSrc), .brType(brType), .aluOp(aluOp), .reg1Data(dReg1Data), 
		.reg2Data(dReg2Data), .clk(clk), .rst(rst), .stall(pipeStall | hazStall), .doBranch(flushPipe), .hazStall(hazStall));

	// Flop outputs


	executeStage execute(.instr(dInstr), .nextPc(dNextPc), .instrOut(eInstr), .nextPcOut(eNextPc), 
		.err(eErr), .halt(dHalt), .sign(sign), .pcOffSel(pcOffSel), .regWrt(dRegWrt), .memWrt(dMemWrt), 
		.memEn(dMemEn), .jump(jump), .invA(invA), .invB(invB), .return(return), .cin(cin), .memToReg(memToReg),
		.writeReg(dWriteReg), .aluSrc(aluSrc), .regWrtSrc(regWrtSrc), .brType(brType), .aluOp(aluOp), .reg1Data(regAData),
		.reg2Data(regBData), .reg1DataOut(eReg1Data), .reg2DataOut(eReg2Data), .clk(clk), .rst(rst),
		.jumpPc(jumpPc), .setVal(setVal), .doBranch(doBranch), .aluOut(aluOut), .regWrtOut(eRegWrt),
		.memWrtOut(eMemWrt), .memEnOut(eMemEn), .regWrtSrcOut(eRegWrtSrc), .writeRegOut(eWriteReg),
		.haltOut(halt), .jumpOut(jumpOut), .flushPipe(flushPipe), .stall(pipeStall), .prevStall(prevStall), .hazStall(hazStall));


	// dff hf(.d(halt), .q(haltOut), .clk(clk), .rst(rst | doBranch | jumpOut));
	memoryStage memory(.clk(clk), .rst(rst), .err(mErr), .aluOut(aluOut), .setVal(setVal), 
					.memWrt(eMemWrt), .memEn(eMemEn), .halt(halt), .reg2Data(eReg2Data), .reg1Data(eReg1Data), 
					.nextPc(eNextPc), .instr(eInstr), .regWrt(eRegWrt), .regWrtOut(regWrtEn), 
					.regWrtSrc(eRegWrtSrc), .memOut(memOut), .regWriteData(regWriteData),
					.writeReg(eWriteReg), .writeRegOut(writeReg), .fwdData(fwdData), .regWrtSrcOut(mRegWrtSrc),
					.stall(pipeStall), .prevStall(prevStall), .hazStall(hazStall));


	dff clrPipeFF(.d(clearPipe), .q(flushPipe), .clk(clk), .rst(rst));
	dff stalleFF(.d(pipeStall), .q(prevStall), .clk(clk), .rst(rst));

	// Forward logic

	// outputs of decode that w
	assign regA = dInstr[10:8];
	assign regB = dInstr[7:5];

	// assign wbRegA = dInstr[10:8];
	// assign wbRegB = dInstr[7:5];
	assign memFwdA = (eRegWrt & (memFwdCheckReg == regA)) | (prevMFwdA & prevStall);
	assign memFwdB = (eRegWrt & (memFwdCheckReg == regB)) | (prevMFwdB & prevStall);


	assign wbFwdA = ((regWrtEn & (writeReg == regA)) | (prevWFwdA & prevStall)) & ~memFwdA;//~(eRegWrt | (eRegWrt & (eWriteReg != regA)));
	assign wbFwdB = ((regWrtEn & (writeReg == regB)) | (prevWFwdB & prevStall)) & ~memFwdB;//~(eRegWrt | (eRegWrt & (eWriteReg != regB)));

	

	assign writeData = (mRegWrtSrc == 3'h0) ? memOut : (regWrtEn & prevJump) ? fwdData : (hazStall) ? savedData : regWriteData;



	// for jalr writeReg is r7 but dep in on r0 which is in instruct so not fowarding mem like should and then forwarding wb which is giving the wrong data
	assign memFwdCheckReg = (eRegWrt & jumpOut) ? eInstr[10:8] : eWriteReg;



	dff rwdA[15:0](.d(regWriteData), .q(savedData), .clk(clk), .rst(rst));
	

	dff mFwdA(.d(memFwdA), .q(prevMFwdA), .clk(clk), .rst(rst));
	dff wFwdA(.d(wbFwdA), .q(prevWFwdA), .clk(clk), .rst(rst));
	dff mFwdB(.d(memFwdB), .q(prevMFwdB), .clk(clk), .rst(rst));
	dff wFwdB(.d(wbFwdB), .q(prevWFwdB), .clk(clk), .rst(rst));
 // 	assign fwdA = memFwdA | wbFwdA;
 // 	assign fwdB = memFwdB | wbFwdB;
	// dffEn regAF[15:0](.d(regAData), .q(regADataFlop), .clk(clk), .rst(rst), .en(~stall | fwd));
	// dffEn regBF[15:0](.d(regBData), .q(regBDataFlop), .clk(clk), .rst(rst), .en(~stall | fwd));


	// assign useA =(stall) ? regADataFlop : regAData;
	// assign useB = (stall) ? regBDataFlop : regBData;


	// reg1Data mux
	always@(*) begin
		hasErr[0] = 1'h0;
		regAData = 16'h0;
		case({memFwdA, wbFwdA})
			2'b00: begin
				regAData = dReg1Data;
				// writeAData = regWriteData;
			end
			2'b01: begin
				regAData = (mRegWrtSrc != 3'h0) ? regWriteData : memOut;
				// writeAData = regAData;
			end
			2'b10: begin
				regAData = (eRegWrtSrc != 3'h0) ? fwdData : memOut;
				// writeAData = regWriteData;
			end
			default: hasErr[0] = 1'h1;
		endcase
	end

	always@(*) begin
		hasErr[1] = 1'h0;
		regBData = 16'h0;
		case({memFwdB, wbFwdB})
			2'b00: begin
				regBData = dReg2Data;
				// writeBData = regWriteData;
			end
			2'b01: begin
				regBData = (mRegWrtSrc != 3'h0) ? regWriteData : memOut;
				// writeBData = regBData;
			end 
			2'b10: begin
				regBData = (eRegWrtSrc != 3'h0) ? fwdData : memOut;
				// writeBData = regWriteData;
			end
			default: hasErr[1] = 1'h1;
		endcase
	end


	assign clearPipe = doBranch | jumpOut;

	// Pg 313/314 for stalling 
	// pg 306 308 311 for forwarding 

	//Stalling Logic


	assign regRs = fInstr[10:8];
	assign regRt = fInstr[7:5];
	// assign regRd = fInstr[4:2];


	assign dOp = fInstr[15:11];
	assign pipeStall = iMemStall;
	// stall if we are reading memory and the reg we will write that value to is used in the next instruction, or the next instruction is a halt and the next instrction
	// isnt a ld or st or stu. 


	assign extraStall = (~iMemStall) ? 1'h0 | fStall : hazStall | fStall;

	dff hazStallf(.d(extraStall), .q(hazStall), .clk(clk), .rst(rst));
	dff pjf(.d(jumpOut), .q(prevJump), .clk(clk), .rst(rst));


	assign fStall = (dMemEn & ~dMemWrt) & ((regB == regRt) | (regB == regRs) | dOp == 5'h0);// & dOp != 5'b10001 & dOp != 5'b10000 & dOp != 5'b10011;
	
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
