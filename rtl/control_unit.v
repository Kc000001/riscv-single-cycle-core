// ============================================================================
// Module: control_unit
// Description: Top-Level Control Unit for RV32I Processor
//
// Combines:
//   1. main_decoder : decodes 7-bit Opcode into datapath control signals
//   2. alu_decoder  : decodes ALUOp + funct3 + funct7[5] into 3-bit ALUControl
// ============================================================================

module control_unit (
    input  wire [6:0] Op,
    input  wire [2:0] funct3,
    input  wire       funct7_5, // Instruction bit 30
    output wire       RegWrite,
    output wire [1:0] ImmSrc,
    output wire       ALUSrc,
    output wire       MemWrite,
    output wire       ResultSrc,
    output wire       Branch,
    output wire [2:0] ALUControl
);

    wire [1:0] ALUOp;

    // Instantiate Main Decoder
    main_decoder md (
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    // Instantiate ALU Decoder
    alu_decoder ad (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .op_5(Op[5]),
        .ALUControl(ALUControl)
    );

endmodule

