module shift2Bit(en, op, dataIn, out);
    input en;
    input [1:0] op;
    input [15:0] dataIn;
    output [15:0] out;



    // wire lsb, msb;

    reg [15:0] shiftOut;


    // assign msb = (op[0]) ? 1'b0 : dataIn[15];
    // assign lsb = (op[0]) ? 1'b0 : dataIn[14];

    
    // assign shiftVal[0] = (op[1]) ? dataIn[2] : lsb;
    // assign shiftVal[1] = (op[1]) ? dataIn[3] : msb;
    // assign shiftVal[2] = (op[1]) ? dataIn[4] : dataIn[0];
    // assign shiftVal[3] = (op[1]) ? dataIn[5] : dataIn[1];
    // assign shiftVal[4] = (op[1]) ? dataIn[6] : dataIn[2];
    // assign shiftVal[5] = (op[1]) ? dataIn[7] : dataIn[3];
    // assign shiftVal[6] = (op[1]) ? dataIn[8] : dataIn[4];
    // assign shiftVal[7] = (op[1]) ? dataIn[9] : dataIn[5];
    // assign shiftVal[8] = (op[1]) ? dataIn[10] : dataIn[6];
    // assign shiftVal[9] = (op[1]) ? dataIn[11] : dataIn[7];
    // assign shiftVal[10] = (op[1]) ? dataIn[12] : dataIn[8];
    // assign shiftVal[11] = (op[1]) ? dataIn[13] : dataIn[9];
    // assign shiftVal[12] = (op[1]) ? dataIn[14] : dataIn[10];
    // assign shiftVal[13] = (op[1]) ? dataIn[15] : dataIn[11];
    // assign shiftVal[14] = (op[1]) ? msb : dataIn[12];
    // assign shiftVal[15] = (op[1]) ? msb : dataIn[13];

    // assign out  = (en) ? shiftVal : dataIn;
    always@(*) begin
        case(op)
            2'h0:
                shiftOut = {dataIn[13:0], dataIn[15:14]};
            2'h1:
                shiftOut = {dataIn[13:0], {2{1'b0}}};
            2'h2:
                shiftOut = {{2{dataIn[15]}}, dataIn[15:2]};
            2'h3:
                shiftOut = {{2{1'b0}}, dataIn[15:2]};
            default:
                shiftOut = dataIn;
        endcase
    end

    assign out = (en) ? shiftOut : dataIn;



endmodule