class monitor;
transaction t_mon;
mailbox mon_mail;
virtual intf mon_intf;

function new(virtual intf mon_intf, mailbox mon_mail);
    this.mon_intf = mon_intf;
    this.mon_mail = mon_mail;
endfunction

task run_monitor();
    forever begin
    t_mon = new();
    @(mon_intf.monitor_cb);
    t_mon.enable   = mon_intf.monitor_cb.enable;
    t_mon.din_real = mon_intf.monitor_cb.din_real;
    t_mon.din_imag = mon_intf.monitor_cb.din_imag;
    t_mon.valid    = mon_intf.monitor_cb.valid;
    t_mon.dout_real = mon_intf.monitor_cb.dout_real;
    t_mon.dout_imag = mon_intf.monitor_cb.dout_imag;
    mon_mail.put(t_mon);
    //for debug t_mon.display("monitor");
    end
endtask
endclass