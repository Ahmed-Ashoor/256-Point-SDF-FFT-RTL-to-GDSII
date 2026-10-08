module stg_8(
    input clk,rst_n,cont,enable,
    input signed [23:0] din_real, din_imag,//q7.17
    output signed [15:0] dout_real, dout_imag//q8.16 ->q8.8
);
wire signed [24:0] add_real, add_imag, sub_real, sub_imag;
wire signed [24:0] shift_dout_real, shift_dout_imag;
wire signed [49:0] shift_din; //q8.17*2

add_sub #(.in_width(24), .out_width(25)) add_sub_inst (
    .a_real(shift_dout_real[23:0]),
    .a_imag(shift_dout_imag[23:0]),
    .b_real(din_real),
    .b_imag(din_imag),
    .add_real(add_real),
    .add_imag(add_imag),
    .sub_real(sub_real),
    .sub_imag(sub_imag)
);//outputs q8.17

shift_reg #(.width(50), .depth(1)) shift_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(enable),
    .din(shift_din), //q8.17*2
    .dout({shift_dout_real, shift_dout_imag}) //q8.17*2
);//outputs q8.17 pairs
//muxs
assign shift_din = (cont)? {sub_real,sub_imag} : {din_real[23],din_real,din_imag[23],din_imag};

assign dout_real = (cont)? add_real[24:9] : shift_dout_real[24:9];//q8.16->q8.8
assign dout_imag = (cont)? add_imag[24:9] : shift_dout_imag[24:9];//q8.16->q8.8

endmodule