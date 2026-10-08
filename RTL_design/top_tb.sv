`timescale 1ns/1ps

module tb_fft_256_top;

    //parameters
    localparam N          = 256;
    localparam FLUSH      = N - 1+7;                
    localparam TOTAL_IN   = N + FLUSH;              
    localparam string INPUT_FILE  = "D:/fft_inputs.txt";
    localparam string OUTPUT_FILE = "D:/fft_outputs.txt";


    //clk
    logic clk = 0;
    logic rst_n;
    always #5 clk = ~clk;   // 100 MHz

    logic enable;
    logic signed [15:0] din_real, din_imag;
    wire  signed [15:0] dout_real, dout_imag;
    wire  valid;

    
    fft_256_top dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .enable    (enable),
        .din_real  (din_real),
        .din_imag  (din_imag),
        .dout_real (dout_real),
        .dout_imag (dout_imag),
        .valid     (valid)
    );

    
    // $readmemh fills sequentially regardless of line breaks, so a
    // "real imag" per line hex file loads cleanly into a flat array:
    // mem[0]=real(0), mem[1]=imag(0), mem[2]=real(1), ...
    reg [15:0] in_mem  [0:2*N-1];
    reg [15:0] out_mem [0:2*N-1];

    initial begin
        $readmemh(INPUT_FILE,  in_mem);
        $readmemh(OUTPUT_FILE, out_mem);
    end

    logic signed [15:0] captured_real [$];
    logic signed [15:0] captured_imag [$];

    integer i;
    integer errors = 0;
    integer mismatches_shown = 0;

    initial begin
        rst_n   = 0;
        enable  = 0;
        din_real = 0;
        din_imag = 0;

        repeat (5) @(posedge clk);
        rst_n = 1;
        #1 enable = 1;
        @(posedge clk);

        for (i = 0; i < TOTAL_IN; i = i + 1) begin
            if (i < N) begin
                din_real = in_mem[2*i];
                din_imag = in_mem[2*i+1];
            end else begin
                din_real = 16'sd0;   // flush padding, discarded downstream
                din_imag = 16'sd0;
            end

            @(negedge clk);

            if (valid) begin
                captured_real.push_back(dout_real);
                captured_imag.push_back(dout_imag);
            end
            @(posedge clk);
        end

        // Keep clocking a little longer in case any trailing valid
        // samples are still emerging after the stimulus loop ends.
        while (captured_real.size() < N) begin
            @(negedge clk);
            if (valid) begin
                captured_real.push_back(dout_real);
                captured_imag.push_back(dout_imag);
            end
        end

        // ================= SELF-CHECK =================
        if (captured_real.size() != N)
            $display("WARNING: captured %0d samples, expected %0d", captured_real.size(), N);

        for (i = 0; i < N; i = i + 1) begin
            logic signed [15:0] exp_real, exp_imag;
            exp_real = out_mem[2*i];
            exp_imag = out_mem[2*i+1];

            if (captured_real[i] !== exp_real || captured_imag[i] !== exp_imag) begin
                errors = errors + 1;
                if (mismatches_shown < 2000) begin   // cap console spam
                    $display("MISMATCH idx=%0d: got=(%0d,%0d) expected=(%0d,%0d)",
                               i, captured_real[i], captured_imag[i], exp_real, exp_imag);
                    mismatches_shown = mismatches_shown + 1;
                end
            end
        end

        if (errors == 0)
            $display("TEST PASSED: all %0d output samples matched the reference file exactly.", N);
        else begin
            $display("TEST FAILED: %0d / %0d samples mismatched.", errors, N);
        end

        $stop;
    end

endmodule