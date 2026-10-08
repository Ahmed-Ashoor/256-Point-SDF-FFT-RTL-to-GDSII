module mult#(
    parameter in1_width = 8,
    parameter in2_width = 8
) (
    input signed [in1_width-1:0] a_real, a_imag,  
    input signed [in2_width-1:0] b_real, b_imag,   
    output reg signed [in1_width + in2_width - 1:0] out_real, out_imag
);
reg signed [in1_width + in2_width - 1:0] P, Q, R;
reg signed [in1_width:0] sum_a;
reg signed [in2_width:0] sum_b;

    always@(*) begin
        // step 1
        P = a_real * b_real;

        // step 2
        Q = a_imag * b_imag;

        // step 3
        sum_a = a_real + a_imag;
        sum_b = b_real + b_imag;
        R = sum_a * sum_b;

        // result
        out_real = P - Q;
        out_imag = R - P - Q;
    end

endmodule