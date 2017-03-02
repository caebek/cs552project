module carry4Bit(Cin, G, P, Cout);
        input Cin;
        input [3:0] G, P;
        output [3:0] Cout;



        assign Cout[0] = G[0] | (P[0] & Cin);
        assign Cout[1] = G[1] | (P[1] & Cout[0]);
        assign Cout[2] = G[2] | (P[2] & Cout[1]);
        assign Cout[3] = G[3] | (P[3] & Cout[2]);
    

        // assign PG = &P; 
        // assign GG = G[3] | (G[2] & P[3]) | (G[1] & (&P[3:2])) | (G[0] & (&P[3:1]));


endmodule
