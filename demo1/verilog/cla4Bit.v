module cla4Bit(A, B, Cin, S, carries);
    input [3:0] A, B;
    input Cin;
    output [3:0] S, carries;

    wire [3:0] Ps, Gs, cins;

    assign cins = {carries[2:0], Cin};

    faGP fas[3:0](.A(A), .B(B), .Cin(cins), .S(S), .P(Ps), .G(Gs));

    // faGP bit1(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .P(Ps[0]), .G(Gs[0]));
    // faGP bit2(.A(A[1]), .B(B[1]), .Cin(carries[0]), .S(S[1]), .P(Ps[1]), .G(Gs[1]));
    // faGP bit3(.A(A[2]), .B(B[2]), .Cin(carries[1]), .S(S[2]), .P(Ps[2]), .G(Gs[2]));
    // faGP bit4(.A(A[3]), .B(B[3]), .Cin(carries[2]), .S(S[3]), .P(Ps[3]), .G(Gs[3]));
    
    carry4Bit carry(.Cin(Cin), .G(Gs), .P(Ps), .Cout(carries));



endmodule