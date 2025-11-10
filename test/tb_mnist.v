/*
 * Testbench wrapper for MNIST Top Module
 */

`default_nettype none
`timescale 1ns/1ps

module tb_mnist_top ();
    
    // Signals that Cocotb will drive
    reg        clk;
    reg        rst_n;
    reg        start;
    reg [1:0]  pixel_in;
    wire       done;
    wire [3:0] prediction;
    wire       busy;
    
    // Instantiate MNIST top module
    mnist_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(pixel_in),
        .done(done),
        .prediction(prediction),
        .busy(busy)
    );
    
    // Dump waves
    initial begin
        $dumpfile("mnist_top.vcd");
        $dumpvars(0, tb_mnist_top);
    end

endmodule
