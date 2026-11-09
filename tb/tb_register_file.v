// ============================================================================
// Testbench: tb_register_file
// Description: Self-checking unit test for the 32x32 Register File
// ============================================================================

`timescale 1ns / 1ps

module tb_register_file ();

    reg         clk;
    reg         rst;
    reg         WE3;
    reg  [4:0]  A1, A2, A3;
    reg  [31:0] WD3;
    wire [31:0] RD1, RD2;

    integer errors = 0;

    // Instantiate Register File
    register_file uut (
        .clk(clk),
        .rst(rst),
        .WE3(WE3),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2)
    );

    // Clock generator: 10ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        WE3 = 0;
        A1  = 0;
        A2  = 0;
        A3  = 0;
        WD3 = 0;

        $display("==================================================");
        $display("       STARTING REGISTER FILE UNIT TESTS          ");
        $display("==================================================");

        // Apply reset
        #15 rst = 1;
        #10;

        // Test 1: Write to Register x5 (value = 0xAAAA5555)
        @(posedge clk);
        A3  = 5'd5;
        WD3 = 32'hAAAA5555;
        WE3 = 1;
        @(posedge clk);
        WE3 = 0; // Disable write

        // Read back on port 1
        A1 = 5'd5;
        #2;
        if (RD1 === 32'hAAAA5555)
            $display("[PASS] Write & Read x5: Got %h", RD1);
        else begin
            $display("[FAIL] Write & Read x5: Got %h, Expected AAAA5555", RD1);
            errors = errors + 1;
        end

        // Test 2: Write to Register x10 (value = 0x12345678)
        @(posedge clk);
        A3  = 5'd10;
        WD3 = 32'h12345678;
        WE3 = 1;
        @(posedge clk);
        WE3 = 0;

        // Read both x5 and x10 simultaneously
        A1 = 5'd5;
        A2 = 5'd10;
        #2;
        if (RD1 === 32'hAAAA5555 && RD2 === 32'h12345678)
            $display("[PASS] Simultaneous Dual Read (x5 on RD1, x10 on RD2)");
        else begin
            $display("[FAIL] Dual Read: RD1=%h, RD2=%h", RD1, RD2);
            errors = errors + 1;
        end

        // Test 3: Write to x0 (Must remain zero!)
        @(posedge clk);
        A3  = 5'd0;
        WD3 = 32'hFFFFFFFF;
        WE3 = 1;
        @(posedge clk);
        WE3 = 0;

        A1 = 5'd0;
        #2;
        if (RD1 === 32'h00000000)
            $display("[PASS] Register x0 Hardwired Zero: write was successfully ignored!");
        else begin
            $display("[FAIL] Register x0 was overwritten! Got %h", RD1);
            errors = errors + 1;
        end

        #20;
        $display("==================================================");
        if (errors == 0)
            $display("  ALL REGISTER FILE TESTS PASSED! (0 Errors)      ");
        else
            $display("  REGISTER FILE TESTS HAD %0d ERRORS             ", errors);
        $display("==================================================");
        $finish;
    end

endmodule

