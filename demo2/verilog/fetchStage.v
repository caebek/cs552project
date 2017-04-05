module fetchStage(clk, rst, halt, doBranch, branchPc, nextPc, instr);
    input clk, rst, halt, doBranch;
    input [15:0] branchPc;
    output [15:0] instr, nextPc;


    wire [15:0] newPc, curPc;

    register pcReg(.clk(clk), .rst(rst), .wData(newPc), .rData(curPc), .wEn(~haltEn));

    memory2c iMem(.data_out(instr), .addr(curPc), .enable(1'h1), .wr(1'h0), .createdump(1'h0), 
    .clk(clk), .rst(rst));

    incr2 incrPC(.in(curPc), .out(nextPc));

    assign newPc = (doBranch) ? branchPc : nextPc;


endmodule