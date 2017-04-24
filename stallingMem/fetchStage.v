module fetchStage(clk, rst, halt, doBranch, branchPc, nextPc, instr, hazStall, memStall);
    input clk, rst, halt, doBranch, hazStall;
    input [15:0] branchPc;
    output memStall;
    output [15:0] instr, nextPc;

    wire haltEn, done, memErr, iCacheHit, needBr, willBr;
    // wire [15:0] newPc, curPc, preInstr, preNextPc, tempInstr, tempNextPc, tempCurInstr, usePc, actInstr;

    // assign memStall = intMemStall;

    wire [15:0] nPc, curPc, preInstr, intNextPc, pcToIncr, pcIncr, tempInstr, intNextInstr, intBrPc, brPc;

    // register pcReg(.clk(clk), .rst(rst), .wData(tempNextPc), .rData(curPc), .wEn( ~halt | ~stall));
    register pcReg(.clk(clk), .rst(rst), .wData(nPc), .rData(curPc), .wEn( (~halt & done) | doBranch));
    // memory2c iMem(.data_out(preInstr), .addr(usePc), .enable(1'h1), .wr(1'h0), .createdump(1'h0), 
    // .clk(clk), .rst(rst));

    stallmem iMem(.DataOut(preInstr), .Done(done), .Stall(memStall), .CacheHit(iCacheHit), .err(memErr), 
        .Addr(pcToIncr), .Rd(1'h1), .Wr(1'h0), .createdump(halt), .clk(clk), .rst(rst), .DataIn(16'h0));


    // incr2 incrPC(.in(usePc), .out(preNextPc));
    incr2 incrPC(.in(pcToIncr), .out(pcIncr));



    assign nPc = (hazStall) ? curPc : pcIncr;

    assign pcToIncr = (needBr) ? brPc :
                        (doBranch) ? branchPc : 
                        curPc;


    assign intNextPc = (~done) ? nextPc : nPc;


    assign intNextInstr = (hazStall) ? tempInstr : preInstr;

    // maybe enable for hazardStalls
    dffEn fPC[15:0](.d(intNextPc), .q(nextPc), .clk(clk), .rst(rst), .en(done));
    dffEn fInst[15:0](.d(intNextInstr), .q(tempInstr), .clk(clk), .rst(rst), .en(done));
    

    assign instr = (doBranch | needBr) ? 16'h0800 : tempInstr; // prevents us from getting a halt while everything is resetting



    assign willBr = (~done) ? needBr | doBranch : doBranch;
    

    assign intBrPc   = (doBranch) ? branchPc : 
                        (~done) ? brPc : 
                        branchPc;

    dffEn brPF[15:0](.d(intBrPc), .q(brPc), .clk(clk), .rst(rst), .en(1'h1));
    

    dff brF(.d(willBr), .q(needBr), .clk(clk), .rst(rst | (doBranch & done)));


    // TODO Issue
    // Branch that happens while proc is stalled doesn't occur
    // need to latch doBranch until not stalled when we can execute the branch


    // assign newPc = (doBranch) ? branchPc : tempNextPc;


    // if branch lookup instruction at branchPC instead of curPC
    // assign usePc = (doBranch) ? branchPc : curPc;

    // newPc is the next pc we will push through pipeline
    // preNextPc is curPc + 2 or the next instruction
    // tempNextPc is either curPc + 2 or curPc, depending on if we stall


    // if doing branch, need newPc = branchPC

    // if we are going to stall, we want to keep the pc the same (nops are inserted in decode stage)
    // assign tempNextPc = (stall) ? usePc : preNextPc;
    // assign actInstr = (stall) ? tempInstr : preInstr;
    //assign tempCurInstr = stall ? preInstr: tempInstr;

    // if we are take a branch we need to clear the pipeline
    // when doBranch = 1, preInstr needs to be instr at 

        // Flop the outputs




    // dff fPC[15:0](.d(tempNextPc), .q(nextPc), .clk(clk), .rst(rst));
    // dff fInst[15:0](.d(actInstr), .q(tempInstr), .clk(clk), .rst(rst));


   // assign haltEn = preInstr == 16'h0;

endmodule
