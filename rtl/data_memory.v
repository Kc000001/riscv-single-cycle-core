// ============================================================================
// Module: data_memory
// Description: 1024-word (4 KB) Data RAM for RV32I
//
// Ports:
//   - A   : 32-bit Memory Byte Address
//   - WD  : 32-bit Write Data (from Register RD2)
//   - WE  : Write Enable (asserted for SW instructions)
//   - RD  : 32-bit Read Data output (for LW instructions)
//
// Note on Addressing:
//   Memory is byte-addressed in RISC-V, but our internal RAM array is organized
//   in 32-bit (4-byte) words. Thus, word index = A[31:2] (dividing by 4).
// ============================================================================

module data_memory (
    input  wire        clk,
    input  wire        rst,
    input  wire        WE,
    input  wire [31:0] A,
    input  wire [31:0] WD,
    output wire [31:0] RD
);

    reg [31:0] mem [0:1023];

    // Synchronous write on clock edge
    always @(posedge clk) begin
        if (WE)
            mem[A[31:2]] <= WD;
    end

    // Asynchronous (combinational) read
    assign RD = (!rst) ? 32'h00000000 : mem[A[31:2]];

endmodule

