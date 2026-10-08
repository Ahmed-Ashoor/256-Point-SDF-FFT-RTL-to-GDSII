class transaction;
logic rst_n;
logic enable;
logic signed [15:0] din_real,din_imag; //q4.12
logic signed [15:0] dout_real,dout_imag; //q8.8
logic valid;

function void display(input string name = "transaction");
    $display("%s: din_real=%0d, din_imag=%0d, dout_real=%0d, dout_imag=%0d, valid=%0b" ,name, din_real, din_imag, dout_real, dout_imag, valid);
endfunction
endclass