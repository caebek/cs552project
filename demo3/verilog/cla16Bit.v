module cla16Bit(A, B, Cin, S, Cout, C14);
    
    input [15:0] A, B;
    input Cin;
    output [15:0] S;
    output Cout, C14;

    wire [15:0] carries;


    cla4Bit add1(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .carries(carries[3:0]));
    cla4Bit add2(.A(A[7:4]), .B(B[7:4]), .Cin(carries[3]), .S(S[7:4]), .carries(carries[7:4]));
    cla4Bit add3(.A(A[11:8]), .B(B[11:8]), .Cin(carries[7]), .S(S[11:8]), .carries(carries[11:8]));
    cla4Bit add4(.A(A[15:12]), .B(B[15:12]), .Cin(carries[11]), .S(S[15:12]), .carries(carries[15:12]));


    assign Cout = carries[15];
    assign C14 = carries[14];

endmodule