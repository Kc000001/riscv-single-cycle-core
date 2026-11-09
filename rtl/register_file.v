// ============================================================================
// Module: register_file
// Description: 32 x 32-bit General-Purpose Register File (x0 to x31) for RV32I
//
// Ports:
//   - A1, A2 : 5-bit Read Addresses (can address 2^5 = 32 registers)
//   - RD1, RD2 : 32-bit Read Data outputs (Asynchronous / Combinational)
//   - A3     : 5-bit Write Address
//   - WD3    : 32-bit Write Data input (Synchronous on posedge clk when WE3 = 1)
//   - WE3    : Write Enable flag
//
// RISC-V Architectural Invariant:
//   Register x0 is HARDWIRED to constant ZERO.
//   - Any read from x0 always returns 0.
//   - Any write to x0 is ignored (discarded).
// ============================================================================

module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        WE3,
    input  wire [4:0]  A1,
    input  wire [4:0]  A2,
    input  wire [4:0]  A3,
    input  wire [31:0] WD3,
    output wire [31:0] RD1,
    output wire [31:0] RD2
);

    reg [31:0] registers [31:0];
    integer i;

    // Synchronous write port (clocked)
    always @(posedge clk) begin
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'h00000000;
        end else if (WE3 && (A3 != 5'b00000)) begin
            registers[A3] <= WD3;
        end
    end

    // Combinational dual read ports
    // Hardware-enforced zero: x0 is always 0
    assign RD1 = (!rst || A1 == 5'b00000) ? 32'h00000000 : registers[A1];
    assign RD2 = (!rst || A2 == 5'b00000) ? 32'h00000000 : registers[A2];

endmodule

