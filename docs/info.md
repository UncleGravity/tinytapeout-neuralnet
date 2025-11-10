<!---
This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a 2-layer neural network for MNIST digit classification directly in hardware. The design recognizes handwritten digits (0-9) from 8×8 pixel images with 80.96% accuracy.

### Architecture

The neural network consists of:

- **Input Layer:** 64 pixels (8×8), 2-bit quantized using K-means thresholds [33, 99, 169]
- **Hidden Layer:** 48 neurons with ternary weights {-1, 0, +1} and sign activation
- **Output Layer:** 10 neurons (one per digit) with ternary weights
- **Argmax:** Combinational logic to find the predicted digit

### Data Flow

1. **Pixel Streaming (16 cycles):** Load 64 pixels via the parallel interface at 4 pixels per cycle
2. **Layer 1 Computation (~3,216 cycles):** Sequential MAC operations compute all 48 hidden neurons
3. **Layer 2 Computation (~520 cycles):** Sequential MAC operations compute 10 output logits
4. **Argmax (11 cycles):** Find the maximum logit via a comparator tree
5. **Result:** 4-bit output indicating predicted digit (0-9)

**Total latency:** ~3,876 cycles per inference (~388µs @ 10MHz)

### Hardware Optimization

The design achieves minimal gate count through several techniques:

- **Ternary weights:** All weights are {-1, 0, +1}, eliminating multipliers
- **Sequential MAC:** A single multiply-accumulate unit is reused for all neurons
- **ROM-based storage:** Weights and biases stored in 917 bytes of synthesizable ROM
- **Quantized inputs:** 2-bit pixels reduce input bandwidth and computation width

### Memory Layout

- Layer 1 weights: 3,072 weights × 2 bits = 6,144 bits (768 bytes)
- Layer 1 biases: 48 biases × 4 bits = 192 bits (24 bytes)
- Layer 2 weights: 480 weights × 2 bits = 960 bits (120 bytes)
- Layer 2 biases: 10 biases × 4 bits = 40 bits (5 bytes)
- **Total: 917 bytes ROM, ~180 gates**

## How to test

### Protocol

1. **Reset:** Assert `rst_n` low, then high
2. **Load pixels:** Set `ui_in[7:0]` to first 4 pixels (2 bits each)
3. **Start inference:** Pulse `uio_in[0]` high for one cycle
4. **Stream remaining pixels:** Continue sending 4 pixels/cycle for 15 more cycles (total 16 cycles)
5. **Wait for completion:** Poll `uo_out[4]` (done flag) until it goes high
6. **Read result:** The predicted digit is available on `uo_out[3:0]`

### Pin Mapping

**Inputs (`ui_in[7:0]`):**
- Bits [1:0]: Pixel 0 (2-bit quantized value 0-3)
- Bits [3:2]: Pixel 1
- Bits [5:4]: Pixel 2
- Bits [7:6]: Pixel 3

**Outputs (`uo_out[7:0]`):**
- Bits [3:0]: Predicted digit (0-9)
- Bit [4]: Done flag (1 = inference complete)
- Bit [5]: Busy flag (1 = computing)
- Bits [7:6]: Unused

**Bidirectional (`uio[7:0]`):**
- Bit [0]: Start signal (input, pulse high to begin)
- Bits [7:1]: Unused

### Example Test Sequence

For a sample 8×8 digit image with 2-bit quantized pixels:

```
Cycle 0:  ui_in = 8'b00000000 (pixels 0-3), uio_in[0] = 1 (start)
Cycle 1:  ui_in = 8'b00000000 (pixels 4-7), uio_in[0] = 0
Cycle 2:  ui_in = 8'b00010001 (pixels 8-11)
...
Cycle 15: ui_in = 8'b00000000 (pixels 60-63)
Cycle 16-3891: Wait (computing)
Cycle 3892: uo_out[4] = 1 (done), uo_out[3:0] = digit (e.g., 0x7 for "7")
```

### Pixel Quantization

Input images must be:
1. Downsampled to 8×8 pixels
2. Converted to grayscale (0-255)
3. Quantized to 2-bit using thresholds [33, 99, 169]:
   - 0-33 → 0
   - 34-99 → 1
   - 100-169 → 2
   - 170-255 → 3

### Expected Performance

- **Accuracy:** 80.96% on quantized MNIST test set
- **Throughput:** ~258 inferences/second @ 10MHz
- **Latency:** 388µs per inference @ 10MHz

## External hardware

No external hardware is required. The design is fully self-contained with internal ROM.

Optional additions for a complete system:
- **Microcontroller:** To preprocess images and stream pixels via the interface
- **Camera module:** To capture handwritten digits (requires MCU preprocessing)
- **Display:** To show the predicted digit (e.g., 7-segment or OLED)
- **UART/SPI bridge:** For easy interfacing from a host computer

The design operates at any clock frequency, though typical testing uses 10MHz. Higher clock rates will proportionally increase inference throughput.