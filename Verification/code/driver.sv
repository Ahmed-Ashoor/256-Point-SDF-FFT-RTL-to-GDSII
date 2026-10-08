class driver;
transaction t_driv;
mailbox driv_mail;
event driv_handover;
virtual intf driv_intf;

  function new(virtual intf driv_intf, mailbox driv_mail, event driv_handover);
    this.driv_intf = driv_intf;
    this.driv_mail = driv_mail;
    this.driv_handover = driv_handover;
  endfunction

  task run_driver();
    
    forever begin
    t_driv = new();
    driv_mail.get(t_driv);
    @(driv_intf.driver_cb);

    //for debug t_driv.display("driver");
    //load transaction into interface
    driv_intf.driver_cb.rst_n <= t_driv.rst_n;
    driv_intf.driver_cb.enable <= t_driv.enable;
    driv_intf.driver_cb.din_real <= t_driv.din_real;
    driv_intf.driver_cb.din_imag <= t_driv.din_imag;

    ->driv_handover;
    end
  endtask
endclass