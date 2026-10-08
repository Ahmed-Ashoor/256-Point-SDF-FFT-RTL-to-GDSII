class generator;
    transaction t_gen;
    int iterations;
    mailbox gen_mail;
    event gen_handover;

    localparam NUM_SAMPLES = 1024000;
    reg [15:0] in_mem [0:2*NUM_SAMPLES-1]; //because they have spaces in between :,(

    function new(mailbox gen_mail, event gen_handover);
        this.gen_mail = gen_mail;
        this.gen_handover = gen_handover;
        $readmemh("D:/fft_inputs.txt", in_mem);
    endfunction

    task run_generator();
        iterations = NUM_SAMPLES + 2;   // 2 reset and idle cycles + all samples

        for (int i = 1; i <= (iterations + 254); i++) begin // 255 extra cycles to flush the last sample through the pipeline
            t_gen = new();
            if (i == 1) begin
                //reset
                t_gen.rst_n    = 0;
                t_gen.enable   = 0;
                t_gen.din_real = 0;
                t_gen.din_imag = 0;
            end
            else if (i == 2) begin
                //remove reset
                t_gen.rst_n    = 1;
                t_gen.enable   = 1;
                t_gen.din_real = 0;
                t_gen.din_imag = 0;
            end
            else if ((i - 3) < NUM_SAMPLES) begin
            // real MATLAB-driven samples
            t_gen.rst_n    = 1;
            t_gen.enable   = 1;
            t_gen.din_real = in_mem[2*(i-3)];
            t_gen.din_imag = in_mem[2*(i-3)+1];
            end
            else begin
            // flush -- pipeline drain, no more real data to read
            t_gen.rst_n    = 1;
            t_gen.enable   = 1;
            t_gen.din_real = 0;
            t_gen.din_imag = 0;
            end

            gen_mail.put(t_gen);
            @(gen_handover);
        end

        //last stop packet
        t_gen.rst_n    = 1;
        t_gen.enable   = 0;
        t_gen.din_real = 0;
        t_gen.din_imag = 0;
        gen_mail.put(t_gen);
        @(gen_handover);
    endtask
endclass