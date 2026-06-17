module add (a, b, c, g, p, s);                   // adder and g, p
    input  a, b, c;                              // inputs:  a, b, c;
    output g, p, s;                              // outputs: g, p, s; 
    assign s = a ^ b ^ c;                        // output: sum of inputs
    assign g = a & b;                            // output: carry generator
    assign p = a | b;                            // output: carry propagator
endmodule
