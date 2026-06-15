// ============================================================
// MAR - Memory Address Register
// Armazena o endereco de 4 bits que aponta para a RAM.
// Recebe os 4 bits menos significativos do barramento W.
// Carregado quando Lm_n = 0 na borda de subida do clock.
// ============================================================
module mar(
    input clk,
    input reset,
    input Lm_n,

    input [7:0] bus_in,   // barramento principal de 8 bits

    output reg [3:0] mar_out
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        mar_out <= 4'b0000;

    else if(~Lm_n)
        mar_out <= bus_in[3:0]; // usa os 4 LSB do barramento
end

endmodule