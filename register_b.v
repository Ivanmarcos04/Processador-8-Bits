module register_b(
    input clk,
    input reset,

    input Lb_n,

    input [7:0] bus_in,

    output [7:0] b_out
);

reg [7:0] B;

always @(posedge clk or posedge reset)
begin
    if(reset)
        B <= 8'b00000000;

    else if(~Lb_n)
        B <= bus_in;
end

assign b_out = B;

endmodule