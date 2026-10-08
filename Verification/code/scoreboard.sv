class scoreboard;
    transaction t_score;
    mailbox score_agnt_mail;
    mailbox score_sub_mail;
    int passed_test_count;
    int failed_test_count;

    localparam N = 1024000;
    reg [15:0] outputs_mem [0:2*N-1];
    int out_idx;

    function new(mailbox score_agnt_mail, mailbox score_sub_mail);
        this.score_agnt_mail = score_agnt_mail;
        this.score_sub_mail  = score_sub_mail;
        passed_test_count = 0;
        failed_test_count = 0;
        out_idx = 0;
        $readmemh("D:/fft_outputs.txt", outputs_mem);
    endfunction

    function void display_results();
        $display("scoreboard: passed tests: %0d, failed tests: %0d", passed_test_count, failed_test_count);
    endfunction

    task run_scoreboard();
        bit signed [15:0] exp_real, exp_imag;

        forever begin
            score_agnt_mail.get(t_score);
            if (t_score.valid) begin
                exp_real = outputs_mem[2*out_idx];//$signed(
                exp_imag = outputs_mem[2*out_idx+1];//$signed(

                if (t_score.dout_real === exp_real && t_score.dout_imag === exp_imag) begin
                    passed_test_count++;
                end else begin
                    failed_test_count++;
                    $display("scoreboard MISMATCH out_idx=%0d: got=(%0d,%0d) expected=(%0d,%0d)",
                    out_idx, t_score.dout_real, t_score.dout_imag, exp_real, exp_imag);
                end
                out_idx++;
            end
            score_sub_mail.put(t_score);
        end
    endtask
endclass
