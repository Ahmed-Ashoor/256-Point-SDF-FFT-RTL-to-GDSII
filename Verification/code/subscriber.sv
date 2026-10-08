class subscriber;
    transaction t_sub;
    mailbox score_sub_mail;
    int valid_count;
    covergroup cg_enable;
        cp_enable: coverpoint t_sub.enable {
            bins low  = {0};
            bins high = {1};
        }
    endgroup
    covergroup cg_valid;
        cp_valid: coverpoint t_sub.valid {
            bins low  = {0};
            bins high = {1};
        }
    endgroup
    covergroup cg_din;
        cp_din_real: coverpoint t_sub.din_real {
            bins neg_full = {[-32768:-16384]};
            bins neg_mid  = {[-16383:-1]};
            bins zero     = {0};
            bins pos_mid  = {[1:16383]};
            bins pos_full = {[16384:32767]};
        }
        cp_din_imag: coverpoint t_sub.din_imag {
            bins neg_full = {[-32768:-16384]};
            bins neg_mid  = {[-16383:-1]};
            bins zero     = {0};
            bins pos_mid  = {[1:16383]};
            bins pos_full = {[16384:32767]};
        }
    endgroup
    covergroup cg_dout;
        cp_dout_real: coverpoint t_sub.dout_real {
            bins neg_full = {[-32768:-16384]};
            bins neg_mid  = {[-16383:-1]};
            bins zero     = {0};
            bins pos_mid  = {[1:16383]};
            bins pos_full = {[16384:32767]};
        }
        cp_dout_imag: coverpoint t_sub.dout_imag {
            bins neg_full = {[-32768:-16384]};
            bins neg_mid  = {[-16383:-1]};
            bins zero     = {0};
            bins pos_mid  = {[1:16383]};
            bins pos_full = {[16384:32767]};
        }
    endgroup

    function new(mailbox score_sub_mail);
        this.score_sub_mail = score_sub_mail;
        valid_count    = 0;
        cg_enable = new();
        cg_valid = new();
        cg_din = new();
        cg_dout = new();
    endfunction

    function void display_results();
        $display("subscriber: valid_count=%0d", valid_count);
    endfunction

    task run_subscriber();
        forever begin
            score_sub_mail.get(t_sub);
            cg_enable.sample();
            cg_valid.sample();
            cg_din.sample();
            cg_dout.sample();
            if (t_sub.valid) begin
                valid_count++;
            end
        end
    endtask

endclass