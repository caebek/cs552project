module fetchStage(clk, rst, halt, doBranch, branchPc, nextPc, instr, stall);
    input clk, rst, halt, doBranch, stall;
    input [15:0] branchPc;

    output [15:0] instr, nextPc;

    wire haltEn;
    wire [15:0] newPc, curPc, preInstr, preNextPc, tempInstr, tempNextPc, tempCurInstr, usePc, actInstr;


    register pcReg(.clk(clk), .rst(rst), .wData(tempNextPc), .rData(curPc), .wEn( ~halt | ~stall));

    memory2c iMem(.data_out(preInstr), .addr(usePc), .enable(1'h1), .wr(1'h0), .createdump(1'h0), 
    .clk(clk), .rst(rst));

    incr2 incrPC(.in(usePc), .out(preNextPc));

    // assign newPc = (doBranch) ? branchPc : tempNextPc;


    // if branch lookup instruction at branchPC instead of curPC
    assign usePc = (doBranch) ? branchPc : curPc;

    // newPc is the next pc we will push through pipeline
    // preNextPc is curPc + 2 or the next instruction
    // tempNextPc is either curPc + 2 or curPc, depending on if we stall


    // if doing branch, need newPc = branchPC

    // if we are going to stall, we want to keep the pc the same (nops are inserted in decode stage)
    assign tempNextPc = (stall) ? usePc : preNextPc;
    assign actInstr = (stall) ? tempInstr : preInstr;
    //assign tempCurInstr = stall ? preInstr: tempInstr;

    // if we are take a branch we need to clear the pipeline
    // when doBranch = 1, preInstr needs to be instr at 

        // Flop the outputs
    dff fPC[15:0](.d(tempNextPc), .q(nextPc), .clk(clk), .rst(rst));
    dff fInst[15:0](.d(actInstr), .q(tempInstr), .clk(clk), .rst(rst));

    // assign instr = (doBranch) ? 16'h0800 : tempInstr; // prevents us from getting a halt while everything is resetting
    assign instr = tempInstr;
   // assign haltEn = preInstr == 16'h0;

endmodule
