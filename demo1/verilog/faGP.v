module faGP(A, B, Cin, S, G, P);
	input A, B, Cin;
	output S, G, P;

    assign S = A ^ B  ^ Cin;
    // assign Cout = ((A ^ B) & Cin) | (A & B);

    assign G = A & B;
    assign P = A | B;

endmodule