/*
 * Layer 1 Neuron - Single neuron computation
 * 
 * Computes one neuron of layer 1:
 *   1. Accumulate 64 MACs (input[i] * weight[i])
 *   2. Add bias
 *   3. Output result (before activation)
 * 
 * This module performs sequential computation over 64 clock cycles.
 * The activation function (sign) is separate.
 * 
 * Interface:
 *   - start: Pulse high to begin computation
 *   - done: Goes high when result is ready
 *   - Inputs/weights fed sequentially via input_val/weight
 *   - bias: Constant bias value for this neuron
 *   - result: Final accumulated value (after bias, before activation)
 */

module layer1_neuron (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,            // Start computation
    input  wire [1:0]  input_val,        // One input per clock [0-3]
    input  wire [1:0]  weight,           // One weight per clock (ternary)
    input  wire signed [3:0] bias,       // 4-bit signed bias
    output reg         done,             // Result ready
    output reg  signed [6:0] result,     // 7-bit signed result
    output wire [5:0]  mac_count_out     // Which MAC we're on (0-63)
);

    // State machine
    localparam IDLE = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam ADD_BIAS = 2'd2;
    localparam DONE = 2'd3;
    
    reg [1:0] state;
    reg [5:0] count;  // 0-63 counter (needs 6 bits)
    
    // Expose counter for parent to know which input/weight we need
    assign mac_count_out = count;
    
    // MAC unit signals
    reg mac_enable;
    wire signed [6:0] mac_acc_in;  // Combinational feedback
    wire signed [6:0] mac_acc_out;
    
    // Instantiate MAC unit
    ternary_mac mac (
        .clk(clk),
        .rst_n(rst_n),
        .enable(mac_enable),
        .input_val(input_val),
        .weight(weight),
        .acc_in(mac_acc_in),
        .acc_out(mac_acc_out)
    );
    
    // Combinational feedback path: feed MAC output back to input when computing
    // count=0: first MAC processes input[0]
    // count=1: first result appears, feed back for input[1]
    assign mac_acc_in = (state == COMPUTE && count >= 6'd1) ? mac_acc_out : 7'sd0;
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            count <= 6'd0;
            done <= 1'b0;
            result <= 7'sd0;
            mac_enable <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= COMPUTE;
                        count <= 6'd0;
                        mac_enable <= 1'b1;  // Enable MAC for next cycle
                    end else begin
                        mac_enable <= 1'b0;
                    end
                end
                
                COMPUTE: begin
                    // Keep MAC enabled
                    count <= count + 1;
                    
                    if (count == 6'd63) begin
                        // Just completed 64th MAC (count went 0->63), move to add bias
                        state <= ADD_BIAS;
                    end
                end
                
                ADD_BIAS: begin
                    // Add bias to accumulated MAC result
                    result <= mac_acc_out + {{3{bias[3]}}, bias};  // Sign extend bias to 7 bits
                    state <= DONE;
                end
                
                DONE: begin
                    done <= 1'b1;
                    if (!start) begin
                        // Wait for start to go low before returning to IDLE
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
