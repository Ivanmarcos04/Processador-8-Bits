// ============================================================
// Testbench - Processador 8 bits
// UFAM - Lista 4
//
// Programa carregado na RAM:
//   Addr 0: LDA 14  (0000_1110) -> A = mem[14] = 5
//   Addr 1: ADD 15  (0001_1111) -> A = A + mem[15] = 5 + 3 = 8
//   Addr 2: OUT     (1110_0000) -> leds = A = 8
//   Addr 3: HLT     (1111_0000) -> para
//   Addr 14: 5  (dado)
//   Addr 15: 3  (dado)
//
// Resultado esperado: leds = 8'b00001000 (decimal 8)
// ============================================================
`timescale 1ns/1ps

module tb_processador;

// -------------------------------------------------------
// Sinais
// -------------------------------------------------------
reg clk;
reg reset;

wire [7:0] leds;

// -------------------------------------------------------
// DUT - Device Under Test
// -------------------------------------------------------
processador_8bits DUT (
    .clk(clk),
    .reset(reset),
    .leds(leds)
);

// -------------------------------------------------------
// Clock: periodo de 10 ns (100 MHz)
// -------------------------------------------------------
initial clk = 0;
always #5 clk = ~clk;

// -------------------------------------------------------
// Tarefa de monitoramento do estado interno (acesso
// hierarquico aos sinais internos do DUT para debug)
// -------------------------------------------------------
integer ciclo;

initial
begin
    ciclo = 0;

    // ---- Reset ----
    reset = 1;
    #20;
    reset = 0;

    $display("============================================================");
    $display(" SIMULACAO - Processador 8 bits - UFAM Lista 4");
    $display("============================================================");
    $display(" Programa:");
    $display("   [0] LDA 14  -> A = mem[14] = 5");
    $display("   [1] ADD 15  -> A = A + mem[15] = 5 + 3 = 8");
    $display("   [2] OUT     -> leds = A");
    $display("   [3] HLT     -> para");
    $display(" Resultado esperado: leds = 8 (0x08)");
    $display("============================================================");
    $display("Tempo | Ciclo | Estado | PC | MAR | IR      | A  | B  | ALU| OUT | LEDs");
    $display("------|-------|--------|----|-----|---------|----|----|----|----|------");

    // Monitoramento por 60 ciclos de clock (10 instrucoes x 6 estados)
    repeat(60)
    begin
        @(posedge clk);
        #1; // pequeno atraso para estabilizar sinais
        ciclo = ciclo + 1;

        $display("%5t | %5d | T%0d      | %2d | %3d | %b | %3d | %3d | %3d | %3d | %b",
            $time,
            ciclo,
            DUT.CTRL.state,
            DUT.PC.pc_out,
            DUT.MAR.mar_out,
            DUT.IR.instruction,
            DUT.A.A,
            DUT.B.B,
            DUT.ALU.result,
            DUT.OUT_REG.out_data,
            leds
        );
    end

    // ---- Verificacao do resultado ----
    $display("============================================================");
    $display(" RESULTADO FINAL:");
    $display("   leds     = %0d (binario: %b)", leds, leds);
    $display("   out_data = %0d", DUT.OUT_REG.out_data);
    $display("   A        = %0d", DUT.A.A);

    if(leds === 8'd8)
    begin
        $display("   [PASS] leds = 8 - CORRETO! (5 + 3 = 8)");
    end
    else
    begin
        $display("   [FAIL] leds = %0d - INCORRETO! Esperado: 8", leds);
    end

    if(DUT.OUT_REG.out_data === 8'd8)
        $display("   [PASS] out_data = 8 - CORRETO!");
    else
        $display("   [FAIL] out_data = %0d - INCORRETO!", DUT.OUT_REG.out_data);

    $display("============================================================");
    $finish;
end

// -------------------------------------------------------
// Monitor automatico de mudanca nos LEDs
// -------------------------------------------------------
always @(leds)
begin
    if(!reset)
        $display("[EVENT] leds mudou para: %0d (binario: %b) no tempo %0t", leds, leds, $time);
end

endmodule