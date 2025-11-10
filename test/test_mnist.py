"""
Simple end-to-end test for ROM-based MNIST top module

Tests the new architecture where weights are in ROM.
Only needs to stream 64 pixels - much simpler!
"""

from pathlib import Path

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

# Path to test vectors
VECTOR_DIR = Path(__file__).parent / "test_vectors" / "vectors"


def load_test_vector(test_idx):
    """Load a test vector (just pixels and expected output)."""
    # Load input pixels
    input_file = VECTOR_DIR / f"test_{test_idx:03d}_input.txt"
    pixels = []
    with open(input_file, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                pixels.append(int(line))
    assert len(pixels) == 64, f"Expected 64 pixels, got {len(pixels)}"

    # Load expected output
    output_file = VECTOR_DIR / f"test_{test_idx:03d}_output.txt"
    with open(output_file, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                expected = int(line)
                break

    # Load metadata
    metadata_file = VECTOR_DIR / f"test_{test_idx:03d}_metadata.txt"
    metadata = {}
    with open(metadata_file, "r") as f:
        for line in f:
            line = line.strip()
            if ":" in line:
                key, value = line.split(":", 1)
                metadata[key.strip()] = value.strip()

    return pixels, expected, metadata


@cocotb.test()
async def test_single_inference(dut):
    """Test single inference with vector 0 (detailed logging)."""

    dut._log.info("=" * 80)
    dut._log.info("ROM-Based MNIST Top - Single Inference Test")
    dut._log.info("=" * 80)

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Load test vector
    pixels, expected, metadata = load_test_vector(0)

    dut._log.info(f"Test Vector: 0")
    dut._log.info(f"True Label: {metadata.get('True label', '?')}")
    dut._log.info(f"Expected Prediction: {expected}")
    dut._log.info("")

    # Reset
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.pixel_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Start inference
    dut._log.info("Starting inference...")
    dut.start.value = 1
    await RisingEdge(dut.clk)

    cycle_count = 1

    # Stream 64 pixels (that's it - no weights!)
    dut._log.info(f"Cycle {cycle_count}: Streaming 64 pixels...")
    for i in range(64):
        dut.pixel_in.value = pixels[i]
        await RisingEdge(dut.clk)
        cycle_count += 1

    dut._log.info(f"Cycle {cycle_count}: All pixels streamed")
    dut._log.info(f"Cycle {cycle_count}: Waiting for computation to complete...")

    # Wait for done signal
    max_cycles = 5000  # Safety timeout
    while not dut.done.value and cycle_count < max_cycles:
        await RisingEdge(dut.clk)
        cycle_count += 1

        # Log progress every 500 cycles
        if cycle_count % 500 == 0:
            dut._log.info(f"  Cycle {cycle_count}: Still computing...")

    if cycle_count >= max_cycles:
        dut._log.error(f"TIMEOUT: No done signal after {max_cycles} cycles")
        assert False, "Inference timed out"

    # Check result
    result = int(dut.prediction.value)

    dut._log.info("")
    dut._log.info(f"Inference complete!")
    dut._log.info(f"Total Cycles: {cycle_count}")
    dut._log.info(f"Expected:     {expected}")
    dut._log.info(f"Got:          {result}")

    if result == expected:
        dut._log.info("✓ PASS")
    else:
        dut._log.error(f"✗ FAIL - Mismatch!")
        assert False, f"Expected {expected}, got {result}"

    # Clear start
    dut.start.value = 0
    await RisingEdge(dut.clk)


@cocotb.test()
async def test_multiple_inferences(dut):
    """Test first 10 vectors to verify correctness."""

    dut._log.info("")
    dut._log.info("=" * 80)
    dut._log.info("ROM-Based MNIST Top - Multiple Inference Test (10 vectors)")
    dut._log.info("=" * 80)

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    num_vectors = 10
    num_pass = 0
    num_fail = 0
    failures = []
    cycle_counts = []

    for test_idx in range(num_vectors):
        # Load test vector
        pixels, expected, metadata = load_test_vector(test_idx)

        # Reset
        dut.rst_n.value = 0
        dut.start.value = 0
        await RisingEdge(dut.clk)
        dut.rst_n.value = 1
        await RisingEdge(dut.clk)

        # Start inference
        dut.start.value = 1
        await RisingEdge(dut.clk)

        cycle_count = 1

        # Stream pixels
        for i in range(64):
            dut.pixel_in.value = pixels[i]
            await RisingEdge(dut.clk)
            cycle_count += 1

        # Wait for done
        max_cycles = 5000
        while not dut.done.value and cycle_count < max_cycles:
            await RisingEdge(dut.clk)
            cycle_count += 1

        if cycle_count >= max_cycles:
            dut._log.error(f"Test {test_idx}: TIMEOUT")
            num_fail += 1
            failures.append(
                {
                    "idx": test_idx,
                    "expected": expected,
                    "got": "TIMEOUT",
                    "cycles": cycle_count,
                }
            )
            continue

        # Check result
        result = int(dut.prediction.value)
        cycle_counts.append(cycle_count)

        if result == expected:
            num_pass += 1
            status = "✓"
        else:
            num_fail += 1
            status = "✗"
            failures.append(
                {
                    "idx": test_idx,
                    "expected": expected,
                    "got": result,
                    "cycles": cycle_count,
                }
            )

        true_label = metadata.get("True label", "?")
        dut._log.info(
            f"{status} Test {test_idx:2d}: Label={true_label}, "
            f"Expected={expected}, Got={result}, Cycles={cycle_count}"
        )

        # Clear start
        dut.start.value = 0
        await RisingEdge(dut.clk)

    # Summary
    if cycle_counts:
        avg_cycles = sum(cycle_counts) / len(cycle_counts)
        min_cycles = min(cycle_counts)
        max_cycles = max(cycle_counts)
    else:
        avg_cycles = min_cycles = max_cycles = 0

    dut._log.info("")
    dut._log.info("=" * 80)
    dut._log.info(
        f"RESULTS: {num_pass}/{num_vectors} tests passed ({100 * num_pass / num_vectors:.1f}%)"
    )
    if cycle_counts:
        dut._log.info(
            f"Cycle Stats: Min={min_cycles}, Max={max_cycles}, Avg={avg_cycles:.1f}"
        )
    dut._log.info("=" * 80)

    if num_fail > 0:
        dut._log.error("")
        dut._log.error(f"FAILURES: {num_fail} tests failed")
        for f in failures:
            dut._log.error(
                f"Test {f['idx']:2d}: Expected {f['expected']}, Got {f['got']}"
            )

        assert False, f"{num_fail}/{num_vectors} tests failed"
    else:
        dut._log.info("✓ ALL TESTS PASSED!")
