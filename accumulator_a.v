module accumulator_a(
    input clk,
    input reset,

    input La_n,
    input Ea,

    input [7:0] bus_in,

    output [7:0] bus_out,
    output [7:0] a_out
);

reg [7:0] A;

always @(posedge clk or posedge reset)
begin
    if(reset)
        A <= 8'b00000000;

    else if(~La_n)
        A <= bus_in;
end

assign a_out = A;

assign bus_out = (Ea) ? A : 8'b00000000;

endmodule