module fmtDecode(opCode, fmt);
    input [4:0] opCode;
    output reg [2:0] fmt;

    localparam J = 3'h0;
    localparam I1 = 3'h1;
    localparam I2 = 3'h2;
    localparam R = 3'h3;
    localparam SP = 3'h4;
    localparam IL = 3'h7;


    always@(*) begin
        casex(opCode)
            5'b000xx: fmt = SP;
            5'b001x0: fmt = J;
            5'b011xx: fmt = I2;
            5'b001x1: fmt = I2;
            5'b11000: fmt = I2; // special case, else 11xxx is type R
            5'b10010: fmt = I2;
            5'b010xx: fmt = I1;
            5'b101xx: fmt = I1;
            5'b1000x: fmt = I1;
            5'b10011: fmt = I1;
            // 5'b111xx: fmt = R;
            // 5'b110x1: fmt = R;
            // 5'b11010: fmt = R;
            5'b11xxx: fmt = R; // needs to be after 11000 case
            default: fmt = IL; // more or less asserting error 
        endcase
    end







endmodule