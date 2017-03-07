module controlBlock(opCode, func, halt, sign, pcOffSel, regWrt, memWrt, memToReg, memEn, jump, invA, invB, aluSrc, 
    regDst, regWrtSrc, immSel, aluOp);
    input [4:0] opCode;
    input [1:0] func;

    output halt, sign regWrt, pcOffSel, regWrt, memWrt, memToReg, memEn, jump, invA, invB, aluSrc;
    output [1:0] regDst, regWrtSrc, immSel aluOp;
    // output [2:0] 

    

    



endmodule