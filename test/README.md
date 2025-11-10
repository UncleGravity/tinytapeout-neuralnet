# Test Directory

This directory contains Cocotb tests for the MNIST neural network inference core.

## Quick Start

Run tests from the test directory root:

```bash
nix develop -c uv run make -B
```

## Architecture

The design implements a 2-layer neural network optimized for MNIST digit classification:

```
Input: 8×8 pixels, 2-bit quantized [0-3]
  ↓ (parallel streaming: 4 pixels/cycle, 16 cycles)
Layer 1: 64 → 48 neurons (ternary weights, sign activation)
  ↓
Layer 2: 48 → 10 neurons (ternary weights)
  ↓
Argmax: Output digit (0-9)
```

## Test Files

- `Makefile` - Test runner (uses Icarus Verilog + Cocotb)
- `tb.v` - Verilog testbench wrapper
- `test.py` - Main Cocotb test (parallel streaming protocol)
- `test_vectors/` - 105 pre-generated golden reference test cases
- `*.hex` - ROM data (weights/biases, copied from `../src/`)

## Viewing Waveforms

After running tests, inspect signals with GTKWave:

```bash
gtkwave tb.vcd
```

Key signals to observe:
- `uut.start` - Inference start trigger
- `uut.mnist_core.state` - FSM state
- `uut.uo_out[0]` - Done flag
- `uut.uo_out[4:1]` - Predicted digit

## Dependencies

All dependencies are managed via Nix (`flake.nix`) and uv (`pyproject.toml`):

## Regenerating Test Vectors

Test vectors are pre-generated. Only regenerate when the model changes:

```bash
cd test_vectors
nix develop -c uv run python generate_vectors.py
```

This creates 105 test cases with golden reference values for all intermediate signals.
