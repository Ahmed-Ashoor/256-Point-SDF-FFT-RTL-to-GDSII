module stg_1(
    input clk,rst_n,cont,enable,
    input signed [15:0] din_real, din_imag,//q4.12
    output signed [23:0] dout_real, dout_imag//4.20
);
reg enable_ff ;
wire signed [15:0] add_real, add_imag, sub_real, sub_imag;
wire signed [15:0] shift_dout_real, shift_dout_imag;
wire signed [39:0] mult_real, mult_imag;
wire [$clog2(128)-1:0] count;
wire signed [23:0] tw_real, tw_imag;
wire signed [31:0] shift_din; //q4.12

add_sub #(.in_width(16), .out_width(16)) add_sub_inst (
    .a_real(shift_dout_real),
    .a_imag(shift_dout_imag),
    .b_real(din_real),
    .b_imag(din_imag),
    .add_real(add_real),
    .add_imag(add_imag),
    .sub_real(sub_real),
    .sub_imag(sub_imag)
);//outputs q4.12

shift_reg #(.width(32), .depth(128)) shift_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(enable),
    .din(shift_din), //q4.12 
    .dout({shift_dout_real, shift_dout_imag}) //q4.12
);//outputs q4.12
//muxs
assign shift_din = (cont)? {sub_real,sub_imag} : {din_real,din_imag};

assign dout_real = (cont)? {add_real,8'b0} : mult_real[37:14];//q4.20
assign dout_imag = (cont)? {add_imag,8'b0} : mult_imag[37:14];//q4.20


mult #(.in1_width(16), .in2_width(24)) mult_inst (
    .a_real(shift_dout_real),//q4.12
    .a_imag(shift_dout_imag),
    .b_real(tw_real),//q2.22
    .b_imag(tw_imag),
    .out_real(mult_real),
    .out_imag(mult_imag)
);//outputs q6.34


counter #(.max_count(128)) counter_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en((enable_ff&&(!cont))),
    .count(count)
);
s1_rom s1_rom_inst (
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