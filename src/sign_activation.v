/*
 * Sign Activation Function
 * 
 * Implements: sign(x) = { +1 if x >= 0, -1 if x < 0 }
 * 
 * Input:  7-bit signed value (layer1 bias output)
 * Output: 2-bit signed ternary {-1, +1}
 * 
 * Note: Zero maps to +1 (x >= 0 case)
 */

module sign_activation (
    input  wire signed [6:0] in_val,    // 7-bit signed input
    output wire signed [1:0] out        // 2-bit signed output: -1 or +1
);

    // Sign function: +1 if in_val >= 0, -1 if in_val < 0
    // In 2-bit signed: +1 = 2'b01, -1 = 2'b11
    assign out = (in_val[6] == 1'b0) ? 2'sb01 : 2'sb11;

endmodule
