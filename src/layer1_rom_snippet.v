    // Layer 1 Weight ROM: 3,072 weights (48 neurons × 64 inputs)
    // Column-major: neuron N weights at addresses [N*64, N*64+63]
    reg [1:0] w1_rom [0:3071];
    
    // Layer 1 Bias ROM: 48 biases
    reg [3:0] b1_rom [0:47];
    
    initial begin
        $readmemh("layer1_weights.hex", w1_rom);
        $readmemh("layer1_biases.hex", b1_rom);
    end
