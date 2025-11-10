/*
 * Argmax - Find index of maximum value
 * 
 * Pure combinational logic to find the maximum among 10 signed values
 * 
 * Input: 10 signed 6-bit logits from Layer 2
 * Output: 4-bit index (0-9) of the maximum value
 * 
 * Architecture:
 *   - Sequential comparison: compare each value with current max
 *   - Track both max value and its index
 *   - In case of tie, first occurrence wins (lower index)
 * 
 * Timing: Pure combinational (no clock needed)
 */

module argmax (
    input  wire signed [5:0] logit_0,
    input  wire signed [5:0] logit_1,
    input  wire signed [5:0] logit_2,
    input  wire signed [5:0] logit_3,
    input  wire signed [5:0] logit_4,
    input  wire signed [5:0] logit_5,
    input  wire signed [5:0] logit_6,
    input  wire signed [5:0] logit_7,
    input  wire signed [5:0] logit_8,
    input  wire signed [5:0] logit_9,
    output wire [3:0] max_index
);

    // Internal wires for pairwise comparisons
    wire signed [5:0] max_01, max_23, max_45, max_67, max_89;
    wire [3:0] idx_01, idx_23, idx_45, idx_67, idx_89;
    
    wire signed [5:0] max_0123, max_4567;
    wire [3:0] idx_0123, idx_4567;
    
    wire signed [5:0] max_01234567;
    wire [3:0] idx_01234567;
    
    // Level 1: Compare pairs (0-1, 2-3, 4-5, 6-7, 8-9)
    assign max_01 = (logit_0 >= logit_1) ? logit_0 : logit_1;
    assign idx_01 = (logit_0 >= logit_1) ? 4'd0 : 4'd1;
    
    assign max_23 = (logit_2 >= logit_3) ? logit_2 : logit_3;
    assign idx_23 = (logit_2 >= logit_3) ? 4'd2 : 4'd3;
    
    assign max_45 = (logit_4 >= logit_5) ? logit_4 : logit_5;
    assign idx_45 = (logit_4 >= logit_5) ? 4'd4 : 4'd5;
    
    assign max_67 = (logit_6 >= logit_7) ? logit_6 : logit_7;
    assign idx_67 = (logit_6 >= logit_7) ? 4'd6 : 4'd7;
    
    assign max_89 = (logit_8 >= logit_9) ? logit_8 : logit_9;
    assign idx_89 = (logit_8 >= logit_9) ? 4'd8 : 4'd9;
    
    // Level 2: Compare pairs of pairs (0-3, 4-7)
    assign max_0123 = (max_01 >= max_23) ? max_01 : max_23;
    assign idx_0123 = (max_01 >= max_23) ? idx_01 : idx_23;
    
    assign max_4567 = (max_45 >= max_67) ? max_45 : max_67;
    assign idx_4567 = (max_45 >= max_67) ? idx_45 : idx_67;
    
    // Level 3: Compare 0-7
    assign max_01234567 = (max_0123 >= max_4567) ? max_0123 : max_4567;
    assign idx_01234567 = (max_0123 >= max_4567) ? idx_0123 : idx_4567;
    
    // Level 4: Final comparison with 8-9
    assign max_index = (max_01234567 >= max_89) ? idx_01234567 : idx_89;

endmodule
