// ============================================================================
// Module: sign_extend
// Description: Immediate Generator & Sign-Extender for RISC-V (RV32I)
//
// Why does this exist?
//   Immediates in instructions are 12 bits wide (signed).
//   The ALU requires 32-bit inputs.
//   This module extracts the immediate bits and replicates the sign bit (bit 31)
//   across the top 20 bits to preserve the negative/positive signed value.
//
// ImmSrc Encoding:
//   2'b00 : I-type (Loads, ADDI)   -> Imm = { {20{Instr[31]}}, Instr[31:20] }
//   2'b01 : S-type (Stores, SW)    -> Imm = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] }
//   2'b10 : B-type (Branches, BEQ) -> Imm = { {20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0 }
//   2'b11 : J-type (Jumps, JAL)    -> Imm = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0 }
// ============================================================================

module sign_extend (
    input  wire [31:0] Instr,
    input  wire [1:0]  ImmSrc,
    output reg  [31:0] Imm_Ext
);

    always @(*) begin
        case (ImmSrc)
            // I-type: bits [31:20]
            2'b00: Imm_Ext = {{20{Instr[31]}}, Instr[31:20]};

            // S-type: bits [31:25] and [11:7]
            2'b01: Imm_Ext = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};

            // B-type: bits [31], [7], [30:25], [11:8], with LSB=0 (halfword aligned)
            2'b10: Imm_Ext = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};

            // J-type: bits [31], [19:12], [20], [30:21], with LSB=0
            2'b11: Imm_Ext = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};

            default: Imm_Ext = 32'h00000000;
        endcase
    end

endmodule

