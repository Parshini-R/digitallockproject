`timescale 1ns / 1ps
// Nexys A7 seven-segment display driver (active-low segments and digit enables).
// Displays one hexadecimal digit on the rightmost digit.
module seven_segment(
    input  wire [3:0] value,
    output reg  [6:0] seg,
    output wire       dp,
    output wire [7:0] an
);
    assign dp = 1'b1;        // decimal point off
    assign an = 8'b11111110; // rightmost digit enabled

    // Segment order: {a,b,c,d,e,f,g}; 0 = illuminated.
    always @(*) begin
        case (value)
            4'h0: seg = 7'b0000001;
            4'h1: seg = 7'b1001111;
            4'h2: seg = 7'b0010010;
            4'h3: seg = 7'b0000110;
            4'h4: seg = 7'b1001100;
            4'h5: seg = 7'b0100100;
            4'h6: seg = 7'b0100000;
            4'h7: seg = 7'b0001111;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0000100;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b1100000;
            4'hC: seg = 7'b0110001;
            4'hD: seg = 7'b1000010;
            4'hE: seg = 7'b0110000;
            4'hF: seg = 7'b0111000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
