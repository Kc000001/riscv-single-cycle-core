// ============================================================================
// Module: main_decoder
// Description: Main Control Unit Decoder for RV32I
//
// Translates the 7-bit Opcode into high-level control signals:
//
// Opcode Table:
//   0110011 (R-type) : add, sub, and, or, slt -> RegWrite=1, ALUSrc=0, MemWrite=0, ResultSrc=0, ALUOp=2'b10
//   0000011 (I-load) : lw                     -> RegWrite=1, ALUSrc=1, MemWrite=0, ResultSrc=1, ALUOp=2'b00, ImmSrc=2'b00
//   0100011 (S-store): sw                     -> RegWrite=0, ALUSrc=1, MemWrite=1, ResultSrc=X, ALUOp=2'b00, ImmSrc=2'b01
//   1100011 (B-branch): beq                   -> RegWrite=0, ALUSrc=0, MemWrite=0, ResultSrc=X, ALUOp=2'b01, ImmSrc=2'b10, Branch=1
//   0010011 (I-arith): addi                   -> RegWrite=1, ALUSrc=1, MemWrite=0, ResultSrc=0, ALUOp=2'b10, ImmSrc=2'b00
// ============================================================================

module main_decoder (
    input  wire [6:0] Op,
    output reg        RegWrite,
    output reg  [1:0] ImmSrc,
    output reg        ALUSrc,
    output reg        MemWrite,
    output reg        ResultSrc,
    output reg        Branch,
    output reg  [1:0] ALUOp
);

    always @(*) begin
        case (Op)
            // R-type (add, sub, and, or, slt)
            7'b0110011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00; // Not used
                ALUSrc    = 1'b0;  // Register RD2
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;  // ALU Result
                Branch    = 1'b0;
                ALUOp     = 2'b10; // Look at funct3 & funct7
            end

            // I-type Load (lw)
            7'b0000011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00; // 12-bit I-type immediate
                ALUSrc    = 1'b1;  // Sign-extended Immediate
                MemWrite  = 1'b0;
                ResultSrc = 1'b1;  // Data Memory Read Data
                Branch    = 1'b0;
                ALUOp     = 2'b00; // Addition (base + offset)
            end

            // S-type Store (sw)
            7'b0100011: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b01; // 12-bit S-type immediate
                ALUSrc    = 1'b1;  // Sign-extended Immediate
                MemWrite  = 1'b1;  // Write to Data RAM
                ResultSrc = 1'b0;  // Don't care
                Branch    = 1'b0;
                ALUOp     = 2'b00; // Addition (base + offset)
            end

            // B-type Branch (beq)
            7'b1100011: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b10; // 12-bit B-type immediate
                ALUSrc    = 1'b0;  // Register RD2
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;  // Don't care
                Branch    = 1'b1;  // Branch instruction active
                ALUOp     = 2'b01; // Subtraction (compare rs1 == rs2)
            end

            // I-type Arithmetic (addi)
            7'b0010011: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00; // 12-bit I-type immediate
                ALUSrc    = 1'b1;  // Sign-extended Immediate
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;  // ALU Result
                Branch    = 1'b0;
                ALUOp     = 2'b10; // Look at funct3
            end

            default: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
            end
        endcase
    end

endmodule

