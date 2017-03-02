/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf (
		// Outputs{{
		read1data, read2data, err,
		// Inputs
		clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
		);

	parameter width = 5'h10; // default 16 bits
	input clk, rst;
	input [2:0] read1regsel;
	input [2:0] read2regsel;
	input [2:0] writeregsel;
	input [width-1:0] writedata;
	input        write;

	output [width-1:0] read1data;
	output [width-1:0] read2data;
	output        err;

	// your code
	reg [7:0] writeSelect;
	wire [width-1:0] dataOut [7:0];


	always@(writeregsel, write) begin
		case(writeregsel)
			3'h0: writeSelect = (write) ? 8'h01 : 8'h0;
			3'h1: writeSelect = (write) ? 8'h02 : 8'h0;
			3'h2: writeSelect = (write) ? 8'h04 : 8'h0;
			3'h3: writeSelect = (write) ? 8'h08 : 8'h0;
			3'h4: writeSelect = (write) ? 8'h10 : 8'h0;
			3'h5: writeSelect = (write) ? 8'h20 : 8'h0;
			3'h6: writeSelect = (write) ? 8'h40 : 8'h0;
			3'h7: writeSelect = (write) ? 8'h80 : 8'h0;
		endcase
	end


	register reg1(.clk(clk), .rst(rst), .wEn(writeSelect[0]), .wData(writedata), .rData(dataOut[0])); 
	register reg2(.clk(clk), .rst(rst), .wEn(writeSelect[1]), .wData(writedata), .rData(dataOut[1])); 
	register reg3(.clk(clk), .rst(rst), .wEn(writeSelect[2]), .wData(writedata), .rData(dataOut[2]));
	register reg4(.clk(clk), .rst(rst), .wEn(writeSelect[3]), .wData(writedata), .rData(dataOut[3])); 
	register reg5(.clk(clk), .rst(rst), .wEn(writeSelect[4]), .wData(writedata), .rData(dataOut[4])); 
	register reg6(.clk(clk), .rst(rst), .wEn(writeSelect[5]), .wData(writedata), .rData(dataOut[5])); 
	register reg7(.clk(clk), .rst(rst), .wEn(writeSelect[6]), .wData(writedata), .rData(dataOut[6])); 
	register reg8(.clk(clk), .rst(rst), .wEn(writeSelect[7]), .wData(writedata), .rData(dataOut[7])); 

	assign read1data = dataOut[read1regsel];
	assign read2data = dataOut[read2regsel];

endmodule
// DUMMY LINE FOR REV CONTROL :1:
