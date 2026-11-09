// ============================================================================
// Testbench: tb_sign_extend
// Description: Self-checking testbench for I-type, S-type, and B-type sign extension
// ============================================================================

`timescale 1ns / 1ps

module tb_sign_extend ();

    reg  [31:0] Instr;
    reg  [1:0]  ImmSrc;
    wire [31:0] Imm_Ext;
    integer errors = 0;

    sign_extend uut (
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .Imm_Ext(Imm_Ext)
    );

    initial begin
        $display("==================================================");
        $display("        STARTING SIGN EXTENSION TESTS             ");
        $display("==================================================");

        // Test 1: I-type positive immediate (+5)
        // lw x5, 5(x10) -> Instr[31:20] = 12'd5 = 0x005
        Instr = 32'h00552283; ImmSrc = 2'b00; #10;
        if (Imm_Ext === 32'd5)
            $display("[PASS] I-type positive immediate: +5 -> %d", $signed(Imm_Ext));
        else begin
            $display("[FAIL] I-type positive: got %h, expected 5", Imm_Ext);
            errors = errors + 1;
        end

        // Test 2: I-type negative immediate (-4)
        // 12-bit -4 is 0xFFC. In bits [31:20] -> 0xFFC...
        Instr = 32'hFFC52283; ImmSrc = 2'b00; #10;
        if (Imm_Ext === -32'd4)
            $display("[PASS] I-type negative immediate: -4 -> %d", $signed(Imm_Ext));
        else begin
            $display("[FAIL] I-type negative: got %d, expected -4", $signed(Imm_Ext));
            errors = errors + 1;
        end

        // Test 3: S-type store immediate (+8)
        // sw x5, 8(x10) -> offset 8: bits[31:25]=0, bits[11:7]=8 -> Instr[11:7] = 5'b01000
        Instr = 32'h00552423; ImmSrc = 2'b01; #10;
        if (Imm_Ext === 32'd8)
            $display("[PASS] S-type immediate: +8 -> %d", $signed(Imm_Ext));
        else begin
            $display("[FAIL] S-type immediate: got %d, expected 8", $signed(Imm_Ext));
            errors = errors + 1;
        end

        // Test 4: B-type branch immediate (-8)
        // beq x5, x6, -8
        // -8 is 13'b1_1111_1111_1000 -> imm[12]=1, imm[11]=1, imm[10:5]=6'b111111, imm[4:1]=4'b1100, imm[0]=0
        Instr = 32'hFE628CE3; ImmSrc = 2'b10; #10;
        if (Imm_Ext === -32'd8)
            $display("[PASS] B-type branch immediate: -8 -> %d", $signed(Imm_Ext));
        else begin
            $display("[FAIL] B-type branch immediate: got %d, expected -8", $signed(Imm_Ext));
            errors = errors + 1;
        end

        $display("==================================================");
        if (errors == 0)
            $display("  ALL SIGN EXTENSION TESTS PASSED! (0 Errors)     ");
        else
            $display("  SIGN EXTENSION TESTS HAD %0d ERRORS            ", errors);
        $display("==================================================");
        $finish;
    end

endmodule

