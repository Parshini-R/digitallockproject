`timescale 1ns / 1ps
// Nexys A7 top-level. SW[3:0] is the code; BTN U is submit; BTN C is reset.
module digital_lock_top(
    input  wire       CLK100MHZ,
    input  wire       BTNC,
    input  wire       BTNU,
    input  wire [3:0] SW,
    output wire [6:0] SEG,
    output wire       DP,
    output wire [7:0] AN,
    output wire [15:0] LED
);
    wire submit_pulse;
    wire unlocked, locked_out;
    wire [1:0] failures;
    wire [2:0] state;
    wire [3:0] display_value;

    button_debounce #(.COUNT_MAX(1_000_000)) debounce_submit (
        .clk(CLK100MHZ), .reset(BTNC), .button_in(BTNU), .button_out(submit_pulse)
    );

    digital_lock #(.PASSWORD(4'b1010)) lock_fsm (
        .clk(CLK100MHZ), .reset(BTNC), .submit(submit_pulse), .code(SW),
        .unlocked(unlocked), .locked_out(locked_out),
        .failed_attempts(failures), .status(state)
    );

    // Display the number of failed attempts (0, 1, 2, or 3).
    assign display_value = {2'b00, failures};
    seven_segment display_driver (
        .value(display_value), .seg(SEG), .dp(DP), .an(AN)
    );

    // LEDs: LED0 = unlocked, LED1 = lockout, LED[3:2] = attempts, LED[7:4] = code.
    assign LED = {8'b0, SW, failures, locked_out, unlocked};
endmodule
