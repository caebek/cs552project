module executeStage(instr, nextPc, instrOut, nextPcOut, err, halt, sign, pcOffSel, regWrt, memWrt, 
					memEn, jump, invA, invB, return, cin, memToReg, writeReg, aluSrc,regWrtSrc,
					brType, aluOp, reg1Data, reg2Data, reg1DataOut, reg2DataOut, clk, rst, jumpPc,
					setVal, doBranch, aluOut, regWrtOut, memWrtOut, memEnOut, regWrtSrcOut, writeRegOut,
					haltOut, flushPipe, jumpOut, stall);
	
	input halt, sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB,
		return, cin, memToReg, clk, rst, flushPipe, stall;
	input [2:0] aluSrc, regWrtSrc, brType, writeReg;
	input [3:0] aluOp;
	input [15:0] reg1Data, reg2Data, nextPc, instr;

	output err, doBranch, regWrtOut, memWrtOut, memEnOut, haltOut, jumpOut;
	output [2:0] regWrtSrcOut, writeRegOut;
	output [15:0] jumpPc, aluOut, nextPcOut, instrOut, reg1DataOut, reg2DataOut, setVal;

	wire zero, neg, ofl, ffRst, tempHalt, tempRegWrt, tempMemWrt, tempMemEn, tempJump, tempDoBranch;
	wire [15:0] base, offset, a, intJumpPc, intAluOut;

	reg intDoBranch;
	reg [2:0] hasErr;
	reg [15:0] b, intSetVal;


	localparam NOBR = 3'h0;
	localparam EQZ = 3'h1;
	localparam NEZ = 3'h2;
	localparam LTZ = 3'h3;
	localparam GEQZ = 3'h4;


	// assign jumpOut = jump;
	// assign nextPcOut = nextPc;
	// assign instrOut = instr;
	// assign reg1DataOut = reg1Data;
	// assign reg2DataOut = reg2Data;
	// assign err = |hasErr;
	// assign regWrtOut = regWrt;
	// assign memWrtOut = memWrt;
	// assign memEnOut = memEn;
	// assign writeRegOut = writeReg; 
	// assign regWrtSrcOut = regWrtSrc; 
	// assign haltOut = halt;

	assign haltOut = stall ? 1'h0 : tempHalt;
	assign regWrtOut = stall ? 1'h0 : tempRegWrt;
	assign memWrtOut = stall ? 1'h0 : tempMemWrt;
	assign memEnOut = stall ? 1'h0 : tempMemEn;
	assign jumpOut = stall ? 1'h0 : tempJump;
	assign doBranch = stall ? 1'h0 : tempDoBranch;


	assign ffRst = rst | doBranch | jumpOut | flushPipe;

	dffEn haltF(.d(halt), .q(tempHalt), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn memEnF(.d(memEn), .q(tempMemEn), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn memWRtF(.d(memWrt), .q(tempMemWrt), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn regWrtF(.d(regWrt), .q(tempRegWrt), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn errF(.d(|hasErr), .q(err), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn doBrF(.d(intDoBranch), .q(tempDoBranch), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn jmpF(.d(jump), .q(tempJump), .clk(clk), .rst(ffRst), .en(~stall));


	dffEn regWrtSrcF[2:0] (.d(regWrtSrc), .q(regWrtSrcOut), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn wrtRegF[2:0] (.d(writeReg), .q(writeRegOut), .clk(clk), .rst(ffRst), .en(~stall));

	dffEn reg1F[15:0](.d(reg1Data), .q(reg1DataOut), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn reg2F[15:0](.d(reg2Data), .q(reg2DataOut), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn instrF[15:0](.d(instr), .q(instrOut), .clk(clk), .rst(rst), .en(~stall));
	dffEn nextPcF[15:0](.d(nextPc), .q(nextPcOut), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn jmpPcF[15:0](.d(intJumpPc), .q(jumpPc), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn aluOutF[15:0](.d(intAluOut), .q(aluOut), .clk(clk), .rst(ffRst), .en(~stall));
	dffEn setValF[15:0](.d(intSetVal), .q(setVal), .clk(clk), .rst(ffRst), .en(~stall));


	// Jump/Branch PC calculation
	assign base = (return) ? reg1Data : nextPc;
	assign offset = (pcOffSel) ? {{3'h5{instr[10]}}, instr[10:0]} : {{4'h8{instr[7]}}, instr[7:0]};
	cla16Bit adder(.A(base), .B(offset), .Cin(1'h0), .S(intJumpPc));






	// determine if we are doing a branch
	// if doBranch is 1, we need to clear pipeline since we were 
	// doing wrong instructions
	always@(*) begin
		intDoBranch = 1'h0;
		hasErr[0] = 1'h0;
		case(brType)
			NOBR: intDoBranch = 0;
			EQZ: intDoBranch = zero;
			NEZ: intDoBranch = ~zero;
			LTZ: intDoBranch = neg;
			GEQZ: intDoBranch = ~neg | zero;
			default: hasErr[0] = 1'h1;
		endcase
	end


	// Determine the value of setVal based on the instruction
	always@(*) begin
		hasErr[1] = 1'h0;
		case(instr[12:11])
			2'h0: intSetVal = (zero) ? 16'h1: 16'h0;
			2'h1: intSetVal = (neg ^ ofl) ? 16'h1: 16'h0;
			2'h2: intSetVal = (zero | (neg ^ ofl)) ? 16'h1: 16'h0;
			2'h3: intSetVal = (ofl) ? 16'h1: 16'h0;
			default: hasErr[1] = 1'h1;
		endcase
	end


	// Select the second alu input 
	always@(*) begin
		hasErr[2] = 1'h0;
		b = 16'h0;
		case(aluSrc)
			3'h0: b = {{4'd11{instr[4]}}, instr[4:0]};
			3'h1: b = {{4'd11{1'h0}}, instr[4:0]};
			3'h2: b = {{4'd8{instr[7:0]}}, instr[7:0]};
			3'h3: b = {{4'd8{1'h0}}, instr[7:0]};
			3'h4: b = reg2Data;
			3'h5: b = 16'h0;
			default: hasErr[2] = 1'h1;
		endcase
	end


	assign a = reg1Data;

	alu alua(.A(a), .B(b), .Cin(cin), .Op(aluOp), .invA(invA), .invB(invB), 
		.sign(sign), .Out(intAluOut), .Ofl(ofl), .Zero(zero), .N(neg));

endmodule