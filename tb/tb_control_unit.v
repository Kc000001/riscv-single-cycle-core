// ============================================================================
// Testbench: tb_control_unit
// Description: Comprehensive unit test for the Control Unit
// ============================================================================

`timescale 1ns / 1ps

module tb_control_unit ();

    reg  [6:0] Op;
    reg  [2:0] funct3;
    reg        funct7_5;

    wire       RegWrite;
    wire [1:0] ImmSrc;
    wire       ALUSrc;
    wire       MemWrite;
    wire       ResultSrc;
    wire       Branch;
    wire [2:0] ALUControl;

    integer errors = 0;

    control_unit uut (
        .Op(Op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUControl(ALUControl)
    );

    initial begin
        $display("==================================================");
        $display("        STARTING CONTROL UNIT TESTS               ");
        $display("==================================================");

        // Test 1: ADD (R-type: Op=0110011, funct3=000, funct7_5=0)
        Op = 7'b0110011; funct3 = 3'b000; funct7_5 = 1'b0; #10;
        if (RegWrite==1 && ALUSrc==0 && MemWrite==0 && ResultSrc==0 && ALUControl==3'b000)
            $display("[PASS] ADD Instruction Control Signals");
        else begin
            $display("[FAIL] ADD Control Signals: RegWrite=%b ALUSrc=%b ALUControl=%b", RegWrite, ALUSrc, ALUControl);
            errors = errors + 1;
        end

        // Test 2: SUB (R-type: Op=0110011, funct3=000, funct7_5=1)
        Op = 7'b0110011; funct3 = 3'b000; funct7_5 = 1'b1; #10;
        if (RegWrite==1 && ALUSrc==0 && MemWrite==0 && ResultSrc==0 && ALUControl==3'b001)
            $display("[PASS] SUB Instruction Control Signals");
        else begin
            $display("[FAIL] SUB Control Signals: ALUControl=%b (Expected 001)", ALUControl);
            errors = errors + 1;
        end

        // Test 3: LW (Load: Op=0000011, funct3=010)
        Op = 7'b0000011; funct3 = 3'b010; funct7_5 = 1'b0; #10;
        if (RegWrite==1 && ALUSrc==1 && MemWrite==0 && ResultSrc==1 && ALUControl==3'b000 && ImmSrc==2'b00)
            $display("[PASS] LW Instruction Control Signals (ALUSrc=1, ResultSrc=1, ADD)");
        else begin
            $display("[FAIL] LW Control Signals");
            errors = errors + 1;
        end

        // Test 4: SW (Store: Op=0100011, funct3=010)
        Op = 7'b0100011; funct3 = 3'b010; funct7_5 = 1'b0; #10;
        if (RegWrite==0 && ALUSrc==1 && MemWrite==1 && ALUControl==3'b000 && ImmSrc==2'b01)
            $display("[PASS] SW Instruction Control Signals (MemWrite=1, RegWrite=0, ADD)");
        else begin
            $display("[FAIL] SW Control Signals");
            errors = errors + 1;
        end

        // Test 5: BEQ (Branch: Op=1100011, funct3=000)
        Op = 7'b1100011; funct3 = 3'b000; funct7_5 = 1'b0; #10;
        if (RegWrite==0 && ALUSrc==0 && MemWrite==0 && Branch==1 && ALUControl==3'b001 && ImmSrc==2'b10)
            $display("[PASS] BEQ Instruction Control Signals (Branch=1, SUB for comparison)");
        else begin
            $display("[FAIL] BEQ Control Signals");
            errors = errors + 1;
        end

        $display("==================================================");
        if (errors == 0)
            $display("  ALL CONTROL UNIT TESTS PASSED! (0 Errors)       ");
        else
            $display("  CONTROL UNIT TESTS HAD %0d ERRORS              ", errors);
        $display("==================================================");
        $finish;
    end

endmodule

