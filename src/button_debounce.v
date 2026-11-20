`timescale 1ns / 1ps
// Synchronizer + debounce filter. Set COUNT_MAX for the board clock frequency.
// At 100 MHz, COUNT_MAX=1_000_000 gives approximately 10 ms debounce.
module button_debounce #(
    parameter integer COUNT_MAX = 1_000_000
)(
    input  wire clk,
    input  wire reset,
    input  wire button_in,
    output reg  button_out
);
    reg sync_ff1, sync_ff2;
    reg stable_value;
    reg [31:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
            stable_value <= 1'b0;
            button_out <= 1'b0;
            counter <= 32'd0;
        end else begin
            sync_ff1 <= button_in;
            sync_ff2 <= sync_ff1;
            button_out <= 1'b0; // one-cycle pulse when stable value changes to 1

            if (sync_ff2 == stable_value) begin
                counter <= 32'd0;
            end else if (counter >= COUNT_MAX-1) begin
                counter <= 32'd0;
                stable_value <= sync_ff2;
                if (sync_ff2) button_out <= 1'b1;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule
