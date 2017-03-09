module incr2(input [15:0] in, output [15:0] out);

	cla16Bit adder(.A(in), .B(16'h2), .Cin(1'h0), .S(out));

endmodule