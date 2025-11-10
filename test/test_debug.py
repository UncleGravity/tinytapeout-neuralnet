"""
Debug test with extensive logging to trace pixel flow
"""

from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# Path to test vectors
VECTOR_DIR = Path(__file__).parent / "test_vectors" / "vectors"


def load_test_vector(test_idx):
    """Load a test vector."""
    input_file = VECTOR_DIR / f"test_{test_idx:03d}_input.txt"
    pixels = []
    with open(input_file, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                pixels.append(int(line))
    assert len(pixels) == 64, f"Expected 64 pixels, got {len(pixels)}"

    output_file = VECTOR_DIR / f"test_{test_idx:03d}_output.txt"
    with open(output_file, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                expected = int(line)
                break

    return pixels, expected


@cocotb.test()
async def test_wrapper_debug(dut):
    """Debug test with detailed logging of every cycle."""

    dut._log.info("=" * 80)
    dut._log.info("DEBUG TEST - Detailed Cycle-by-Cycle Logging")
    dut._log.info("=" * 80)

    # Start clock
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Load test vector
    pixels, expected = load_test_vector(0)

    dut._log.info(f"Expected prediction: {expected}")
    dut._log.info(f"First 8 pixels: {pixels[:8]}")
    dut._log.info("")

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    dut._log.info("After reset")
    dut._log.info(f"  state (should be IDLE=000): {bin(int(dut.uut.state.value))}")
    dut._log.info("")

    cycle = 0

    # Assert start signal
    dut._log.info(f"Cycle {cycle}: Asserting start signal")
    dut.uio_in.value = 0x01
    await RisingEdge(dut.clk)
    cycle += 1

    dut._log.info(f"Cycle {cycle}: After start")
    dut._log.info(f"  state: {bin(int(dut.uut.state.value))}")
    dut._log.info(f"  busy: {int(dut.uut.busy_reg.value)}")
    dut._log.info("")

    # Stream pixels - log first few cycles in detail
    for i in range(16):
        # Pack 4 pixels
        pixel_0 = pixels[i * 4 + 0]
        pixel_1 = pixels[i * 4 + 1]
        pixel_2 = pixels[i * 4 + 2]
        pixel_3 = pixels[i * 4 + 3]

        ui_in_value = (pixel_3 << 6) | (pixel_2 << 4) | (pixel_1 << 2) | pixel_0
        dut.ui_in.value = ui_in_value

        if i < 4:  # Log first 4 cycles in detail
            dut._log.info(f"Cycle {cycle}: Setting ui_in")
            dut._log.info(
                f"  ui_in = 0x{ui_in_value:02x} (pixels: {pixel_0}, {pixel_1}, {pixel_2}, {pixel_3})"
            )
            dut._log.info(f"  state: {bin(int(dut.uut.state.value))}")
            dut._log.info(f"  pixel_count: {int(dut.uut.pixel_count.value)}")

        await RisingEdge(dut.clk)
        cycle += 1

        if i < 4:  # Log what got stored
            dut._log.info(f"Cycle {cycle}: After clock")
            dut._log.info(f"  state: {bin(int(dut.uut.state.value))}")
            dut._log.info(f"  pixel_count: {int(dut.uut.pixel_count.value)}")
            # Check what's in the buffer
            try:
                buf_idx = i * 4
                p0 = int(dut.uut.pixel_buffer[buf_idx + 0].value)
                p1 = int(dut.uut.pixel_buffer[buf_idx + 1].value)
                p2 = int(dut.uut.pixel_buffer[buf_idx + 2].value)
                p3 = int(dut.uut.pixel_buffer[buf_idx + 3].value)
                dut._log.info(
                    f"  buffer[{buf_idx}:{buf_idx + 3}] = {p0}, {p1}, {p2}, {p3}"
                )
                if p0 != pixel_0 or p1 != pixel_1 or p2 != pixel_2 or p3 != pixel_3:
                    dut._log.error(
                        f"  MISMATCH! Expected {pixel_0}, {pixel_1}, {pixel_2}, {pixel_3}"
                    )
            except:
                dut._log.info(f"  (couldn't read buffer)")
            dut._log.info("")

    dut._log.info(f"Cycle {cycle}: All pixels streamed")
    dut._log.info(f"  state: {bin(int(dut.uut.state.value))}")
    dut._log.info("")

    # Check buffer contents
    dut._log.info("Pixel buffer contents (first 16):")
    for i in range(16):
        try:
            val = int(dut.uut.pixel_buffer[i].value)
            dut._log.info(f"  buffer[{i:2d}] = {val} (expected {pixels[i]})")
            if val != pixels[i]:
                dut._log.error(f"    MISMATCH!")
        except:
            dut._log.info(f"  buffer[{i:2d}] = (couldn't read)")
    dut._log.info("")

    # Wait a few cycles to see state transitions
    for i in range(10):
        await RisingEdge(dut.clk)
        cycle += 1
        dut._log.info(f"Cycle {cycle}:")
        dut._log.info(f"  state: {bin(int(dut.uut.state.value))}")
        dut._log.info(f"  mnist_start: {int(dut.uut.mnist_start.value)}")
        dut._log.info(f"  mnist_pixel_idx: {int(dut.uut.mnist_pixel_idx.value)}")
        try:
            dut._log.info(f"  mnist_pixel_in: {int(dut.uut.mnist_pixel_in.value)}")
        except:
            pass

    dut._log.info("")
    dut._log.info("Waiting for done...")

    # Wait for done
    max_cycles = 5000
    while not dut.uo_out.value[4] and cycle < max_cycles:
        await RisingEdge(dut.clk)
        cycle += 1
        if cycle % 500 == 0:
            dut._log.info(f"  Cycle {cycle}: still computing...")

    if cycle >= max_cycles:
        dut._log.error("TIMEOUT!")
        assert False

    result = int(dut.uo_out.value) & 0x0F
    dut._log.info(f"")
    dut._log.info(f"DONE at cycle {cycle}")
    dut._log.info(f"Expected: {expected}")
    dut._log.info(f"Got:      {result}")

    if result == expected:
        dut._log.info("✓ PASS")
    else:
        dut._log.error("✗ FAIL")
        assert False
