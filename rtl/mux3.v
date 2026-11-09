// ============================================================================
// Module: mux3
// Description: Parameterized 3-to-1 Multiplexer (defaults to 32 bits)
//
// Selection:
//   s = 2'b00 -> output d = a (ALUResult)
//   s = 2'b01 -> output d = b (ReadData from RAM)
//   s = 2'b10 -> output d = c (PC + 4 return address)
//   s = 2'b11 -> output d = a (default)
// ============================================================================

module mux3 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [WIDTH-1:0] c,
    input  wire [1:0]       s,
    output reg  [WIDTH-1:0] d
);

    always @(*) begin
        case (s)
            2'b00:   d = a;
            2'b01:   d = b;
            2'b10:   d = c;
            default: d = a;
        endcase
    end

endmodule
