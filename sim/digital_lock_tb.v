`timescale 1ns / 1ps
module digital_lock_tb;
    reg clk = 0;
    reg reset = 0;
    reg submit = 0;
    reg [3:0] code = 0;
    wire unlocked, locked_out;
    wire [1:0] failed_attempts;
    wire [2:0] status;

    always #5 clk = ~clk; // 100 MHz test clock

    digital_lock #(.PASSWORD(4'b1010)) dut (
        .clk(clk), .reset(reset), .submit(submit), .code(code),
        .unlocked(unlocked), .locked_out(locked_out),
        .failed_attempts(failed_attempts), .status(status)
    );

    task press_submit;
        begin
            @(negedge clk); submit = 1;
            @(negedge clk); submit = 0;
            repeat (3) @(negedge clk);
        end
    endtask

    initial begin
        $display("Starting Digital Lock FSM test...");
        reset = 1; repeat (2) @(negedge clk); reset = 0;

        // First incorrect attempt.
        code = 4'b0001; press_submit();
        if (failed_attempts !== 1) $fatal(1, "Attempt count should be 1");

        // Second incorrect attempt.
        code = 4'b0011; press_submit();
        if (failed_attempts !== 2) $fatal(1, "Attempt count should be 2");

        // Third incorrect attempt should lock out.
        code = 4'b0100; press_submit();
        if (!locked_out) $fatal(1, "Lockout should be active after 3 failures");
        if (unlocked) $fatal(1, "Lock should not be unlocked in lockout");

        // Reset recovers lock.
        reset = 1; repeat (2) @(negedge clk); reset = 0;
        if (locked_out || failed_attempts != 0) $fatal(1, "Reset did not clear lockout");

        // Correct password unlocks.
        code = 4'b1010; press_submit();
        if (!unlocked) $fatal(1, "Correct code should unlock");

        $display("PASS: Digital Lock FSM test completed successfully.");
        $finish;
    end
endmodule
