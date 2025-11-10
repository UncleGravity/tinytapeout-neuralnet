/*
 * Tiny Tapeout Wrapper for MNIST Neural Network
 * 
 * Simple pass-through wrapper connecting TT pins to MNIST core.
 * MNIST core accepts 4 pixels per cycle directly - no buffering needed!
 * 
 * Protocol:
 *   1. Set ui_in[7:0] = first 4 pixels
 *   2. Assert start (uio_in[0] = 1)  
 *   3. Stream remaining 15 cycles of 4 pixels each
 *   4. Wait for done (uo_out[4] = 1)
 *   5. Read prediction from uo_out[3:0]
 * 
 * Timing: 16 cycles (load) + ~3,747 cycles (inference) = ~3,763 cycles total
 * 
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_unclegravity_mnist (
    input  wire [7:0] ui_in,    // Dedicated inputs: 4 pixels (2-bit each)
    output wire [7:0] uo_out,   // Dedicated outputs: prediction, done, busy
    input  wire [7:0] uio_in,   // IOs: Input path - uio_in[0] = start
    output wire [7:0] uio_out,  // IOs: Output path - unused
    output wire [7:0] uio_oe,   // IOs: Enable path - all inputs
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // ========================================================================
    // Simple Pin Assignments - Direct Pass-Through
    // ========================================================================
    
    wire [7:0] pixels_in = ui_in;      // 4 pixels: [7:6]=px3, [5:4]=px2, [3:2]=px1, [1:0]=px0
    wire start = uio_in[0];            // Start signal
    
    wire [3:0] prediction;
    wire done;
    wire busy;
    
    assign uo_out[3:0] = prediction;
    assign uo_out[4]   = done;
    assign uo_out[5]   = busy;
    assign uo_out[7:6] = 2'b00;
    
    // Bidirectional pins configured as inputs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    
    // ========================================================================
    // MNIST Core - Direct Connection (No Wrapper Logic Needed!)
    // ========================================================================
    
    mnist_top mnist_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixels_in(pixels_in),     // 4 pixels per cycle, direct from ui_in
        .done(done),
        .prediction(prediction),
        .busy(busy)
    );
    
    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
