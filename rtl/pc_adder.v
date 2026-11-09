// ============================================================================
// Module: pc_adder
// Description: Dedicated 32-bit adder to compute next sequential PC (PC + 4)
//
// Why +4?
//   In RISC-V (RV32), every instruction is 32 bits = 4 bytes wide.
//   Memory is byte-addressed, so consecutive instructions are spaced by 4 bytes.
// ============================================================================

module pc_adder (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] c
);

    assign c = a + b;

endmodule

