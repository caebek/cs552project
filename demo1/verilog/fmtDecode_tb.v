module fmtDecode_tb();

    reg [4:0] op;
    wire [2:0] format;

    fmtDecode fmt(.opCode(op), .fmt(format));

    initial begin
        op = 5'h0;
    end

    always begin
        #1
        $display("OpCode: %b Format %d", op, format);
        if(op == 5'h1f)
            $finish();
        #4
        op = op + 1;

    end

endmodule