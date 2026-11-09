// ============================================================================
// Module: riscv_single_cycle_top
// Description: Top-Level 32-bit Single-Cycle RISC-V Processor Core (RV32I)
//
// Integrated Submodules:
//   - pc                  : Program Counter register
//   - pc_adder (x2)       : PC+4 sequential adder & PC+Imm branch target adder
//   - instruction_memory  : Instruction ROM preloaded via memfile.hex
//   - register_file       : 32 x 32-bit general-purpose registers (x0 to x31)
//   - sign_extend         : Immediate generator for I, S, and B type formats
//   - alu                 : 32-bit Arithmetic Logic Unit
//   - control_unit        : Combined Main Decoder and ALU Decoder
//   - data_memory         : 1024-word Data RAM
//   - mux2 (x3)           : PC select, ALU input B select, Write-Back select
// ============================================================================

module riscv_single_cycle_top (
    input  wire        clk,
    input  wire        rst,

    // Debug / Verification probe ports (useful for testbenches and wave inspection)
    output wire [31:0] PC_out,
    output wire [31:0] Instr_out,
    output wire [31:0] ALUResult_out,
    output wire [31:0] WriteData_out,
    output wire [31:0] Result_out,
    output wire        MemWrite_out
);

    // ------------------------------------------------------------------------
    // Internal Datapath and Control Wires
    // ------------------------------------------------------------------------
    wire [31:0] PC, PC_Next, PCPlus4, PCTarget;
    wire [31:0] Instr;
    wire [31:0] SrcA, RD2, SrcB;
    wire [31:0] Imm_Ext;
    wire [31:0] ALUResult, ReadData, Result;

    wire        RegWrite, MemWrite, ALUSrc, ResultSrc, Branch;
    wire [1:0]  ImmSrc;
    wire [2:0]  ALUControl;
    wire        Zero, Negative, Carry, OverFlow;
    wire        PCSrc;

    // ------------------------------------------------------------------------
    // Instruction Fetch (IF) Stage
    // ------------------------------------------------------------------------
    
    // Branch decision: Branch taken when instruction is Branch AND ALU Result is Zero (rs1 == rs2)
    assign PCSrc = Branch & Zero;

    // Mux selecting next PC: either sequential (PC+4) or branch target (PC + Imm)
    mux2 #(32) mux_pc (
        .a(PCPlus4),
        .b(PCTarget),
        .s(PCSrc),
        .c(PC_Next)
    );

    // Program Counter Register
    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .PC_Next(PC_Next),
        .PC(PC)
    );

    // PC + 4 Adder (sequential instruction address)
    pc_adder pc_add4 (
        .a(PC),
        .b(32'd4),
        .c(PCPlus4)
    );

    // PC + Immediate Adder (branch target address calculation)
    pc_adder pc_branch_add (
        .a(PC),
        .b(Imm_Ext),
        .c(PCTarget)
    );

    // Instruction Memory (ROM)
    instruction_memory imem (
        .rst(rst),
        .A(PC),
        .RD(Instr)
    );

    // ------------------------------------------------------------------------
    // Instruction Decode & Register Fetch (ID) Stage
    // ------------------------------------------------------------------------

    // Control Unit (Main Decoder + ALU Decoder)
    // Note: Instr[30] is funct7[5], Instr[14:12] is funct3, Instr[6:0] is Opcode
    control_unit cu (
        .Op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7_5(Instr[30]),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUControl(ALUControl)
    );

    // Register File (32 x 32-bit registers, x0 hardwired to 0)
    register_file rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite),
        .A1(Instr[19:15]), // rs1
        .A2(Instr[24:20]), // rs2
        .A3(Instr[11:7]),  // rd
        .WD3(Result),      // write-back data
        .RD1(SrcA),        // output 1
        .RD2(RD2)          // output 2
    );

    // Sign Extension Unit (generates 32-bit immediate from 12-bit instruction fields)
    sign_extend ext (
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .Imm_Ext(Imm_Ext)
    );

    // ------------------------------------------------------------------------
    // Execute (EX) Stage
    // ------------------------------------------------------------------------

    // ALU Input B Multiplexer (selects between Register RD2 or Immediate)
    mux2 #(32) mux_alusrc (
        .a(RD2),
        .b(Imm_Ext),
        .s(ALUSrc),
        .c(SrcB)
    );

    // 32-bit Arithmetic Logic Unit
    alu alu_inst (
        .A(SrcA),
        .B(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .Zero(Zero),
        .Negative(Negative),
        .Carry(Carry),
        .OverFlow(OverFlow)
    );

    // ------------------------------------------------------------------------
    // Memory Access (MEM) Stage
    // ------------------------------------------------------------------------

    // Data RAM (1024 words)
    data_memory dmem (
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .A(ALUResult),
        .WD(RD2),
        .RD(ReadData)
    );

    // ------------------------------------------------------------------------
    // Write-Back (WB) Stage
    // ------------------------------------------------------------------------

    // Write-Back Multiplexer (selects between ALU Result and Data Memory ReadData)
    mux2 #(32) mux_result (
        .a(ALUResult),
        .b(ReadData),
        .s(ResultSrc),
        .c(Result)
    );

    // ------------------------------------------------------------------------
    // Debug probe assignments
    // ------------------------------------------------------------------------
    assign PC_out        = PC;
    assign Instr_out     = Instr;
    assign ALUResult_out = ALUResult;
    assign WriteData_out = RD2;
    assign Result_out    = Result;
    assign MemWrite_out  = MemWrite;

endmodule
