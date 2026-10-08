`timescale 1ns/1ps
interface intf(input bit clk);
  // Signals
  logic rst_n;
  logic enable;
  logic signed [15:0] din_real, din_imag; // q4.12
  
  // Outputs
  logic signed [15:0] dout_real, dout_imag; // q8.8
  logic valid;

  clocking driver_cb @(posedge clk);
    default input #1ns output #1ns;
    output rst_n, enable, din_real, din_imag;
  endclocking

  clocking monitor_cb @(posedge clk);
    default input #1ns output #1ns;
    input rst_n, enable, din_real, din_imag,dout_real, dout_imag,valid;
  endclocking

endinterface

