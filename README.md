![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# MNIST Neural Network Inference on Silicon

A hardware implementation of a 2-layer neural network for MNIST digit classification, designed for Tiny Tapeout.

> ## What is Tiny Tapeout?
>
> Tiny Tapeout is an educational project that makes it easier and cheaper than ever to get digital designs manufactured on real silicon. Learn more at [tinytapeout.com](https://tinytapeout.com).

## 3D Viewer
[Open 3D viewer](https://gds-viewer.tinytapeout.com/?model=https://unclegravity.github.io/tinytapeout-verilog/tinytapeout.oas&pdk=sky130A)

## 2D Preview
![png](https://unclegravity.github.io/tinytapeout-verilog/gds_render.png)

## Overview

This project implements a complete neural network inference pipeline in Verilog, optimized for minimal gate count while maintaining good accuracy on handwritten digit recognition.

**Architecture:**
- **Input:** 8×8 pixels, 2-bit quantized (streamed 4 pixels/cycle)
- **Layer 1:** 64 → 48 neurons (ternary weights, sign activation)
- **Layer 2:** 48 → 10 neurons (ternary weights)
- **Output:** Digit prediction (0-9) via argmax

**Performance:**
- **Accuracy:** 80.96% on quantized MNIST test set
- **Throughput:** ~3,876 cycles per inference @ 10MHz = 388µs
- **Gate count:** ~180 gates
- **Memory:** 917 bytes ROM (weights + biases)

## How It Works

### Data Flow

1. **Pixel Streaming (16 cycles)** - Load 64 pixels via parallel interface (4 pixels/cycle)
2. **Layer 1 Computation (~3,216 cycles)** - Sequential MAC operations for 48 neurons
3. **Layer 2 Computation (~520 cycles)** - Sequential MAC operations for 10 output neurons
4. **Argmax (11 cycles)** - Combinational logic finds maximum logit
5. **Result Ready** - 4-bit prediction output

### Core Components

- **`ternary_mac.v`** - Multiply-accumulate unit for {-1, 0, +1} weights
- **`layer1_neuron.v`** - Single neuron compute (64 MACs + bias)
- **`sign_activation.v`** - Sign function: ±1 based on input sign
- **`layer2_neuron.v`** - Output layer neuron (48 MACs + bias)
- **`argmax.v`** - Parallel comparator tree for maximum logit
- **`mnist_top.v`** - FSM coordinator and memory management
- **`project.v`** - Tiny Tapeout wrapper (pin mapping)

### Optimization Techniques

1. **Ternary weights** ({-1, 0, +1}) - No multipliers needed
2. **Sequential MAC** - Single compute unit reused for all neurons
3. **K-means quantization** - Input pixels quantized to 2-bit with optimal thresholds [33, 99, 169]
4. **ROM-based weights** - All parameters stored in synthesizable memory
5. **Parallel streaming** - 4 pixels/cycle reduces input latency

## Pin Configuration

### Inputs (`ui_in[7:0]`)
- `ui[1:0]` - Pixel 0 (2-bit)
- `ui[3:2]` - Pixel 1 (2-bit)
- `ui[5:4]` - Pixel 2 (2-bit)
- `ui[7:6]` - Pixel 3 (2-bit)

### Outputs (`uo_out[7:0]`)
- `uo[3:0]` - Predicted digit (0-9)
- `uo[4]` - Done flag
- `uo[5]` - Busy flag
- `uo[7:6]` - Unused

### Bidirectional (`uio[7:0]`)
- `uio[0]` - Start signal (input)
- `uio[7:1]` - Unused

## Testing

Run the Cocotb test suite:

```bash
nix develop -c uv run make -B
```

Expected output: **10/10 tests passed (100.0%)**

View waveforms:
```bash
gtkwave tb.vcd
```

See [test/README.md](test/README.md) for detailed testing information.

## Project Structure

```
src/
├── project.v          # Tiny Tapeout wrapper
├── mnist_top.v        # Top-level FSM and memory
├── layer1_full.v      # Layer 1 controller + ROM
├── layer1_neuron.v    # Single neuron compute
├── layer2_full.v      # Layer 2 controller + ROM
├── layer2_neuron.v    # Output neuron compute
├── ternary_mac.v      # Core MAC unit
├── sign_activation.v  # Sign activation function
├── argmax.v           # Maximum finder
└── *.hex              # Weight/bias ROM data

test/
├── test.py            # Cocotb tests
├── tb.v               # Verilog testbench
└── test_vectors/      # Golden reference data

experiments/
└── winner_48h_kmeans/ # Training code and model
```

## Training

The model was trained using:
- **Framework:** Custom PyTorch implementation
- **Dataset:** MNIST downsampled to 8×8 with K-means quantization
- **Optimization:** Grid search over seeds, learning rates, layer sizes
- **Validation:** Python sequential forward pass matches Verilog exactly

Training code: [`experiments/winner_48h_kmeans/`](experiments/winner_48h_kmeans/)

## Resources

- [Tiny Tapeout](https://tinytapeout.com) - Get your designs manufactured
- [Project Documentation](docs/info.md) - Detailed design information
- [FAQ](https://tinytapeout.com/faq/) - Common questions
- [Discord Community](https://tinytapeout.com/discord) - Get help and share

## License

Licensed under Apache 2.0. See project files for details.
