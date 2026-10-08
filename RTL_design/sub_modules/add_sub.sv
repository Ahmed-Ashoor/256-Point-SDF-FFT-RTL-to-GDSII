module add_sub#(
    parameter in_width = 16,
    parameter out_width = 17
) (
    input signed [in_width-1:0] a_real, b_real,a_imag, b_imag,  
    output signed [out_width-1:0] add_real,add_imag,sub_real,sub_imag
);

    assign add_real = a_real + b_real;
    assign add_imag = a_imag + b_imag;
    assign sub_real = a_real - b_real;
    assign sub_imag = a_imag - b_imag;
endmodule