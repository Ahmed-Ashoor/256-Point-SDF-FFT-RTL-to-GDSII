class agent;
virtual intf agnt_intf;
mailbox agnt_mail;
//internal
monitor m;
driver d;
generator g;
mailbox g2d_mail;
event g2d_handover;



function new(virtual intf agnt_intf, mailbox agnt_mail);
    this.agnt_mail = agnt_mail;
    this.agnt_intf = agnt_intf;
endfunction

task run_agent();
g2d_mail = new();


m = new(agnt_intf, agnt_mail);
d = new(agnt_intf, g2d_mail, g2d_handover);
g = new(g2d_mail, g2d_handover);

fork
m.run_monitor();
d.run_driver();
g.run_generator();
join_any
endtask
endclass