module pc(
    input clk,
    input reset,
    input Cp,

    output reg [3:0] pc_out
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        pc_out <= 4'b0000;

    else if(Cp)
        pc_out <= pc_out + 1'b1;
end

endmodule