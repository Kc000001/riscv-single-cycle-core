// ============================================================================
// Module: alu
// Description: 32-bit Arithmetic Logic Unit for RISC-V (RV32I)
// 
// Supported Operations (ALUControl):
//   3'b000 : ADD  (Result = A + B)
//   3'b001 : SUB  (Result = A - B)
//   3'b010 : AND  (Result = A & B)
//   3'b011 : OR   (Result = A | B)
//   3'b100 : XOR  (Result = A ^ B)
//   3'b101 : SLT  (Result = (A < B signed) ? 1 : 0)
//
// Status Flags:
//   Zero     : Asserted when Result == 0 (crucial for BEQ branches)
//   Negative : Asserted when Result is negative (Result[31] == 1)
//   Carry    : Unsigned carry-out (only active during ADD)
//   OverFlow : Signed arithmetic overflow (active during ADD/SUB)
// ============================================================================

module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  ALUControl,
    output reg  [31:0] Result,
    output wire        Zero,
    output wire        Negative,
    output wire        Carry,
    output wire        OverFlow
);

    wire        is_sub;
    wire [31:0] b_operand;
    wire [31:0] sum;
    wire        cout;

    // Subtraction is performed via 2's complement: A - B = A + (~B) + 1
    // ALUControl[0] is 1 for subtraction (3'b001)
    assign is_sub    = ALUControl[0];
    assign b_operand = is_sub ? (~B) : B;
    assign {cout, sum} = A + b_operand + (is_sub ? 32'd1 : 32'd0);

    // Overflow detection for signed addition and subtraction:
    // Overflow occurs when:
    //   - Adding two positives yields a negative
    //   - Adding two negatives yields a positive
    assign OverFlow = ((A[31] == b_operand[31]) && (sum[31] != A[31]) && (ALUControl[1:0] == 2'b00 || ALUControl[1:0] == 2'b01));

    // Carry flag: Only meaningful for unsigned addition
    assign Carry = (~is_sub) & cout;

    // Result Multiplexer
    always @(*) begin
        case (ALUControl)
            3'b000: Result = sum;                                      // ADD
            3'b001: Result = sum;                                      // SUB
            3'b010: Result = A & B;                                    // AND
            3'b011: Result = A | B;                                    // OR
            3'b100: Result = A ^ B;                                    // XOR
            3'b101: Result = {31'b0, (sum[31] ^ OverFlow)};            // SLT (Signed Set Less Than)
            default: Result = 32'b0;
        endcase
    end

    // Status Flags
    assign Zero     = (Result == 32'b0);
    assign Negative = Result[31];

endmodule

