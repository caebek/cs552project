/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */

module sc( clk, rst, ctr_rst, out, err);
	input clk;
	input rst;
	input ctr_rst;
	output [2:0] out;
	output reg err;

	// your code
	localparam reset = 3'h0;
	localparam one = 3'h1;
	localparam two = 3'h2;
	localparam three = 3'h3;
	localparam four = 3'h4;
	localparam five = 3'h5;
	

	wire [2:0] curState; 
	reg [2:0] nextState;

	dff flop[0:2](.clk(clk), .rst(rst), .d(nextState), .q(curState));

	always@(*) begin
		case(curState)
			reset: begin
				nextState = (ctr_rst) ? reset : one;
				err = 1'h0;
			end
			one: begin
				nextState = (ctr_rst) ? reset : two;
				err = 1'h0;
			end
			two: begin
				nextState = (ctr_rst) ? reset : three;
				err = 1'h0;
			end
			three: begin
				nextState = (ctr_rst) ? reset : four;
				err = 1'h0;
			end
			four: begin
				nextState = (ctr_rst) ? reset : five;
				err = 1'h0;
			end
			five: begin
				nextState = (ctr_rst) ? reset : five; 
				err = 1'h0;
			end
			default: begin
				nextState = reset;
				err = 1'h1;
			end

		endcase

	end

	assign out = curState;

endmodule
// DUMMY LINE FOR REV CONTROL :1:
