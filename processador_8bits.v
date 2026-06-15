// ============================================================
// Processador 8 bits - Modulo Principal
// UFAM - Faculdade de Eletronica e Computacao (FEEC)
// Prof. Dr. Thiago Brito - Lista 4
//
// Arquitetura:
//   - Barramento W de 8 bits (bus8)
//   - RAM 16x8
//   - PC (4 bits), MAR (4 bits), IR (8 bits)
//   - Acumulador A (8 bits), Registrador B (8 bits)
//   - ALU (soma/subtracao)
//   - Registrador de Saida (8 bits) -> LEDs
//   - Controlador/Sequenciador FSM
//
// Instrucoes suportadas:
//   LDA 0000 - carrega memoria no acumulador
//   ADD 0001 - soma memoria ao acumulador
//   SUB 0010 - subtrai memoria do acumulador
//   OUT 1110 - acumulador -> registrador de saida (LEDs)
//   HLT 1111 - para o processamento
// ============================================================
module processador_8bits(
    input clk,
    input reset,

    output [7:0] leds
);

    // ==========================================================
    // Barramento Principal W (8 bits)
    // ==========================================================

    wire [7:0] bus8;

    // ==========================================================
    // Sinais de Controle (palavra de 12 bits)
    // Cp Ep ~Lm ~CE ~Li ~Ei ~La Ea Su Eu ~Lb ~Lo
    // ==========================================================

    wire Cp;      // Counter Program   - incrementa PC
    wire Ep;      // Enable PC         - PC -> barramento
    wire Lm_n;    // Load MAR (ativo 0)- carrega MAR
    wire CE_n;    // Chip Enable RAM(0)- RAM -> barramento
    wire Li_n;    // Load IR (ativo 0) - carrega IR
    wire Ei_n;    // Enable IR (ativo 0)- IR.operand -> barramento

    wire La_n;    // Load Acum (ativo 0)- carrega acumulador
    wire Ea;      // Enable Acum       - A -> barramento
    wire Su;      // Subtract          - configura ALU p/ subtr.
    wire Eu;      // Enable ALU        - ALU -> barramento

    wire Lb_n;    // Load Reg B(ativo 0)- carrega registrador B
    wire Lo_n;    // Load OUT (ativo 0) - carrega reg. de saida

    wire [2:0] state; // estado atual da FSM (debug)

    // ==========================================================
    // PC - Program Counter (4 bits)
    // ==========================================================

    wire [3:0] pc_out;
    wire [7:0] pc_bus; // PC no barramento (8 bits, zero-extended)

    pc PC(
        .clk(clk),
        .reset(reset),
        .Cp(Cp),
        .pc_out(pc_out)
    );

    // PC coloca seu valor no barramento quando Ep = 1
    assign pc_bus = (Ep) ? {4'b0000, pc_out} : 8'b00000000;

    // ==========================================================
    // MAR - Memory Address Register (4 bits)
    // Recebe os 4 LSB do barramento W
    // ==========================================================

    wire [3:0] mar_out;

    mar MAR(
        .clk(clk),
        .reset(reset),
        .Lm_n(Lm_n),
        .bus_in(bus8),      // CORRECAO: recebe do barramento principal
        .mar_out(mar_out)
    );

    // ==========================================================
    // RAM 16x8
    // ==========================================================

    wire [7:0] ram_out;
    wire [7:0] ram_bus;

    ram16x8 RAM(
        .CE_n(CE_n),
        .address(mar_out),
        .data_out(ram_out)
    );

    assign ram_bus = (~CE_n) ? ram_out : 8'b00000000;

    // ==========================================================
    // IR - Instruction Register (8 bits)
    // ==========================================================

    wire [3:0] opcode;
    wire [3:0] operand;
    wire [7:0] ir_bus;

    ir IR(
        .clk(clk),
        .reset(reset),
        .Li_n(Li_n),
        .Ei_n(Ei_n),
        .bus_in(bus8),
        .opcode(opcode),
        .operand(operand),
        .bus_out(ir_bus)
    );

    // ==========================================================
    // Acumulador A (8 bits)
    // ==========================================================

    wire [7:0] a_out;
    wire [7:0] a_bus;

    accumulator_a A(
        .clk(clk),
        .reset(reset),
        .La_n(La_n),
        .Ea(Ea),
        .bus_in(bus8),
        .bus_out(a_bus),
        .a_out(a_out)
    );

    // ==========================================================
    // Registrador B (8 bits)
    // ==========================================================

    wire [7:0] b_out;

    register_b B(
        .clk(clk),
        .reset(reset),
        .Lb_n(Lb_n),
        .bus_in(bus8),
        .b_out(b_out)
    );

    // ==========================================================
    // ALU - Adder/Subtractor (8 bits)
    // ==========================================================

    wire [7:0] alu_out;
    wire [7:0] alu_bus;

    alu ALU(
        .a_in(a_out),
        .b_in(b_out),
        .Su(Su),
        .Eu(Eu),
        .alu_out(alu_out),
        .bus_out(alu_bus)
    );

    // ==========================================================
    // Registrador de Saida (8 bits) -> LEDs
    // ==========================================================

    wire [7:0] out_data;

    output_register OUT_REG(
        .clk(clk),
        .reset(reset),
        .Lo_n(Lo_n),
        .bus_in(bus8),
        .out_data(out_data)
    );

    // ==========================================================
    // FSM - Controlador/Sequenciador
    // ==========================================================

    controller_fsm CTRL(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),

        .Cp(Cp),
        .Ep(Ep),
        .Lm_n(Lm_n),
        .CE_n(CE_n),
        .Li_n(Li_n),
        .Ei_n(Ei_n),

        .La_n(La_n),
        .Ea(Ea),
        .Su(Su),
        .Eu(Eu),

        .Lb_n(Lb_n),
        .Lo_n(Lo_n),

        .state(state)
    );

    // ==========================================================
    // Barramento W (bus8) - multiplexador de 8 bits (wired-OR)
    // Apenas um modulo dirige o barramento por vez; os demais
    // emitem 0, entao o OR das fontes seleciona a ativa.
    // ==========================================================
    assign bus8 = ram_bus  |  // RAM quando CE_n=0
                  alu_bus  |  // ALU quando Eu=1
                  a_bus    |  // Acum quando Ea=1
                  pc_bus   |  // PC  quando Ep=1
                  ir_bus;     // IR  quando Ei_n=0 (4 LSB)

    // ==========================================================
    // LEDs
    // ==========================================================
    assign leds = out_data;

endmodule