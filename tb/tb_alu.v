// ============================================================================
// Testbench: tb_alu
// Description: Comprehensive self-checking unit test for the 32-bit ALU
// ============================================================================

`timescale 1ns / 1ps

module tb_alu ();

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [2:0]  ALUControl;
    wire [31:0] Result;
    wire        Zero;
    wire        Negative;
    wire        Carry;
    wire        OverFlow;

    integer errors = 0;

    // Instantiate ALU module
    alu uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .Zero(Zero),
        .Negative(Negative),
        .Carry(Carry),
        .OverFlow(OverFlow)
    );

    task check_result;
        input [31:0] expected_res;
        input expected_zero;
        input [8*20:1] test_name;
        begin
            #1;
            if (Result !== expected_res || Zero !== expected_zero) begin
                $display("[FAIL] %0s: A=%h, B=%h, ALUControl=%b | Got: Res=%h Zero=%b, Expected: Res=%h Zero=%b", 
                         test_name, A, B, ALUControl, Result, Zero, expected_res, expected_zero);
                errors = errors + 1;
            end else begin
                $display("[PASS] %0s: Result = %h (Zero = %b)", test_name, Result, Zero);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_alu.vcd");
        $dumpvars(0, tb_alu);

        $display("==================================================");
        $display("            STARTING ALU UNIT TESTS               ");
        $display("==================================================");

        // Test 1: ADD (5 + 4 = 9)
        A = 32'd5; B = 32'd4; ALUControl = 3'b000;
        #10 check_result(32'd9, 1'b0, "ADD (5 + 4)");

        // Test 2: SUB (10 - 4 = 6)
        A = 32'd10; B = 32'd4; ALUControl = 3'b001;
        #10 check_result(32'd6, 1'b0, "SUB (10 - 4)");

        // Test 3: SUB producing Zero (8 - 8 = 0) -> Check Zero Flag
        A = 32'd8; B = 32'd8; ALUControl = 3'b001;
        #10 check_result(32'd0, 1'b1, "SUB (8 - 8) Zero Flag");

        // Test 4: AND (0x0F0F0F0F & 0x00FF00FF = 0x000F000F)
        A = 32'h0F0F0F0F; B = 32'h00FF00FF; ALUControl = 3'b010;
        #10 check_result(32'h000F000F, 1'b0, "AND Bitwise");

        // Test 5: OR (0xF0000000 | 0x0000000F = 0xF000000F)
        A = 32'hF0000000; B = 32'h0000000F; ALUControl = 3'b011;
        #10 check_result(32'hF000000F, 1'b0, "OR Bitwise");

        // Test 6: XOR (0xAAAA5555 ^ 0xFFFF0000 = 0x55555555)
        A = 32'hAAAA5555; B = 32'hFFFF0000; ALUControl = 3'b100;
        #10 check_result(32'h55555555, 1'b0, "XOR Bitwise");

        // Test 7: SLT (Signed: -5 < 2 -> should be 1)
        A = -32'd5; B = 32'd2; ALUControl = 3'b101;
        #10 check_result(32'd1, 1'b0, "SLT (-5 < 2)");

        // Test 8: SLT (Signed: 7 < 3 -> should be 0)
        A = 32'd7; B = 32'd3; ALUControl = 3'b101;
        #10 check_result(32'd0, 1'b1, "SLT (7 < 3)");

        // Test 9: Overflow test on Addition (0x7FFFFFFF + 1 = Negative / Overflow)
        A = 32'h7FFFFFFF; B = 32'd1; ALUControl = 3'b000;
        #10;
        if (OverFlow === 1'b1 && Negative === 1'b1) begin
            $display("[PASS] ADD Overflow: 0x7FFFFFFF + 1 -> OverFlow=%b, Negative=%b", OverFlow, Negative);
        end else begin
            $display("[FAIL] ADD Overflow: OverFlow=%b, Negative=%b (Expected 1, 1)", OverFlow, Negative);
            errors = errors + 1;
        end

        #20;
        $display("==================================================");
        if (errors == 0) begin
            $display("    ALL ALU TESTS PASSED SUCCESSFULLY! (0 Errors) ");
        end else begin
            $display("    ALU TESTS COMPLETED WITH %0d ERRORS           ", errors);
        end
        $display("==================================================");
        $finish;
    end

endmodule

