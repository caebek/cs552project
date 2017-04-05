module memoryStage(clk, rst, err, aluOut, setVal, memWrt, memEn, halt, reg2Data, reg1Data, nextPc, instr, 
					regWrtIn, regWrtOut, regWrtSrc, memOut, regWriteData);

	input clk, rst, halt, memEn, memWrt;
	input [15:0] aluOut, reg1Data, reg2Data, nextPc, instr, setVal;
	input [2:0] regWrtSrc;
	input regWrtIn;

	output [15:0] memOut, regWriteData;
	output regWrtOut;
	output reg err;
	reg [15:0] regWriteData;
	memory2c mem(.data_out(memOut), .data_in(reg2Data), .addr(aluOut), .enable(memEn), .createdump(err|halt), 
		.wr(memWrt), .clk(clk), .rst(rst));

	assign regWrtOut = regWrtIn;

//	dff mOut [15:0] (.d(memOut), .q(memOut), .clk(clk), .rst(rst));


	always @(*) begin
		err = 0;
		regWriteData = 16'h0;
		case(regWrtSrc)
			3'h0: regWriteData = memOut;
			3'h1: regWriteData = aluOut;
			3'h2: regWriteData = nextPc;
			3'h3: regWriteData = setVal; // probably update this name
			3'h4: regWriteData = {{4'h8{instr[7]}},instr[7:0]};
			3'h5: regWriteData = {reg1Data[7:0], instr[7:0]};
			3'h6: regWriteData = {	reg1Data[0], reg1Data[1], reg1Data[2], reg1Data[3], reg1Data[4], reg1Data[5], 
								reg1Data[6], reg1Data[7], reg1Data[8], reg1Data[9], reg1Data[10], reg1Data[11],
								reg1Data[12], reg1Data[13], reg1Data[14], reg1Data[15]}; 
			default: err = 1'h1;
		endcase
	end

endmodule