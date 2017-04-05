module memoryStage(clk, rst, err, aluOut, memWrt, memEn, halt, reg2Data, reg1Data, nextPc, instr);

	input clk, rst, err, halt, memEn, memWrt;
	input [15:0] aluOut, reg1Data, reg2Data, nextPc, instr;
	output [15:0] memOut, regWriteData;
	inout regWrt;
	inout [2:0] regWrtSrc;

	memory2c mem(.data_out(memOut), .data_in(dataIn), .addr(wrtAddr), .enable(memEn), .createdump(err|halt), 
		.wr(memWrt), .clk(clk), .rst(rst));



	always @(*) begin
		hasErr[2] = 0;
		writeData = 16'h0;
		case(regWrtSrc)
			3'h0: writeData = memOut;
			3'h1: writeData = aluOut;
			3'h2: writeData = pcIncr;
			3'h3: writeData = setVal; // probably update this name
			3'h4: writeData = {{4'h8{instr[7]}},instr[7:0]};
			3'h5: writeData = {reg1Data[7:0], instr[7:0]};
			3'h6: writeData = {reg1Data[0], reg1Data[1], reg1Data[2], reg1Data[3], reg1Data[4], reg1Data[5], reg1Data[6], reg1Data[7], reg1Data[8], reg1Data[9], reg1Data[10], reg1Data[11], reg1Data[12], reg1Data[13], reg1Data[14], reg1Data[15]}; 
			default: hasErr[2] = 1'h1;
		endcase
	end

endmodule;