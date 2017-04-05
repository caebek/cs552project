module fetchStage(clk, rst, halt, doBranch, branchPc, nextPc, instr);
    input clk, rst, halt, doBranch;
    input [15:0] branchPc;

    output [15:0] instr, nextPc;

    wire haltEn;
    wire [15:0] newPc, curPc, preInstr, preNextPc;


    register pcReg(.clk(clk), .rst(rst), .wData(newPc), .rData(curPc), .wEn(~haltEn));

    memory2c iMem(.data_out(preInstr), .addr(curPc), .enable(1'h1), .wr(1'h0), .createdump(1'h0), 
    .clk(clk), .rst(rst));

    incr2 incrPC(.in(curPc), .out(preNextPc));

    assign newPc = (doBranch) ? branchPc : preNextPc;
    // assign nextPc = tempPc;

    assign haltEn = halt & ~(curPc == 16'h0);
        // Flop the outputs
        
    dff fPC[15:0](.d(preNextPc), .q(nextPc), .clk(clk), .rst(rst));
    dff fInst[15:0](.d(preInstr), .q(instr), .clk(clk), .rst(rst));



endmodule