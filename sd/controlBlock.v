module controlBlock(opCode, func, halt, sign, pcOffSel, regWrt, memWrt, memToReg, memEn, jump, invA, invB, aluSrc, err,
    regDst, regWrtSrc, aluOp, return, cin, brType, stall);
    input [4:0] opCode;
    input [1:0] func;
    input stall;

    output reg halt, sign, regWrt, pcOffSel, memWrt, memToReg, memEn, jump, 
    			invA, invB, err, return, cin;
    output reg [1:0] regDst;
    output reg [3:0] aluOp;
    output reg [2:0] aluSrc, regWrtSrc, brType;

    wire [4:0] tempOp;


    // I1
    localparam ADDI = 5'b01000;
    localparam SUBI = 5'b01001;
    localparam XORI = 5'b01010;
    localparam ANDNI = 5'b01011;
    localparam ROLI = 5'b10100;
    localparam SLLI = 5'b10101;
    localparam RORI = 5'b10110;
    localparam SRLI = 5'b10111;
    localparam ST = 5'b10000;
    localparam LD = 5'b10001;
    localparam STU = 5'b10011;
    
    //R
    localparam BTR = 5'b11001;
    localparam ALU_OP1 = 5'b11011;
    localparam ALU_OP2 = 5'b11010;
    localparam SEQ = 5'b11100;
    localparam SLT = 5'b11101;
    localparam SLE = 5'b11110;
    localparam SCO = 5'b11111;


    // I2
    localparam LBI = 5'b11000;
    localparam SLBI = 5'b10010;
    localparam JR = 5'b00101;
    localparam JALR = 5'b00111;
    localparam BEQZ = 5'b01100;
    localparam BNEZ = 5'b01101;
    localparam BLTZ = 5'b01110;
    localparam BGEZ = 5'b01111;
    //J
    localparam J = 5'b00100;
    localparam JAL = 5'b00110;
    // SP
    localparam SIIC = 5'b00010;
    localparam RTI = 5'b00011;
    localparam HALT = 5'b00000;
    localparam NOP = 5'b00001;

    localparam ALU_ADD = 2'h0;
    localparam ALU_SUB = 2'h1;
    localparam ALU_XOR = 2'h2;
    localparam ALU_ANDN = 2'h3;

    localparam ALU_ROL = 2'h0;
    localparam ALU_SLL = 2'h1;
    localparam ALU_ROR = 2'h2;
    localparam ALU_SRL= 2'h3;
    localparam DC = 2'bxx;


    // Branch Types
   localparam NOBR = 3'h0;
   localparam EQZ = 3'h1;
   localparam NEZ = 3'h2;
   localparam LTZ = 3'h3;
   localparam GEQZ = 3'h4;



   assign tempOp = stall ? NOP : opCode;
    // determine which format the instruction is
   	// is it even worth though? 
   	// better to just have huge case statement for each opcode/function
   	// and assign control sigs for there
    // fmtDecode fmt(.opCode(opCode), .fmt(format));

    always@(tempOp, func) begin
    	halt = 0;
    	sign = 1'h0;
    	pcOffSel = 1'h0;
    	regWrt = 0;
    	memWrt = 0;
    	memToReg = 0; // needed? only for pipeline?
    	memEn = 0;
    	jump = 0;
        return  = 0;
    	invA = 0;
    	invB = 0;
    	regDst = 0;
    	regWrtSrc = 1;
    	aluOp = 4;
    	err = 0;
        cin = 1'h0;

        aluSrc = 3'h4;
        brType = NOBR;


    	casex({tempOp,func})

/************************ r instr ****************************/
            {BTR, DC}: begin
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h6;
                
                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                // aluSrc = 3'h0;
                // aluOp = 4'h0;
            end

            {ALU_OP1, ALU_ADD}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;
                cin = 1'h0;
                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b100;
                
            end

            {ALU_OP1, ALU_SUB}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h1;
                invB = 1'h0;
                cin = 1'h1;

                aluSrc = 3'h4;
                aluOp = 4'b100;

            end
            {ALU_OP1, ALU_XOR}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b110;

            end
            {ALU_OP1, ALU_ANDN}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b111;

            end
            {ALU_OP2, ALU_ROL}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b000;

            end
            {ALU_OP2, ALU_SLL}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b001;

            end
            {ALU_OP2, ALU_ROR}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
                
                aluSrc = 3'h4;
                //TODO:
                aluOp = 4'b1000;

            end
            {ALU_OP2, ALU_SRL}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b011;

            end
            {SEQ, DC}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h3;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h1;

                aluSrc = 3'h4;
                aluOp = 4'b100;

            end
            {SLT, DC}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h3;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h1;

                aluSrc = 3'h4;
                aluOp = 4'b100;

            end
            {SLE, DC}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h3;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h1;

                aluSrc = 3'h4;
                aluOp = 4'b100;

            end
            {SCO, DC}: begin
                sign = 1'h0;
                regWrt = 1'h1;
                regDst = 2'h2;
                regWrtSrc = 3'h3;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h4;
                aluOp = 4'b100;

            end
/****************************************************************/



/********************** i1 instr ****************************/            

            {ADDI, DC}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h0;
                aluOp = 4'b100;

            end
            {SUBI, DC}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h1;
                invB = 1'h0;
                cin = 1'h1;

                aluSrc = 3'h0;
                aluOp = 4'b100;

            end
            
            {XORI, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h1;
                aluOp = 4'b110;

            end
            {ANDNI, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h0;

                aluSrc = 3'h1;
                aluOp = 4'b111;

            end
            {ROLI, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h1;
                aluOp = 4'b000;

            end

            {SLLI, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                aluSrc = 3'h1;
                aluOp = 4'b001;

            end

            {RORI, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
                aluSrc = 3'h1;
                //TODO:
                aluOp = 4'b1000;

            end
            
            {SRLI, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h1;

                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
                
                aluSrc = 3'h1;
                aluOp = 4'b011;

            end
            
            {ST, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h0;
                // regDst = 2'hx;
                // regWrtSrc = 3'hx;

                memWrt = 1'h1;
                memEn = 1'h1;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
                
                aluSrc = 3'h0;
                aluOp = 4'b100;

            end
            
            {LD, DC}: begin
                // sign = 1'hx;
                regWrt = 1'h1;
                regDst = 2'h0;
                regWrtSrc = 3'h0;

                memWrt = 1'h0;
                memEn = 1'h1;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
                
                aluSrc = 3'h0;
                aluOp = 4'b100;

            end
            {STU, DC}: begin
                sign = 1'h1;
                regWrt = 1'h1;
                regDst = 2'h1;
                regWrtSrc = 3'h1;

                memWrt = 1'h1;
                memEn = 1'h1;

                jump = 1'h0;
                return = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
                
                aluSrc = 3'h0;
                aluOp = 4'b100;

            end
/****************************************************************/

/*************************** i2 instr ***************************/
            {LBI,DC}: begin
    			regWrt = 1'h1;
    			regDst = 2'h1;
    			regWrtSrc = 3'h4;
    		end


            {SLBI, DC}: begin
                regWrt = 1'h1;
                regDst = 2'h1;
                regWrtSrc = 3'h5;
            end


            {JR, DC}: begin
                pcOffSel = 1'h0;
                regWrt = 1'h0;
                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h1;
                return = 1'h1;
            end    
            {JALR, DC}: begin
                sign = 1'h0;
                pcOffSel = 1'h0;
                regWrt = 1'h1;
                memWrt = 1'h0;
                memEn = 1'h0;


                jump = 1'h1;
                return = 1'h1;

                invA = 1'h0;
                invB = 1'h0;

                regDst = 2'h3;
                regWrtSrc = 3'h2;


            end        

            {BEQZ, DC}: begin
                aluSrc = 3'h5;
                aluOp = 4'b100;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

                pcOffSel = 1'h0;
                jump = 1'h0;
                return = 1'h0;
                brType = EQZ;

                regWrt = 1'h0;

                memWrt = 1'h0;
                memEn = 1'h0;
            end            
            {BNEZ, DC}: begin
                aluSrc = 3'h5;
                aluOp = 4'b100;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

                pcOffSel = 1'h0;
                jump = 1'h0;
                return = 1'h0;
                brType = NEZ;

                regWrt = 1'h0;

                memWrt = 1'h0;
                memEn = 1'h0;
            end            
            {BLTZ, DC}: begin
                aluSrc = 3'h5;
                aluOp = 4'b100;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

                pcOffSel = 1'h0;
                jump = 1'h0;
                return = 1'h0;
                brType = LTZ;

                regWrt = 1'h0;

                memWrt = 1'h0;
                memEn = 1'h0;
            end
            {BGEZ, DC}: begin
                aluSrc = 3'h5;
                aluOp = 4'b100;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

                pcOffSel = 1'h0;
                jump = 1'h0;
                return = 1'h0;
                brType = GEQZ;

                regWrt = 1'h0;

                memWrt = 1'h0;
                memEn = 1'h0;
            end      
            
            



/*************************** J instr ***************************/

            {J, DC}: begin
                pcOffSel = 1'h1;
                regWrt = 1'h0;
                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h1;
                return = 1'h0;
            end

            {JAL, DC}: begin
                pcOffSel = 1'h1;
                regWrt = 1'h1;
                memWrt = 1'h0;
                memEn = 1'h0;

                jump = 1'h1;
                return = 1'h0;


                regDst = 2'h3;
                regWrtSrc = 3'h2;
            end


/********************** special instr **************************/
            {HALT, DC}: begin
                halt = 1;
            end
            {NOP, DC}: begin
                err = 1'h0;
            end
            
            // {STU, DC}: begin
                // sign = 1'hx;
            //     regWrt = 1'h1;
            //     regDst = 2'h1;
            //     regWrtSrc = 3'h0;

            //     memWrt = 1'h1;
            //     memEn = 1'h1;

            //     jump = 1'h0;
            //     return = 1'h0;
            //     invA = 1'h0;
            //     invB = 1'h0;
            //     cin = 1'h0;
                
            //     aluOp = 4'b100;

            // end









               // aluSrc = 3'h2;


            default: err = 1;
        endcase

    end


endmodule
