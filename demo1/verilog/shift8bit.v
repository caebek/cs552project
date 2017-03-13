module shift8Bit(en, op, dataIn, out);
    input en;
    input [2:0] op;
    input [15:0] dataIn;
    output [15:0] out;



    // wire lsb, msb;

    reg [15:0] shiftOut;


    // assign msb = (op[0]) ? 1'b0 : dataIn[15];
    // assign lsb = (op[0]) ? 1'b0 : dataIn[8];
    // assign bit1 = (op[0]) ? 1'b0 : dataIn[9];
    // assign bit2 = (op[0]) ? 1'b0 : dataIn[10];
    // assign bit3 = (op[0]) ? 1'b0 : dataIn[11];
    // assign bit4 = (op[0]) ? 1'b0 : dataIn[12];
    // assign bit5 = (op[0]) ? 1'b0 : dataIn[13];
    // assign bit6 = (op[0]) ? 1'b0 : dataIn[14];
    // assign bit7 = (op[0]) ? 1'b0 : dataIn[15];




    // assign shiftVal[0] = (op[1]) ? dataIn[8] : lsb;
    // assign shiftVal[1] = (op[1]) ? dataIn[9] : bit1;
    // assign shiftVal[2] = (op[1]) ? dataIn[10] : bit2;
    // assign shiftVal[3] = (op[1]) ? dataIn[11] : bit3;
    // assign shiftVal[4] = (op[1]) ? dataIn[12] : bit4;
    // assign shiftVal[5] = (op[1]) ? dataIn[13] : bit5;
    // assign shiftVal[6] = (op[1]) ? dataIn[14] : bit6;
    // assign shiftVal[7] = (op[1]) ? dataIn[15] : bit7;
    // assign shiftVal[8] = (op[1]) ? msb : dataIn[0];
    // assign shiftVal[9] = (op[1]) ? msb : dataIn[1];
    // assign shiftVal[10] = (op[1]) ? msb : dataIn[2];
    // assign shiftVal[11] = (op[1]) ? msb : dataIn[3];
    // assign shiftVal[12] = (op[1]) ? msb : dataIn[4];
    // assign shiftVal[13] = (op[1]) ? msb : dataIn[5];
    // assign shiftVal[14] = (op[1]) ? msb : dataIn[6];
    // assign shiftVal[15] = (op[1]) ? msb : dataIn[7];

    always@(*) begin
        casex(op)
            3'h0:
                shiftOut = {dataIn[7:0], dataIn[15:8]};
            3'h1:
                shiftOut = {dataIn[7:0], {8{1'b0}}};
            3'h2:
                shiftOut = {{8{dataIn[15]}}, dataIn[15:8]};
            3'h3:
                shiftOut = {{8{1'b0}}, dataIn[15:8]};
            3'b1xx:
                shiftOut = {dataIn[7:0], dataIn[15:8]};

            default:
                shiftOut = dataIn;
        endcase
    end

    assign out = (en) ? shiftOut : dataIn;

endmodule