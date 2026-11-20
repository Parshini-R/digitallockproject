`timescale 1ns / 1ps

// FSM digital lock: one 4-bit code is entered using SW[3:0] and BTN enter.
// Three consecutive incorrect submissions cause LOCKOUT until reset.
module digital_lock #(
    parameter [3:0] PASSWORD = 4'b1010
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       submit,
    input  wire [3:0] code,
    output reg        unlocked,
    output reg        locked_out,
    output reg  [1:0] failed_attempts,
    output reg  [2:0] status
);
    localparam [2:0] S_LOCKED   = 3'b000;
    localparam [2:0] S_CHECK    = 3'b001;
    localparam [2:0] S_UNLOCKED = 3'b010;
    localparam [2:0] S_FAIL     = 3'b011;
    localparam [2:0] S_LOCKOUT  = 3'b100;

    reg [2:0] state, next_state;
    reg submit_d;
    wire submit_rise = submit & ~submit_d;

    // Edge detect submit. Debouncing is provided in the top-level module.
    always @(posedge clk) begin
        if (reset) submit_d <= 1'b0;
        else       submit_d <= submit;
    end

    // State register and attempt counter.
    always @(posedge clk) begin
        if (reset) begin
            state <= S_LOCKED;
            failed_attempts <= 2'd0;
        end else begin
            state <= next_state;
            if (state == S_CHECK && code != PASSWORD) begin
                if (failed_attempts < 2'd3)
                    failed_attempts <= failed_attempts + 1'b1;
            end else if (state == S_CHECK && code == PASSWORD) begin
                failed_attempts <= 2'd0;
            end
        end
    end

    // Next-state logic. A submit edge moves from LOCKED to CHECK.
    always @(*) begin
        next_state = state;
        case (state)
            S_LOCKED: begin
                if (submit_rise) next_state = S_CHECK;
            end
            S_CHECK: begin
                if (code == PASSWORD) next_state = S_UNLOCKED;
                else if (failed_attempts >= 2'd2) next_state = S_LOCKOUT;
                else next_state = S_FAIL;
            end
            S_FAIL: next_state = S_LOCKED;
            S_UNLOCKED: next_state = S_UNLOCKED; // stays open until reset
            S_LOCKOUT: next_state = S_LOCKOUT;   // stays locked until reset
            default: next_state = S_LOCKED;
        endcase
    end

    // Output decode.
    always @(*) begin
        unlocked  = (state == S_UNLOCKED);
        locked_out = (state == S_LOCKOUT);
        status = state;
    end
endmodule
