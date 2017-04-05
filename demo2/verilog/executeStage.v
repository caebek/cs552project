module executeStage(instr, nextPc, instrOut, nextPcOut, err, halt, sign, pcOffSel, regWrt, memWrt, 
					memEn, jump, invA, invB, return, cin, memToReg, writeReg, aluSrc,regWrtDataSrc,
					brType, aluOp, reg1Data, reg2Data, reg1DataOut, reg2DataOut, clk, rst, jumpPc,
					setVal, doBranch);
	
	input halt, sign, pcOffSel, regWrt, memWrt, memEn, jump, invA, invB,
		return, cin, memToReg, clk, rst;
	input [2:0] aluSrc, regWrtDataSrc, brType, writeReg;
	input [3:0] aluOp;
	input [15:0] reg1Data, reg2Data;
	input [15:0] nextPc, instr;

	output err, doBranch;
	output [15:0] jumpPc, aluOut;
	output [15:0] nextPcOut, instrOut;
	output [15:0] reg1DataOut, reg2DataOut, setVal;

	wire [15:0] base, offset, a, b;
	wire zero, neg, ofl;
	reg [2:0] hasErr;


	localparam NOBR = 3'h0;
	localparam EQZ = 3'h1;
	localparam NEZ = 3'h2;
	localparam LTZ = 3'h3;
	localparam GEQZ = 3'h4;

	assign nextPcOut = nextPc;
	assign instrOut = instr;
	assign reg1DataOut = reg1Data;
	assign reg2DataOut = reg2Data;
	assign err = |hasErr;


	// Jump/Branch PC calculation
	assign base = (return) ? reg1Data : nextPc;
	assign offset = (pcOffSel) ? {{3'h5{instr[10]}}, instr[10:0]} : {{4'h8{instr[7]}}, instr[7:0]};
	cla16Bit adder(.A(base), .B(offset), .Cin(1'h0), .S(jumpPc));



	// determine if we are doing a branch
	// if doBranch is 1, we need to clear pipeline since we were 
	// doing wrong instructions
	always@(*) begin
		doBranch = 1'h0;
		hasErr[0] = 1'h0;
		case(brType)
			NOBR: doBranch = 0;
			EQZ: doBranch = zero;
			NEZ: doBranch = ~zero;
			LTZ: doBranch = neg;
			GEQZ: doBranch = ~neg | zero;
			default: hasErr[0] = 1'h1;
		endcase
	end


	// Determine the value of setVal based on the instruction
	always@(*) begin
		hasErr[1] = 1'h0;
		case(instr[12:11])
			2'h0: setVal = (zero) ? 16'h1: 16'h0;
			2'h1: setVal = (aluOut[15] ^ ofl) ? 16'h1: 16'h0;
			2'h2: setVal = (zero | (aluOut[15] ^ ofl)) ? 16'h1: 16'h0;
			2'h3: setVal = (ofl) ? 16'h1: 16'h0;
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
		.sign(sign), .Out(aluOut), .Ofl(ofl), .Zero(zero), .N(neg));

endmodule