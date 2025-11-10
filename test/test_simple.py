"""
Ultra-simple test to verify pixels load correctly
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


@cocotb.test()
async def test_pixel_loading(dut):
    """Test that pixels load into MNIST correctly."""

    dut._log.info("=" * 80)
    dut._log.info("Simple Pixel Loading Test")
    dut._log.info("=" * 80)

    # Start clock
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Create simple test pattern: 0,1,2,3, 0,1,2,3, ... (repeating)
    pixels = [(i % 4) for i in range(64)]

    dut._log.info(f"Test pattern: {pixels[:16]}")

    # Set first 4 pixels and start
    ui_in_value = (pixels[3] << 6) | (pixels[2] << 4) | (pixels[1] << 2) | pixels[0]
    dut.ui_in.value = ui_in_value
    dut.uio_in.value = 0x01

    dut._log.info(
        f"Cycle 0: start=1, pixels[0:3] = {pixels[0]}, {pixels[1]}, {pixels[2]}, {pixels[3]}"
    )
    await RisingEdge(dut.clk)

    # Stream remaining 15 cycles
    for i in range(1, 16):
        idx = i * 4
        ui_in_value = (
            (pixels[idx + 3] << 6)
            | (pixels[idx + 2] << 4)
            | (pixels[idx + 1] << 2)
            | pixels[idx]
        )
        dut.ui_in.value = ui_in_value

        if i < 4:
            dut._log.info(
                f"Cycle {i}: pixels[{idx}:{idx + 3}] = {pixels[idx]}, {pixels[idx + 1]}, {pixels[idx + 2]}, {pixels[idx + 3]}"
            )

        await RisingEdge(dut.clk)

    dut._log.info("All 16 cycles streamed, waiting a few cycles...")
    await ClockCycles(dut.clk, 5)

    # Check what's in MNIST's pixel buffer
    dut._log.info("")
    dut._log.info("Checking MNIST pixel buffer:")
    for i in range(16):
        try:
            val = int(dut.uut.mnist_core.pixels[i].value)
            expected = pixels[i]
            match = "✓" if val == expected else "✗"
            dut._log.info(f"  pixels[{i:2d}] = {val} (expected {expected}) {match}")
        except:
            dut._log.info(f"  pixels[{i:2d}] = (couldn't read)")

    dut._log.info("")
    dut._log.info("Test complete - check logs above for mismatches")
