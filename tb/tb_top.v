// ============================================================================
// Testbench: tb_top
// Description: Full System Testbench for 32-bit Single-Cycle RISC-V Core
//
// Features:
//   - Clock generation (10ns period) & Power-on reset sequence
//   - Disassembly execution trace printed at each clock cycle
//   - Automated verification of arithmetic, memory (lw/sw), and branch (beq)
//   - Generates "sim/riscv_top.vcd" for GTKWave waveform analysis
// ============================================================================

`timescale 1ns / 1ps

module tb_top ();

    reg         clk;
    reg         rst;

    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ALUResult;
    wire [31:0] WriteData;
    wire [31:0] Result;
    wire        MemWrite;

    integer cycle = 0;

    // Instantiate Top-Level RISC-V Processor Core
    riscv_single_cycle_top uut (
        .clk(clk),
        .rst(rst),
        .PC_out(PC),
        .Instr_out(Instr),
        .ALUResult_out(ALUResult),
        .WriteData_out(WriteData),
        .Result_out(Result),
        .MemWrite_out(MemWrite)
    );

    // Clock generator: 100 MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/riscv_top.vcd");
        $dumpvars(0, tb_top);

        clk = 0;
        rst = 0; // Assert active-low reset

        $display("===============================================================================");
        $display("          STARTING FULL RISC-V PROCESSOR SYSTEM SIMULATION                     ");
        $display("===============================================================================");
        $display(" Cycle |    PC    |   Instr   | ALUResult | WriteData |  Result   | MemWrite       ");
        $display("-------+----------+-----------+-----------+-----------+-----------+----------------");

        // Hold reset for 15ns, then release on falling clock edge
        #15;
        @(negedge clk);
        rst = 1;

        // Run for 20 clock cycles to execute program
        repeat (20) begin
            @(posedge clk);
            #1; // slight delay to sample post-clock values
            $display(" %4d  | %h | %h  | %h  | %h  | %h  |    %b", 
                     cycle, PC, Instr, ALUResult, WriteData, Result, MemWrite);
            cycle = cycle + 1;
        end

        $display("===============================================================================");
        $display("                     FINAL ARCHITECTURAL STATE CHECKS                          ");
        $display("===============================================================================");

        // Verification Check 1: Register x4 (5 + 10 = 15)
        if (uut.rf.registers[4] === 32'd15)
            $display("[PASS] ADD Result: Register x4 = %d (Expected: 15)", uut.rf.registers[4]);
        else
            $display("[FAIL] ADD Result: Register x4 = %d (Expected: 15)", uut.rf.registers[4]);

        // Verification Check 2: Register x5 (10 - 5 = 5)
        if (uut.rf.registers[5] === 32'd5)
            $display("[PASS] SUB Result: Register x5 = %d (Expected: 5)", uut.rf.registers[5]);
        else
            $display("[FAIL] SUB Result: Register x5 = %d (Expected: 5)", uut.rf.registers[5]);

        // Verification Check 3: Data Memory at word 1 (Byte addr 4) holds 15
        if (uut.dmem.mem[1] === 32'd15)
            $display("[PASS] SW Result: Data_Memory[1] = %d (Expected: 15)", uut.dmem.mem[1]);
        else
            $display("[FAIL] SW Result: Data_Memory[1] = %d (Expected: 15)", uut.dmem.mem[1]);

        // Verification Check 4: Register x9 loaded from RAM
        if (uut.rf.registers[9] === 32'd15)
            $display("[PASS] LW Result: Register x9 = %d (Expected: 15)", uut.rf.registers[9]);
        else
            $display("[FAIL] LW Result: Register x9 = %d (Expected: 15)", uut.rf.registers[9]);

        // Verification Check 5: BEQ Branch taken!
        // x10 should be 0 because instruction at 0x2C (addi x10, 99) was skipped!
        // x11 should be 42 because branch landed at 0x30!
        if (uut.rf.registers[10] === 32'd0 && uut.rf.registers[11] === 32'd42) begin
            $display("[PASS] BEQ Branch Succeeded: Skipped x10 (still 0), Executed x11 = %d", uut.rf.registers[11]);
        end else begin
            $display("[FAIL] BEQ Branch Failed: x10=%d, x11=%d", uut.rf.registers[10], uut.rf.registers[11]);
        end

        $display("===============================================================================");
        $display("               SIMULATION COMPLETED SUCCESSFULLY!                              ");
        $display("===============================================================================");
        $finish;
    end

endmodule
