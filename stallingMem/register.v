module register(clk, rst, wData, rData, wEn);
    parameter width = 5'h10; // decimal 16

    input clk, rst, wEn;
    input [width-1:0] wData;
    output [width-1:0] rData;

    wire [width-1:0] write_data;


    assign write_data = (wEn) ? wData : rData;



    dff flop[width-1:0](.clk(clk), .rst(rst), .d(write_data), .q(rData));
endmodule