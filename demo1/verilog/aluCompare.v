// Module that compares a to b. 
// eq = 1 iff a == b
// gr = 1 iff a > b
// lt = 1 iff a < b
module compare(a, b, zero, ofl, eq, gr, lt);

	input [15:0] a, b;
	input zero, ofl;

	output eq, gr, lt;

	assign eq = zero;
	assign lt = a[15] ^ ofl;
	assign gr = ~eq & ~lt;

endmodule