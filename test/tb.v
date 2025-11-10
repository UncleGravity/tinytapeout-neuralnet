/*
 * Testbench for Tiny Tapeout MNIST Wrapper
 * 
 * Tests the complete wrapper with streaming protocol
 */

`default_nettype none
`timescale 1ns/1ps

module tb ();
    
    // Tiny Tapeout signals
    reg [7:0]  ui_in;
    wire [7:0] uo_out;
    reg [7:0]  uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        ena;
    reg        clk;
    reg        rst_n;
    
    // Instantiate Tiny Tapeout wrapper
    tt_um_unclegravity_mnist uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Dump waves
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end

endmodule
