module alu(
    input [7:0] a_in,
    input [7:0] b_in,

    input Su,
    input Eu,

    output [7:0] alu_out,
    output [7:0] bus_out
);

wire [7:0] result;

assign result = (Su) ? (a_in - b_in) :
                       (a_in + b_in);

assign alu_out = result;

assign bus_out = (Eu) ? result :
                        8'b00000000;

endmodule