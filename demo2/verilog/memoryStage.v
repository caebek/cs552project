module memoryStage(clk, rst, err, aluOut, setVal, memWrt, memEn, halt, reg2Data, reg1Data, nextPc, instr, 
					regWrt, regWrtOut, regWrtSrc, memOut, regWriteData, writeReg, writeRegOut);

	input clk, rst, halt, memEn, memWrt, regWrt;
	input [2:0] regWrtSrc, writeReg;
	input [15:0] aluOut, reg1Data, reg2Data, nextPc, instr, setVal;

	output err, regWrtOut;
	output [2:0] writeRegOut;
	output [15:0] memOut, regWriteData;


	wire intRegWrtOut;
	wire [15:0]intMemOut;
	
	reg intErr;
	reg [15:0] intRegWriteData;
	
	
	memory2c mem(.data_out(intMemOut), .data_in(reg2Data), .addr(aluOut), .enable(memEn), .createdump(intErr|halt), 
		.wr(memWrt), .clk(clk), .rst(rst));

	// assign regWrtOut = regWrt;

//	dff mOut [15:0] (.d(memOut), .q(memOut), .clk(clk), .rst(rst));


	always @(*) begin
		intErr = 0;
		intRegWriteData = 16'h0;
		case(regWrtSrc)
			3'h0: intRegWriteData = memOut;
			3'h1: intRegWriteData = aluOut;
			3'h2: intRegWriteData = nextPc;
			3'h3: intRegWriteData = setVal; // probably update this name
			3'h4: intRegWriteData = {{4'h8{instr[7]}},instr[7:0]};
			3'h5: intRegWriteData = {reg1Data[7:0], instr[7:0]};
			3'h6: intRegWriteData = {reg1Data[0], reg1Data[1], reg1Data[2], reg1Data[3], reg1Data[4], reg1Data[5], 
									reg1Data[6], reg1Data[7], reg1Data[8], reg1Data[9], reg1Data[10], reg1Data[11],
									reg1Data[12], reg1Data[13], reg1Data[14], reg1Data[15]}; 
			default: intErr = 1'h1;
		endcase
	end


	dff memOF[15:0](.d(intMemOut), .q(memOut), .clk(clk), .rst(rst));
	dff regWrtDF[15:0](.d(intRegWriteData), .q(regWriteData), .clk(clk), .rst(rst));


	dff regWrtF(.d(regWrt), .q(regWrtOut), .clk(clk), .rst(rst));
	dff errF(.d(intErr), .q(err), .clk(clk), .rst(rst));

	dff wrtRegF [2:0] (.d(writeReg), .q(writeRegOut), .clk(clk), .rst(rst));


endmodule