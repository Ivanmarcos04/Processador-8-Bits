// ============================================================
// Controller FSM - Unidade de Controle / Sequenciador
// Implementa os 6 estados T1-T6 (ciclo de busca + execucao).
// Gera a palavra de controle de 12 bits:
//   Cp Ep ~Lm ~CE ~Li ~Ei ~La Ea Su Eu ~Lb ~Lo
//
// Ciclo de Busca (igual para todas as instrucoes):
//   T1: Ep=1, Lm_n=0  -> PC -> MAR
//   T2: Cp=1           -> PC++
//   T3: CE_n=0, Li_n=0 -> RAM[MAR] -> IR
//
// Ciclo de Execucao (depende do opcode):
//   LDA: T4: Ei_n=0, Lm_n=0 | T5: CE_n=0, La_n=0 | T6: idle
//   ADD: T4: Ei_n=0, Lm_n=0 | T5: CE_n=0, Lb_n=0 | T6: Eu=1, La_n=0
//   SUB: T4: Ei_n=0, Lm_n=0 | T5: CE_n=0, Lb_n=0 | T6: Su=1, Eu=1, La_n=0
//   OUT: T4: Ea=1, Lo_n=0   | T5: idle            | T6: idle
//   HLT: T4-T6: idle (todos os sinais em default)
// ============================================================
module controller_fsm(
    input clk,
    input reset,

    input [3:0] opcode,

    output reg Cp,
    output reg Ep,
    output reg Lm_n,
    output reg CE_n,
    output reg Li_n,
    output reg Ei_n,

    output reg La_n,
    output reg Ea,
    output reg Su,
    output reg Eu,

    output reg Lb_n,
    output reg Lo_n,

    output reg [2:0] state
);

// Estados
parameter T1 = 3'd0;
parameter T2 = 3'd1;
parameter T3 = 3'd2;
parameter T4 = 3'd3;
parameter T5 = 3'd4;
parameter T6 = 3'd5;

// Opcodes
parameter LDA = 4'b0000;
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter OUT = 4'b1110;
parameter HLT = 4'b1111;

// Flag de parada (HLT): quando setado, congela o sequenciador
reg halted;

// -------------------------------------------------------
// Sequenciador: avanca o estado a cada borda de subida.
// Para de avancar permanentemente apos decodificar HLT.
// -------------------------------------------------------
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state  <= T1;
        halted <= 1'b0;
    end
    else if(!halted)
    begin
        case(state)
            T1: state <= T2;
            T2: state <= T3;
            T3: state <= T4;
            T4:
            begin
                // HLT ja esta decodificado em T4: congela o processador
                if(opcode == HLT)
                    halted <= 1'b1;   // permanece em T4, nao avanca mais
                else
                    state <= T5;
            end
            T5: state <= T6;
            T6: state <= T1;
            default: state <= T1;
        endcase
    end
end

// -------------------------------------------------------
// Logica combinacional de controle
// -------------------------------------------------------
always @(*)
begin
    // Defaults: sinais ativos baixos em 1 (inativo), ativos altos em 0
    Cp   = 0;
    Ep   = 0;
    Lm_n = 1;
    CE_n = 1;
    Li_n = 1;
    Ei_n = 1;

    La_n = 1;
    Ea   = 0;
    Su   = 0;
    Eu   = 0;

    Lb_n = 1;
    Lo_n = 1;

    case(state)

        // ==================================================
        // CICLO DE BUSCA
        // ==================================================

        T1: // Endereco: coloca PC no barramento, carrega MAR
        begin
            Ep   = 1;   // PC -> barramento
            Lm_n = 0;   // MAR <- barramento
        end

        T2: // Incremento: PC++
        begin
            Cp = 1;
        end

        T3: // Memoria: RAM[MAR] -> IR
        begin
            CE_n = 0;   // RAM -> barramento
            Li_n = 0;   // IR  <- barramento
        end

        // ==================================================
        // CICLO DE EXECUCAO
        // ==================================================

        T4:
        begin
            case(opcode)

                LDA: // operando do IR -> MAR (para buscar dado)
                begin
                    Ei_n = 0;   // IR.operand -> barramento
                    Lm_n = 0;   // MAR <- barramento
                end

                ADD: // operando do IR -> MAR (para buscar dado)
                begin
                    Ei_n = 0;
                    Lm_n = 0;
                end

                SUB: // operando do IR -> MAR (para buscar dado)
                begin
                    Ei_n = 0;
                    Lm_n = 0;
                end

                OUT: // acumulador -> registrador de saida
                begin
                    Ea   = 1;   // A -> barramento
                    Lo_n = 0;   // OUT <- barramento
                end

                // HLT: todos os defaults (nada acontece)
                default: begin end

            endcase
        end

        T5:
        begin
            case(opcode)

                LDA: // dado da RAM -> acumulador
                begin
                    CE_n = 0;   // RAM[MAR] -> barramento
                    La_n = 0;   // A <- barramento
                end

                ADD: // dado da RAM -> registrador B
                begin
                    CE_n = 0;   // RAM[MAR] -> barramento
                    Lb_n = 0;   // B <- barramento
                end

                SUB: // dado da RAM -> registrador B
                begin
                    CE_n = 0;
                    Lb_n = 0;
                end

                // OUT, HLT: idle
                default: begin end

            endcase
        end

        T6:
        begin
            case(opcode)

                ADD: // ALU(A+B) -> acumulador
                begin
                    Su   = 0;   // operacao: adicao
                    Eu   = 1;   // ALU -> barramento
                    La_n = 0;   // A   <- barramento
                end

                SUB: // ALU(A-B) -> acumulador
                begin
                    Su   = 1;   // operacao: subtracao
                    Eu   = 1;   // ALU -> barramento
                    La_n = 0;   // A   <- barramento
                end

                // LDA, OUT, HLT: idle
                default: begin end

            endcase
        end

    endcase
end

endmodule