module s3_rom(
input [4:0] address,
output signed [23:0] tw_real,
output signed [23:0] tw_imag
);
reg signed [47:0] rom [0:31];
initial begin
    $readmemh("stg_3_factors_rom.txt", rom);//use path to rom file
end
assign {tw_real,tw_imag} = rom[address];
endmodule