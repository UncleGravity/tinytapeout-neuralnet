    // Layer 2 Weight ROM: 480 weights (10 neurons × 48 inputs)
    // Column-major: neuron N weights at addresses [N*48, N*48+47]
    reg [1:0] w2_rom [0:479];
    
    // Layer 2 Bias ROM: 10 biases
    reg [3:0] b2_rom [0:9];
    
    initial begin
        $readmemh("layer2_weights.hex", w2_rom);
        $readmemh("layer2_biases.hex", b2_rom);
    end
