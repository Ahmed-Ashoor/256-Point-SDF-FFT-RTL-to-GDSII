`timescale 1ns/1ps
`include "transaction.sv"
`include "interface.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "subscriber.sv"
`include "environment.sv"

module test;
bit clk=0;
environment e;

intf phy_intf(clk);


fft_256_top dut (.rst_n(phy_intf.rst_n),.enable(phy_intf.enable),.clk(clk),.din_real(phy_intf.din_real),.din_imag(phy_intf.din_imag),
.dout_real(phy_intf.dout_real),.dout_imag (phy_intf.dout_imag),.valid(phy_intf.valid));

always #5 clk = ~clk;

initial begin
    e = new(phy_intf);
    e.run_environment();
    

    repeat(2) @(posedge clk);
    
    e.s.display_results();
    e.su.display_results();
    $stop;
end

endmodule
