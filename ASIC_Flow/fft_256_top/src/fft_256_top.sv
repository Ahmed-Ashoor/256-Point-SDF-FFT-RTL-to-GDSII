module fft_256_top(
    input rst_n,
    input enable,
    input clk,
    input signed [15:0] din_real,din_imag, //q4.12
    output signed [15:0] dout_real,dout_imag, //q8.8
    output valid
);
wire signed [23:0] stg_1_real,stg_1_imag;//q4.20
wire signed [23:0] stg_2_real,stg_2_imag;//q5.19
wire signed [23:0] stg_3_real,stg_3_imag;//q5.19
wire signed [23:0] stg_4_real,stg_4_imag;//q6.18
wire signed [23:0] stg_5_real,stg_5_imag;//q6.18
wire signed [23:0] stg_6_real,stg_6_imag;//q7.17
wire signed [23:0] stg_7_real,stg_7_imag;//q7.17
reg [7:0] c;//counter for stages
reg valid_r,enable_ff;
// the output of stage 8 is dout
wire e1,e2,e3,e4,e5,e6,e7;
wire [47:0] s1,s2,s3,s4,s5,s6,s7;
wire [7:0] c1,c2,c3,c4,c5,c6,c7;

stg_1 stg_1_inst(.clk(clk),.rst_n(rst_n),.cont(c[7]),.enable(enable),.din_real(din_real),
.din_imag(din_imag),.dout_real(stg_1_real),.dout_imag(stg_1_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_1 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({enable,c,stg_1_real,stg_1_imag}),.dout({e1,c1,s1}));

stg_2 stg_2_inst(.clk(clk),.rst_n(rst_n),.cont(c1[6]),.enable(e1),.din_real(s1[47:24]),
.din_imag(s1[23:0]),.dout_real(stg_2_real),.dout_imag(stg_2_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_2 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({e1,c1,stg_2_real,stg_2_imag}),.dout({e2,c2,s2}));

stg_3 stg_3_inst(.clk(clk),.rst_n(rst_n),.cont(c2[5]),.enable(e2),.din_real(s2[47:24]),
.din_imag(s2[23:0]),.dout_real(stg_3_real),.dout_imag(stg_3_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_3 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({e2,c2,stg_3_real,stg_3_imag}),.dout({e3,c3,s3}));

stg_4 stg_4_inst(.clk(clk),.rst_n(rst_n),.cont(c3[4]),.enable(e3),.din_real(s3[47:24]),
.din_imag(s3[23:0]),.dout_real(stg_4_real),.dout_imag(stg_4_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_4 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({e3,c3,stg_4_real,stg_4_imag}),.dout({e4,c4,s4}));

stg_5 stg_5_inst(.clk(clk),.rst_n(rst_n),.cont(c4[3]),.enable(e4),.din_real(s4[47:24]),
.din_imag(s4[23:0]),.dout_real(stg_5_real),.dout_imag(stg_5_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_5 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({e4,c4,stg_5_real,stg_5_imag}),.dout({e5,c5,s5}));

stg_6 stg_6_inst(.clk(clk),.rst_n(rst_n),.cont(c5[2]),.enable(e5),.din_real(s5[47:24]),
.din_imag(s5[23:0]),.dout_real(stg_6_real),.dout_imag(stg_6_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_6 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({e5,c5,stg_6_real,stg_6_imag}),.dout({e6,c6,s6}));

stg_7 stg_7_inst(.clk(clk),.rst_n(rst_n),.cont(c6[1]),.enable(e6),.din_real(s6[47:24]),
.din_imag(s6[23:0]),.dout_real(stg_7_real),.dout_imag(stg_7_imag));

shift_reg #(.width(57), .depth(1)) pipe_reg_7 (.clk(clk),.rst_n(rst_n),.en(enable),
    .din({e6,c6,stg_7_real,stg_7_imag}),.dout({e7,c7,s7}));

stg_8 stg_8_inst(.clk(clk),.rst_n(rst_n),.cont(c7[0]),.enable(e7),.din_real(s7[47:24]),
.din_imag(s7[23:0]),.dout_real(dout_real),.dout_imag(dout_imag));

//cont is a counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        c <= 0;
    else if(enable_ff)
        c <= c + 1;
    else
        c <= c;
end

//valid logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        valid_r <= 1'b0;
    else if (enable && c7 == 8'd254)
        valid_r <= 1'b1;
end
assign valid = valid_r && enable_ff;

//enable delay flip flop for the counter to get count=0
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        enable_ff <= 0;
    else
        enable_ff <= enable;
end

endmodule