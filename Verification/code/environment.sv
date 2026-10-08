class environment;
virtual intf env_intf;
//internal
agent a;
scoreboard s;
subscriber su;
mailbox a2s_mail;
mailbox s2su_mail;

function new(virtual intf vif);
    this.env_intf = vif;
endfunction

task run_environment();
a2s_mail = new();
s2su_mail = new();

a = new(env_intf, a2s_mail);
s = new(a2s_mail, s2su_mail);
su = new(s2su_mail);

fork
a.run_agent();
s.run_scoreboard();
su.run_subscriber();
join_any

endtask
endclass