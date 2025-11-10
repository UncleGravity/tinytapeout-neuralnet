"""
Generate golden test vectors for Verilog verification.

This creates the definitive reference that Verilog must match bit-exact.
"""

import sys
from pathlib import Path

import numpy as np

# Add parent directories to path
sys.path.append("../..")
sys.path.append("../../..")

from shared.data import downsample_8x8, flatten_images, load_mnist
from winner_48h_kmeans.model import FinalModel


class TestVectorGenerator:
    """Generate comprehensive test vectors with intermediate values."""

    def __init__(self, model, output_dir="vectors"):
        self.model = model
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        # Track min/max values for bit width analysis
        self.stats = {
            "input": {"min": float("inf"), "max": float("-inf")},
            "layer1_acc": {"min": float("inf"), "max": float("-inf")},
            "layer1_bias": {"min": float("inf"), "max": float("-inf")},
            "layer1_act": {"min": float("inf"), "max": float("-inf")},
            "layer2_acc": {"min": float("inf"), "max": float("-inf")},
            "layer2_bias": {"min": float("inf"), "max": float("-inf")},
        }

    def update_stats(self, key, values):
        """Track min/max for bit width analysis."""
        self.stats[key]["min"] = min(self.stats[key]["min"], np.min(values))
        self.stats[key]["max"] = max(self.stats[key]["max"], np.max(values))

    def generate_single_vector(self, sample_input, sample_idx, digit_label=None):
        """
        Generate one complete test vector with all intermediate values.

        Args:
            sample_input: (64,) array of 2-bit values [0-3]
            sample_idx: Test case number
            digit_label: Optional ground truth label
        """
        assert sample_input.shape == (64,), f"Expected (64,), got {sample_input.shape}"
        assert np.all((sample_input >= 0) & (sample_input <= 3)), "Input must be [0-3]"

        sample_input = sample_input.astype(np.int16)
        self.update_stats("input", sample_input)

        # ===== Layer 1 =====
        # Compute each neuron showing intermediate values
        layer1_acc = np.zeros(48, dtype=np.int16)  # After MAC, before bias
        layer1_bias = np.zeros(48, dtype=np.int16)  # After bias, before activation
        layer1_act = np.zeros(48, dtype=np.int8)  # After activation

        for neuron_idx in range(48):
            acc = 0
            for input_idx in range(64):
                weight = self.model.W1[input_idx, neuron_idx]
                input_val = sample_input[input_idx]
                acc += input_val * weight

            layer1_acc[neuron_idx] = acc
            layer1_bias[neuron_idx] = acc + self.model.b1[neuron_idx]
            layer1_act[neuron_idx] = 1 if layer1_bias[neuron_idx] >= 0 else -1

        self.update_stats("layer1_acc", layer1_acc)
        self.update_stats("layer1_bias", layer1_bias)
        self.update_stats("layer1_act", layer1_act)

        # ===== Layer 2 =====
        layer2_acc = np.zeros(10, dtype=np.int16)  # After MAC, before bias
        layer2_logits = np.zeros(10, dtype=np.int16)  # After bias (final output)

        for neuron_idx in range(10):
            acc = 0
            for input_idx in range(48):
                weight = self.model.W2[input_idx, neuron_idx]
                input_val = layer1_act[input_idx]
                acc += input_val * weight

            layer2_acc[neuron_idx] = acc
            layer2_logits[neuron_idx] = acc + self.model.b2[neuron_idx]

        self.update_stats("layer2_acc", layer2_acc)
        self.update_stats("layer2_bias", layer2_logits)

        # ===== Argmax =====
        predicted_class = np.argmax(layer2_logits)

        # ===== Save to files =====
        prefix = f"test_{sample_idx:03d}"

        # Input (64 values, 2-bit each)
        np.savetxt(
            self.output_dir / f"{prefix}_input.txt",
            sample_input,
            fmt="%d",
            header=f"Input: 64 pixels [0-3], Label: {digit_label}",
        )

        # Layer 1 intermediate values
        np.savetxt(
            self.output_dir / f"{prefix}_layer1_acc.txt",
            layer1_acc,
            fmt="%d",
            header="Layer 1: After MAC (before bias)",
        )

        np.savetxt(
            self.output_dir / f"{prefix}_layer1_bias.txt",
            layer1_bias,
            fmt="%d",
            header="Layer 1: After bias (before activation)",
        )

        np.savetxt(
            self.output_dir / f"{prefix}_layer1_act.txt",
            layer1_act,
            fmt="%d",
            header="Layer 1: After activation (sign function)",
        )

        # Layer 2 intermediate values
        np.savetxt(
            self.output_dir / f"{prefix}_layer2_acc.txt",
            layer2_acc,
            fmt="%d",
            header="Layer 2: After MAC (before bias)",
        )

        np.savetxt(
            self.output_dir / f"{prefix}_layer2_logits.txt",
            layer2_logits,
            fmt="%d",
            header="Layer 2: Final logits (after bias)",
        )

        # Final output
        with open(self.output_dir / f"{prefix}_output.txt", "w") as f:
            f.write(f"# Predicted class\n")
            f.write(f"{predicted_class}\n")

        # Metadata
        with open(self.output_dir / f"{prefix}_metadata.txt", "w") as f:
            f.write(f"Test case: {sample_idx}\n")
            f.write(f"True label: {digit_label}\n")
            f.write(f"Predicted: {predicted_class}\n")
            f.write(
                f"Correct: {predicted_class == digit_label if digit_label is not None else 'N/A'}\n"
            )

        return {
            "input": sample_input,
            "layer1_acc": layer1_acc,
            "layer1_bias": layer1_bias,
            "layer1_act": layer1_act,
            "layer2_acc": layer2_acc,
            "layer2_logits": layer2_logits,
            "predicted_class": predicted_class,
            "true_label": digit_label,
        }

    def generate_detailed_trace(self, sample_input, trace_idx=0):
        """
        Generate ultra-detailed trace showing EVERY operation.
        This is for debugging Verilog implementations.
        """
        trace_file = self.output_dir / f"trace_{trace_idx:03d}_detailed.txt"

        with open(trace_file, "w") as f:
            f.write("=" * 80 + "\n")
            f.write(f"DETAILED TRACE - Test Case {trace_idx}\n")
            f.write("=" * 80 + "\n\n")

            f.write("INPUT:\n")
            for i in range(64):
                f.write(f"  input[{i:2d}] = {sample_input[i]}\n")
            f.write("\n")

            # Layer 1 - Show first neuron in detail
            f.write("LAYER 1 - Neuron 0 (detailed):\n")
            f.write("-" * 80 + "\n")
            acc = 0
            for i in range(64):
                weight = self.model.W1[i, 0]
                input_val = sample_input[i]
                product = input_val * weight
                acc += product
                f.write(
                    f"  MAC[{i:2d}]: input={input_val:2d}, weight={weight:2d}, "
                    f"product={product:3d}, acc={acc:4d}\n"
                )

            bias = self.model.b1[0]
            acc_with_bias = acc + bias
            activation = 1 if acc_with_bias >= 0 else -1

            f.write(f"\n  Final accumulator: {acc}\n")
            f.write(f"  Bias: {bias}\n")
            f.write(f"  After bias: {acc_with_bias}\n")
            f.write(f"  After activation: {activation}\n")
            f.write("\n")

            # Layer 1 - Show all neurons summary
            f.write("LAYER 1 - All Neurons Summary:\n")
            f.write("-" * 80 + "\n")
            f.write("  Neuron |   Acc | +Bias |  Act\n")
            f.write("  -------|-------|-------|-----\n")

            layer1_results = []
            for neuron_idx in range(48):
                acc = sum(
                    sample_input[i] * self.model.W1[i, neuron_idx] for i in range(64)
                )
                acc_bias = acc + self.model.b1[neuron_idx]
                act = 1 if acc_bias >= 0 else -1
                layer1_results.append(act)
                f.write(f"  {neuron_idx:6d} | {acc:5d} | {acc_bias:5d} | {act:4d}\n")

            f.write("\n")

            # Layer 2 - Show first neuron in detail
            f.write("LAYER 2 - Neuron 0 (detailed):\n")
            f.write("-" * 80 + "\n")
            acc = 0
            for i in range(48):
                weight = self.model.W2[i, 0]
                input_val = layer1_results[i]
                product = input_val * weight
                acc += product
                f.write(
                    f"  MAC[{i:2d}]: input={input_val:2d}, weight={weight:2d}, "
                    f"product={product:3d}, acc={acc:4d}\n"
                )

            bias = self.model.b2[0]
            logit = acc + bias

            f.write(f"\n  Final accumulator: {acc}\n")
            f.write(f"  Bias: {bias}\n")
            f.write(f"  Final logit: {logit}\n")
            f.write("\n")

            # Layer 2 - All neurons summary
            f.write("LAYER 2 - All Neurons Summary:\n")
            f.write("-" * 80 + "\n")
            f.write("  Neuron |   Acc | +Bias | Logit\n")
            f.write("  -------|-------|-------|------\n")

            logits = []
            for neuron_idx in range(10):
                acc = sum(
                    layer1_results[i] * self.model.W2[i, neuron_idx] for i in range(48)
                )
                logit = acc + self.model.b2[neuron_idx]
                logits.append(logit)
                f.write(
                    f"  {neuron_idx:6d} | {acc:5d} | {self.model.b2[neuron_idx]:5d} | {logit:5d}\n"
                )

            f.write("\n")

            # Argmax
            predicted = np.argmax(logits)
            f.write("ARGMAX:\n")
            f.write("-" * 80 + "\n")
            f.write(f"  Predicted class: {predicted}\n")
            f.write(f"  Logit value: {logits[predicted]}\n")

            f.write("\n" + "=" * 80 + "\n")

        print(f"  ✓ Detailed trace saved to {trace_file}")


def main():
    print("=" * 80)
    print("GOLDEN TEST VECTOR GENERATION")
    print("=" * 80)

    # Load model
    print("\nLoading trained model...")
    model = FinalModel()
    weights_path = Path(__file__).parent.parent.parent / "weights.npz"
    model.load_weights(str(weights_path))

    # Load MNIST test set
    print("\nLoading MNIST test set...")
    x_train, y_train, x_test, y_test = load_mnist()
    x_test_8x8 = downsample_8x8(x_test)
    x_test_2bit = model.quantize_kmeans(x_test_8x8)
    x_test_flat = flatten_images(x_test_2bit)

    # Create generator
    generator = TestVectorGenerator(model)

    # Generate test cases
    print("\n" + "=" * 80)
    print("Generating test vectors...")
    print("=" * 80)

    test_idx = 0

    # 1. One sample from each digit (0-9)
    print("\n1. Generating samples for each digit (0-9)...")
    for digit in range(10):
        # Find first occurrence of this digit
        idx = np.where(y_test == digit)[0][0]
        sample = x_test_flat[idx]
        label = y_test[idx]

        print(f"   Test {test_idx:03d}: Digit {digit} (MNIST index {idx})")
        generator.generate_single_vector(sample, test_idx, label)

        # Generate detailed trace for digit 0
        if digit == 0:
            generator.generate_detailed_trace(sample, test_idx)

        test_idx += 1

    # 2. Random samples
    print("\n2. Generating random samples...")
    np.random.seed(42)
    random_indices = np.random.choice(len(x_test), 90, replace=False)

    for idx in random_indices:
        sample = x_test_flat[idx]
        label = y_test[idx]

        if test_idx % 10 == 0:
            print(f"   Test {test_idx:03d}: Random sample (digit {label})")

        generator.generate_single_vector(sample, test_idx, label)
        test_idx += 1

    # 3. Edge cases
    print("\n3. Generating edge cases...")

    # All zeros (background)
    print(f"   Test {test_idx:03d}: All zeros")
    generator.generate_single_vector(np.zeros(64, dtype=np.int16), test_idx, None)
    test_idx += 1

    # All max values
    print(f"   Test {test_idx:03d}: All max (3)")
    generator.generate_single_vector(np.full(64, 3, dtype=np.int16), test_idx, None)
    test_idx += 1

    # Checkerboard
    print(f"   Test {test_idx:03d}: Checkerboard pattern")
    checkerboard = np.array([i % 2 * 3 for i in range(64)], dtype=np.int16)
    generator.generate_single_vector(checkerboard, test_idx, None)
    test_idx += 1

    # Single hot pixel in center
    print(f"   Test {test_idx:03d}: Single hot pixel")
    single_hot = np.zeros(64, dtype=np.int16)
    single_hot[27] = 3  # Center-ish
    generator.generate_single_vector(single_hot, test_idx, None)
    test_idx += 1

    # Gradient
    print(f"   Test {test_idx:03d}: Gradient pattern")
    gradient = np.array([i // 16 for i in range(64)], dtype=np.int16)
    generator.generate_single_vector(gradient, test_idx, None)
    test_idx += 1

    # Save statistics
    print("\n" + "=" * 80)
    print("BIT WIDTH ANALYSIS")
    print("=" * 80)

    stats_file = generator.output_dir / "bit_widths.txt"
    with open(stats_file, "w") as f:
        f.write("=" * 80 + "\n")
        f.write("BIT WIDTH REQUIREMENTS (from actual test data)\n")
        f.write("=" * 80 + "\n\n")

        for key, bounds in generator.stats.items():
            min_val = bounds["min"]
            max_val = bounds["max"]

            # Calculate bits needed
            min_val = int(min_val)
            max_val = int(max_val)

            if min_val >= 0:
                # Unsigned
                bits_needed = max_val.bit_length()
                signed = "unsigned"
            else:
                # Signed - need to represent both min and max
                bits_for_pos = max_val.bit_length() if max_val > 0 else 0
                bits_for_neg = (abs(min_val) - 1).bit_length() if min_val < 0 else 0
                bits_needed = max(bits_for_pos, bits_for_neg) + 1  # +1 for sign bit
                signed = "signed"

            f.write(f"{key}:\n")
            f.write(f"  Range: [{min_val}, {max_val}]\n")
            f.write(f"  Bits needed: {bits_needed} ({signed})\n")
            f.write(
                f"  Verilog: {'signed ' if signed == 'signed' else ''}[{bits_needed - 1}:0]\n"
            )
            f.write("\n")

            print(
                f"{key:15s}: [{min_val:6d}, {max_val:6d}] → {bits_needed} bits ({signed})"
            )

    print(f"\n✓ Bit width analysis saved to {stats_file}")

    # Summary
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Total test vectors generated: {test_idx}")
    print(f"Output directory: {generator.output_dir}")
    print(f"\nFiles per test case:")
    print(f"  - test_XXX_input.txt           (64 values)")
    print(f"  - test_XXX_layer1_acc.txt      (48 values, before bias)")
    print(f"  - test_XXX_layer1_bias.txt     (48 values, after bias)")
    print(f"  - test_XXX_layer1_act.txt      (48 values, after activation)")
    print(f"  - test_XXX_layer2_acc.txt      (10 values, before bias)")
    print(f"  - test_XXX_layer2_logits.txt   (10 values, final logits)")
    print(f"  - test_XXX_output.txt          (predicted class 0-9)")
    print(f"  - test_XXX_metadata.txt        (test info)")
    print(f"\nSpecial files:")
    print(f"  - trace_000_detailed.txt       (complete operation trace)")
    print(f"  - bit_widths.txt               (Verilog type specifications)")

    print("\n" + "=" * 80)
    print("✓ Golden test vectors ready for Verilog verification!")
    print("=" * 80)


if __name__ == "__main__":
    main()
