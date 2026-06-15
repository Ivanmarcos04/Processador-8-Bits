module ram16x8(
    input CE_n,
    input [3:0] address,

    output reg [7:0] data_out
);

reg [7:0] memory [0:15];

integer i;

initial begin

    // Inicializa toda a memoria em 0 (evita valores 'x' nas posicoes nao usadas)
    for(i = 0; i < 16; i = i + 1)
        memory[i] = 8'b0000_0000;

    // Programa exemplo

    memory[0] = 8'b0000_1110; // LDA 14
    memory[1] = 8'b0001_1111; // ADD 15
    memory[2] = 8'b1110_0000; // OUT
    memory[3] = 8'b1111_0000; // HLT

    // Dados

    memory[14] = 8'd5;
    memory[15] = 8'd3;

end

always @(*)
begin
    if(~CE_n)
        data_out = memory[address];
    else
        data_out = 8'b00000000;
end

endmodule