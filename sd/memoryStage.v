module memoryStage(clk, rst, err, aluOut, setVal, memWrt, memEn, halt, reg2Data, reg1Data, nextPc, instr, 
					regWrt, regWrtOut, regWrtSrc, memOut, regWriteData, writeReg, writeRegOut, fwdData, regWrtSrcOut,
					hazStall, iMemStall, dMemStall);
	
	input clk, rst, halt, memEn, memWrt, regWrt, hazStall, iMemStall;
	input [2:0] regWrtSrc, writeReg;
	input [15:0] aluOut, reg1Data, reg2Data, nextPc, instr, setVal;

	output err, regWrtOut, dMemStall;
	output [2:0] writeRegOut, regWrtSrcOut;
	output [15:0] memOut, regWriteData, fwdData;

	
	wire intRegWrtOut, memErr, intErr, done, rd, wrt;
	wire [15:0]intMemOut;
	
	reg hasErr;
	reg [15:0] fwdData;
	
	
	// memory2c_align mem(.data_out(intMemOut), .data_in(reg2Data), .addr(aluOut), .enable(memEn), .createdump(intErr|halt), 
	// 			.wr(memWrt), .clk(clk), .rst(rst), .err(memErr));
	mem_system dMem(.DataOut(intMemOut), .Done(done), .Stall(dMemStall), .CacheHit(dCacheHit), .err(memErr), 
	    .Addr(aluOut), .Rd(rd & ~done), .Wr(wrt & ~done), .createdump(halt), .clk(clk), .rst(rst), .DataIn(reg2Data), .cancel(1'h0));


	assign rd = memEn & ~memWrt;
	assign wrt = memEn & memWrt;


	always @(*) begin
		hasErr = 0;
		fwdData = 16'h0;
		case(regWrtSrc)
			3'h0: fwdData = 16'h0;
			3'h1: fwdData = aluOut;
			3'h2: fwdData = nextPc;
			3'h3: fwdData = setVal; // probably update this name
			3'h4: fwdData = {{4'h8{instr[7]}},instr[7:0]};
			3'h5: fwdData = {reg1Data[7:0], instr[7:0]};
			3'h6: fwdData = {reg1Data[0], reg1Data[1], reg1Data[2], reg1Data[3], reg1Data[4], reg1Data[5], 
									reg1Data[6], reg1Data[7], reg1Data[8], reg1Data[9], reg1Data[10], reg1Data[11],
									reg1Data[12], reg1Data[13], reg1Data[14], reg1Data[15]}; 
			default: hasErr = 1'h1;
		endcase
	end	

	assign intErr = |hasErr | memErr;	
	dff memOF[15:0](.d(intMemOut), .q(memOut), .clk(clk), .rst(rst));
	dff regWrtDF[15:0](.d(fwdData), .q(regWriteData), .clk(clk), .rst(rst));


	dff regWrtF(.d(regWrt), .q(regWrtOut), .clk(clk), .rst(rst | dMemStall));
	dff errF(.d(intErr), .q(err), .clk(clk), .rst(rst));

	dff wrtRegF [2:0] (.d(writeReg), .q(writeRegOut), .clk(clk), .rst(rst));
	dff wrtRegSrcF [2:0] (.d(regWrtSrc), .q(regWrtSrcOut), .clk(clk), .rst(rst));


endmodule