// ============================================================================
// Module: alu_decoder
// Description: ALU Control Decoder for RV32I
//
// Translates ALUOp, funct3, and funct7[5] into the 3-bit ALUControl signal:
//
// ALUControl Encoding:
//   3'b000 : ADD
//   3'b001 : SUB
//   3'b010 : AND
//   3'b011 : OR
//   3'b100 : XOR
//   3'b101 : SLT
// ============================================================================

module alu_decoder (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_5, // bit 30 of instruction (funct7[5])
    input  wire       op_5,     // bit 5 of instruction (op[5])
    output reg  [2:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            // 2'b00: Loads (lw) and Stores (sw) -> Always compute address with ADD
            2'b00: ALUControl = 3'b000;

            // 2'b01: Branch (beq) -> Compare registers by SUB (checks Zero flag)
            2'b01: ALUControl = 3'b001;

            // 2'b10: R-type or I-type arithmetic -> Examine funct3 and funct7
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        // Distinguish ADD vs SUB:
                        // SUB only happens for R-type (op_5 = 1) when funct7_5 = 1 (bit 30 = 1)
                        if (op_5 && funct7_5)
                            ALUControl = 3'b001; // SUB
                        else
                            ALUControl = 3'b000; // ADD / ADDI
                    end

                    3'b010: ALUControl = 3'b101; // SLT (Set Less Than)
                    3'b100: ALUControl = 3'b100; // XOR
                    3'b110: ALUControl = 3'b011; // OR
                    3'b111: ALUControl = 3'b010; // AND
                    default: ALUControl = 3'b000;
                endcase
            end

            default: ALUControl = 3'b000;
        endcase
    end

endmodule

