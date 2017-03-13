module alu (A, B, Cin, Op, invA, invB, sign, Out, Ofl, Zero, N);
   
    input [15:0] A;
    input [15:0] B;
    input Cin;
    input [3:0] Op;
    input invA;
    input invB;
    input sign;
    output reg[15:0]  Out;
    output reg Ofl;
    output Zero;
    output N;

    /*
    Your code goes here
    */

    // make stuff more readable
    localparam rll = 4'h0;
    localparam sll = 4'h1;
    localparam sra = 4'h2;
    localparam srl = 4'h3;
    localparam add = 4'h4;
    localparam OR = 4'h5;
    localparam XOR = 4'h6;
    localparam AND = 4'h7;
    localparam ROR = 4'b1xxx;


    wire [15:0] addOut, shiftOut, inA, inB;
    wire cout, c14;

    // Select correct input to use
    assign inA = (invA) ? ~A : A;
    assign inB = (invB) ? ~B : B;


    shifter shift(.In(inA), .Cnt(inB[3:0]), .Op({Op[3],Op[1:0]}), .Out(shiftOut));
    cla16Bit adder(.A(inA), .B(inB), .Cin(Cin), .S(addOut), .Cout(cout), .C14(c14));

    // TODO Add adder 


    assign Zero = ~|Out;
    assign N = Out[15];

    always@(*) begin
        casex (Op)
            rll: begin
                Out = shiftOut;
                Ofl = 0;
            end
            sll: begin
                Out = shiftOut;
                Ofl = 0;
            end
            sra: begin
                Out = shiftOut;
                Ofl = 0;
            end
            srl: begin 
                Out = shiftOut;
                Ofl = 0;
            end
            add: begin
                Out = addOut;
                Ofl = (sign) ? cout ^ c14 : cout;
            end
            OR: begin
                Out = inA | inB;
                Ofl = 0;
            end
            XOR: begin
                Out = inA ^ inB;
                Ofl = 0;
            end
            AND: begin
                Out = inA & inB;
                Ofl = 0;
            end
            ROR: begin
                Out = shiftOut;
                Ofl = 0;
            end
            default: begin
                Ofl = 0;
                Out = 16'hZ;
            end
        endcase
    end


endmodule
