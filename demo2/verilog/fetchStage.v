module fetchStage(clk, rst, halt, doBranch, branchPc, nextPc, instr, stall);
    input clk, rst, halt, doBranch, stall;
    input [15:0] branchPc;

    output [15:0] instr, nextPc;

    wire haltEn;
    wire [15:0] newPc, curPc, preInstr, preNextPc, tempInstr, tempNextPc, tempCurInstr;


    register pcReg(.clk(clk), .rst(rst), .wData(newPc), .rData(curPc), .wEn( ~halt | ~stall));

    memory2c iMem(.data_out(preInstr), .addr(curPc), .enable(1'h1), .wr(1'h0), .createdump(1'h0), 
    .clk(clk), .rst(rst));

    incr2 incrPC(.in(curPc), .out(preNextPc));

    assign newPc = (doBranch) ? branchPc : tempNextPc;

    // assign nextPc = tempPc;

    // assign haltEn = halt & ~(curPc == 16'h0);

    assign tempNextPc = (stall) ? curPc : preNextPc;
    //assign tempCurInstr = stall ? preInstr: tempInstr;

        // Flop the outputs
    dff fPC[15:0](.d(tempNextPc), .q(nextPc), .clk(clk), .rst(rst));
    dff fInst[15:0](.d(preInstr), .q(tempInstr), .clk(clk), .rst(rst));

    assign instr = (curPc == 16'h0 | doBranch) ? 16'h0800 : tempInstr; // prevents us from getting a halt while everything is resetting

   // assign haltEn = preInstr == 16'h0;

endmodule
