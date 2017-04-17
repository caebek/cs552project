module shifter (In, Cnt, Op, Out);
   
   input [15:0] In;
   input [3:0]  Cnt;
   input [2:0]  Op;
   output [15:0] Out;
   wire [15:0] Out1, Out2, Out3;
   /*
   Your code goes here
   */
   shift1Bit shift1(.en(Cnt[0]), .op(Op), .out(Out1), .dataIn(In));
   shift2Bit shift2(.en(Cnt[1]), .op(Op), .out(Out2), .dataIn(Out1));
   shift4Bit shift4(.en(Cnt[2]), .op(Op), .out(Out3), .dataIn(Out2));
   shift8Bit shift8(.en(Cnt[3]), .op(Op), .out(Out), .dataIn(Out3));
endmodule

