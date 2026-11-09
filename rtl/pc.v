// ============================================================================
// Module: pc
// Description: Program Counter Register for RISC-V Processor
//
// Features:
//   - 32-bit register holding the memory address of the current instruction
//   - Synchronous active-low reset (~rst) to address 0x00000000
//   - Updates to PC_Next on every rising clock edge
// ============================================================================

module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] PC_Next,
    output reg  [31:0] PC
);

    always @(posedge clk) begin
        if (!rst)
            PC <= 32'h00000000;
        else
            PC <= PC_Next;
    end

endmodule

