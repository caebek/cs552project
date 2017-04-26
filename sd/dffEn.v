module dffEn(d, q, en, clk, rst);
	output         q;
	input          d, en;
	input          clk;
	input          rst;

	wire val;


	assign val = en ? d : q;



	dff flop(.d(val), .q(q), .clk(clk), .rst(rst));


endmodule