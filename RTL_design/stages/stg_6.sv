module stg_6(
    input clk,rst_n,cont,enable,
    input signed [23:0] din_real, din_imag,//q6.18
    output signed [23:0] dout_real, dout_imag//q7.17
);
reg enable_ff ;
wire signed [24:0] add_real, add_imag, sub_real, sub_imag;
wire signed [24:0] shift_dout_real, shift_dout_imag;
wire signed [48:0] mult_real, mult_imag;
wire [$clog2(4)-1:0] count;
wire signed [23:0] tw_real, tw_imag;
wire signed [49:0] shift_din; //q7.18*2

add_sub #(.in_width(24), .out_width(25)) add_sub_inst (
    .a_real(shift_dout_real[23:0]),
    .a_imag(shift_dout_imag[23:0]),
    .b_real(din_real),
    .b_imag(din_imag),
    .add_real(add_real),
    .add_imag(add_imag),
    .sub_real(sub_real),
    .sub_imag(sub_imag)
);//outputs q7.18

shift_reg #(.width(50), .depth(4)) shift_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(enable),
    .din(shift_din), //q7.18*2
    .dout({shift_dout_real, shift_dout_imag}) //q7.18*2
);//outputs q7.18 pairs
//muxs
assign shift_din = (cont)? {sub_real,sub_imag} : {din_real[23],din_real,din_imag[23],din_imag};

assign dout_real = (cont)? add_real[24:1] : mult_real[46:23];//q7.17
assign dout_imag = (cont)? add_imag[24:1] : mult_imag[46:23];//q7.17


mult #(.in1_width(25), .in2_width(24)) mult_inst (
    .a_real(shift_dout_real),//q7.18
    .a_imag(shift_dout_imag),
    .b_real(tw_real),//q2.22
    .b_imag(tw_imag),
    .out_real(mult_real),
    .out_imag(mult_imag)
);//outputs q9.40


counter #(.max_count(4)) counter_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en((enable_ff&&(!cont))),
    .count(count)
);
s6_rom s6_rom_inst (
    .address(count),
    .tw_real(tw_real),
    .tw_imag(tw_imag)
);

//enable delay flip flop for the counter to get count=0
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        enable_ff <= 0;
    else
        enable_ff <= enable;
end
endmodule