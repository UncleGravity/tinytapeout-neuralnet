/*
 * Layer 2 ROM Module
 *
 * Auto-generated from weights.npz - DO NOT EDIT
 *
 * Uses hierarchical combinational case statements for optimal synthesis:
 * - Level 1: 10-way case (neuron selection)
 * - Level 2: 48-way case (input selection per neuron)
 * - Combinational logic provides zero-latency access
 *
 * Memory:
 *   - 480 weights (10 neurons × 48 inputs, 2-bit ternary)
 *   - 10 biases (4-bit signed)
 */

module layer2_rom (
    input  wire [3:0] neuron_idx,   // Which neuron (0-9)
    input  wire [5:0] input_idx,    // Which input (0-47)
    input  wire [3:0] bias_addr,    // Which bias (0-9)
    output reg  [1:0] weight_data,  // Weight output (combinational)
    output reg  [3:0] bias_data     // Bias output (combinational)
);

    // Weight ROM - hierarchical combinational case statement
    always @(*) begin
        case(neuron_idx)
            4'd0: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b11;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b11;
                    6'd4: weight_data = 2'b00;
                    6'd5: weight_data = 2'b11;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b11;
                    6'd9: weight_data = 2'b00;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b11;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b11;
                    6'd15: weight_data = 2'b11;
                    6'd16: weight_data = 2'b01;
                    6'd17: weight_data = 2'b00;
                    6'd18: weight_data = 2'b11;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b00;
                    6'd21: weight_data = 2'b00;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b00;
                    6'd24: weight_data = 2'b01;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b11;
                    6'd27: weight_data = 2'b11;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b01;
                    6'd35: weight_data = 2'b00;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b00;
                    6'd43: weight_data = 2'b11;
                    6'd44: weight_data = 2'b01;
                    6'd45: weight_data = 2'b00;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b01;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd1: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b01;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b11;
                    6'd4: weight_data = 2'b01;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b11;
                    6'd8: weight_data = 2'b00;
                    6'd9: weight_data = 2'b00;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b01;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b00;
                    6'd15: weight_data = 2'b11;
                    6'd16: weight_data = 2'b00;
                    6'd17: weight_data = 2'b00;
                    6'd18: weight_data = 2'b00;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b01;
                    6'd21: weight_data = 2'b01;
                    6'd22: weight_data = 2'b11;
                    6'd23: weight_data = 2'b11;
                    6'd24: weight_data = 2'b11;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b01;
                    6'd27: weight_data = 2'b01;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b11;
                    6'd35: weight_data = 2'b00;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b01;
                    6'd42: weight_data = 2'b00;
                    6'd43: weight_data = 2'b01;
                    6'd44: weight_data = 2'b00;
                    6'd45: weight_data = 2'b00;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b00;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd2: begin
                case(input_idx)
                    6'd0: weight_data = 2'b01;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b00;
                    6'd4: weight_data = 2'b00;
                    6'd5: weight_data = 2'b01;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b11;
                    6'd8: weight_data = 2'b00;
                    6'd9: weight_data = 2'b11;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b01;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b11;
                    6'd15: weight_data = 2'b00;
                    6'd16: weight_data = 2'b00;
                    6'd17: weight_data = 2'b00;
                    6'd18: weight_data = 2'b01;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b01;
                    6'd21: weight_data = 2'b01;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b00;
                    6'd24: weight_data = 2'b01;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b00;
                    6'd27: weight_data = 2'b11;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b01;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b00;
                    6'd35: weight_data = 2'b11;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b00;
                    6'd43: weight_data = 2'b01;
                    6'd44: weight_data = 2'b11;
                    6'd45: weight_data = 2'b01;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b00;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd3: begin
                case(input_idx)
                    6'd0: weight_data = 2'b01;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b11;
                    6'd4: weight_data = 2'b00;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b00;
                    6'd9: weight_data = 2'b00;
                    6'd10: weight_data = 2'b01;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b01;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b00;
                    6'd15: weight_data = 2'b11;
                    6'd16: weight_data = 2'b00;
                    6'd17: weight_data = 2'b01;
                    6'd18: weight_data = 2'b00;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b00;
                    6'd21: weight_data = 2'b00;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b11;
                    6'd24: weight_data = 2'b01;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b11;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b00;
                    6'd35: weight_data = 2'b11;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b01;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b11;
                    6'd43: weight_data = 2'b01;
                    6'd44: weight_data = 2'b11;
                    6'd45: weight_data = 2'b01;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b11;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd4: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b01;
                    6'd4: weight_data = 2'b00;
                    6'd5: weight_data = 2'b01;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b01;
                    6'd9: weight_data = 2'b00;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b01;
                    6'd12: weight_data = 2'b00;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b00;
                    6'd15: weight_data = 2'b01;
                    6'd16: weight_data = 2'b01;
                    6'd17: weight_data = 2'b11;
                    6'd18: weight_data = 2'b11;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b01;
                    6'd21: weight_data = 2'b11;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b11;
                    6'd24: weight_data = 2'b11;
                    6'd25: weight_data = 2'b11;
                    6'd26: weight_data = 2'b01;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b01;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b01;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b00;
                    6'd35: weight_data = 2'b01;
                    6'd36: weight_data = 2'b11;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b01;
                    6'd43: weight_data = 2'b00;
                    6'd44: weight_data = 2'b00;
                    6'd45: weight_data = 2'b00;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b00;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd5: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b00;
                    6'd4: weight_data = 2'b00;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b01;
                    6'd9: weight_data = 2'b00;
                    6'd10: weight_data = 2'b01;
                    6'd11: weight_data = 2'b01;
                    6'd12: weight_data = 2'b00;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b11;
                    6'd15: weight_data = 2'b11;
                    6'd16: weight_data = 2'b01;
                    6'd17: weight_data = 2'b00;
                    6'd18: weight_data = 2'b00;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b00;
                    6'd21: weight_data = 2'b00;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b00;
                    6'd24: weight_data = 2'b01;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b01;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b01;
                    6'd35: weight_data = 2'b00;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b11;
                    6'd38: weight_data = 2'b01;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b01;
                    6'd42: weight_data = 2'b00;
                    6'd43: weight_data = 2'b00;
                    6'd44: weight_data = 2'b00;
                    6'd45: weight_data = 2'b00;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b11;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd6: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b01;
                    6'd4: weight_data = 2'b11;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b11;
                    6'd8: weight_data = 2'b11;
                    6'd9: weight_data = 2'b00;
                    6'd10: weight_data = 2'b11;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b00;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b00;
                    6'd15: weight_data = 2'b00;
                    6'd16: weight_data = 2'b00;
                    6'd17: weight_data = 2'b11;
                    6'd18: weight_data = 2'b00;
                    6'd19: weight_data = 2'b11;
                    6'd20: weight_data = 2'b01;
                    6'd21: weight_data = 2'b11;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b00;
                    6'd24: weight_data = 2'b11;
                    6'd25: weight_data = 2'b01;
                    6'd26: weight_data = 2'b01;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b01;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b01;
                    6'd35: weight_data = 2'b11;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b11;
                    6'd38: weight_data = 2'b01;
                    6'd39: weight_data = 2'b11;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b01;
                    6'd43: weight_data = 2'b01;
                    6'd44: weight_data = 2'b00;
                    6'd45: weight_data = 2'b11;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b01;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd7: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b00;
                    6'd4: weight_data = 2'b01;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b00;
                    6'd9: weight_data = 2'b01;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b01;
                    6'd12: weight_data = 2'b11;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b00;
                    6'd15: weight_data = 2'b01;
                    6'd16: weight_data = 2'b11;
                    6'd17: weight_data = 2'b00;
                    6'd18: weight_data = 2'b00;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b11;
                    6'd21: weight_data = 2'b00;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b11;
                    6'd24: weight_data = 2'b00;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b11;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b11;
                    6'd34: weight_data = 2'b00;
                    6'd35: weight_data = 2'b01;
                    6'd36: weight_data = 2'b01;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b01;
                    6'd42: weight_data = 2'b01;
                    6'd43: weight_data = 2'b00;
                    6'd44: weight_data = 2'b00;
                    6'd45: weight_data = 2'b01;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b11;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd8: begin
                case(input_idx)
                    6'd0: weight_data = 2'b01;
                    6'd1: weight_data = 2'b01;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b00;
                    6'd4: weight_data = 2'b00;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b00;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b01;
                    6'd9: weight_data = 2'b01;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b11;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b11;
                    6'd15: weight_data = 2'b11;
                    6'd16: weight_data = 2'b00;
                    6'd17: weight_data = 2'b11;
                    6'd18: weight_data = 2'b01;
                    6'd19: weight_data = 2'b11;
                    6'd20: weight_data = 2'b00;
                    6'd21: weight_data = 2'b11;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b01;
                    6'd24: weight_data = 2'b01;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b01;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b01;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b00;
                    6'd35: weight_data = 2'b00;
                    6'd36: weight_data = 2'b01;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b11;
                    6'd43: weight_data = 2'b00;
                    6'd44: weight_data = 2'b11;
                    6'd45: weight_data = 2'b00;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b11;
                    default: weight_data = 2'b00;
                endcase
            end
            4'd9: begin
                case(input_idx)
                    6'd0: weight_data = 2'b00;
                    6'd1: weight_data = 2'b00;
                    6'd2: weight_data = 2'b00;
                    6'd3: weight_data = 2'b01;
                    6'd4: weight_data = 2'b01;
                    6'd5: weight_data = 2'b00;
                    6'd6: weight_data = 2'b11;
                    6'd7: weight_data = 2'b00;
                    6'd8: weight_data = 2'b01;
                    6'd9: weight_data = 2'b01;
                    6'd10: weight_data = 2'b00;
                    6'd11: weight_data = 2'b00;
                    6'd12: weight_data = 2'b00;
                    6'd13: weight_data = 2'b00;
                    6'd14: weight_data = 2'b00;
                    6'd15: weight_data = 2'b00;
                    6'd16: weight_data = 2'b00;
                    6'd17: weight_data = 2'b00;
                    6'd18: weight_data = 2'b00;
                    6'd19: weight_data = 2'b00;
                    6'd20: weight_data = 2'b11;
                    6'd21: weight_data = 2'b00;
                    6'd22: weight_data = 2'b00;
                    6'd23: weight_data = 2'b11;
                    6'd24: weight_data = 2'b11;
                    6'd25: weight_data = 2'b00;
                    6'd26: weight_data = 2'b00;
                    6'd27: weight_data = 2'b00;
                    6'd28: weight_data = 2'b00;
                    6'd29: weight_data = 2'b00;
                    6'd30: weight_data = 2'b00;
                    6'd31: weight_data = 2'b00;
                    6'd32: weight_data = 2'b00;
                    6'd33: weight_data = 2'b00;
                    6'd34: weight_data = 2'b11;
                    6'd35: weight_data = 2'b01;
                    6'd36: weight_data = 2'b00;
                    6'd37: weight_data = 2'b00;
                    6'd38: weight_data = 2'b00;
                    6'd39: weight_data = 2'b00;
                    6'd40: weight_data = 2'b00;
                    6'd41: weight_data = 2'b00;
                    6'd42: weight_data = 2'b01;
                    6'd43: weight_data = 2'b11;
                    6'd44: weight_data = 2'b00;
                    6'd45: weight_data = 2'b00;
                    6'd46: weight_data = 2'b00;
                    6'd47: weight_data = 2'b11;
                    default: weight_data = 2'b00;
                endcase
            end
            default: weight_data = 2'b00;
        endcase
    end

    // Bias ROM - simple combinational case statement
    always @(*) begin
        case(bias_addr)
            4'd0: bias_data = 4'hE;
            4'd1: bias_data = 4'hF;
            4'd2: bias_data = 4'h0;
            4'd3: bias_data = 4'h1;
            4'd4: bias_data = 4'hF;
            4'd5: bias_data = 4'h3;
            4'd6: bias_data = 4'hE;
            4'd7: bias_data = 4'hF;
            4'd8: bias_data = 4'h2;
            4'd9: bias_data = 4'h0;
            default: bias_data = 4'h0;
        endcase
    end

endmodule
