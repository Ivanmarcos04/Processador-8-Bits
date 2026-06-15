module output_register(
    input clk,
    input reset,

    input Lo_n,

    input [7:0] bus_in,

    output reg [7:0] out_data
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        out_data <= 8'b00000000;

    else if(~Lo_n)
        out_data <= bus_in;
end

endmodule