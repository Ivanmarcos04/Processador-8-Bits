// ============================================================
// IR - Instruction Register (8 bits)
// Armazena a instrucao buscada da RAM.
// Dividido em dois nibbles:
//   [7:4] opcode  -> vai para o controlador FSM
//   [3:0] operand -> vai para o barramento (quando Ei_n=0)
// ============================================================
module ir(
    input clk,
    input reset,

    input Li_n,       // Load IR  (ativo em 0): carrega instrucao
    input Ei_n,       // Enable IR(ativo em 0): operand -> barramento

    input [7:0] bus_in,   // barramento principal (8 bits)

    output [3:0] opcode,  // nibble alto -> FSM
    output [3:0] operand, // nibble baixo (endereco do operando)
    output [7:0] bus_out  // operand zero-extended no barramento
);

reg [7:0] instruction;

always @(posedge clk or posedge reset)
begin
    if(reset)
        instruction <= 8'b00000000;
    else if(~Li_n)
        instruction <= bus_in; // carrega instrucao do barramento
end

assign opcode  = instruction[7:4];
assign operand = instruction[3:0];

// Quando Ei_n=0, coloca o operando (4 bits) no barramento (zero-extended)
assign bus_out = (~Ei_n) ? {4'b0000, operand} : 8'b00000000;

endmodule