// ============================================================================
// Module: instruction_memory
// Description: 1024-word (4 KB) Instruction ROM for RV32I
//
// Ports:
//   - A  : 32-bit Instruction Address from Program Counter (PC)
//   - RD : 32-bit Machine Instruction output to Decoder
//
// Initialization:
//   Loads binary machine code instructions from "sim/memfile.hex" using $readmemh.
// ============================================================================

module instruction_memory (
    input  wire        rst,
    input  wire [31:0] A,
    output wire [31:0] RD
);

    reg [31:0] mem [0:1023];

    integer i;

    // Read word-aligned instruction (divide byte address by 4 -> A[31:2])
    assign RD = (!rst) ? 32'h00000000 : mem[A[31:2]];

    initial begin
        // Fallback: clear memory first
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000013; // RISC-V NOP (addi x0, x0, 0)
        
        // Load program hex file
        $readmemh("sim/memfile.hex", mem);
    end

endmodule

