// ============================================================================
// Module: mux2
// Description: Parameterized 2-to-1 Multiplexer (defaults to 32 bits)
//
// Selection:
//   s = 0 -> output c = a
//   s = 1 -> output c = b
// ============================================================================

module mux2 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             s,
    output wire [WIDTH-1:0] c
);

    assign c = (s) ? b : a;

endmodule

