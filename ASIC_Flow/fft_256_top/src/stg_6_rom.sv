module s6_rom(
input [1:0] address,
output signed [23:0] tw_real,
output signed [23:0] tw_imag
);
reg signed [47:0] rom [0:3];
initial begin
    $readmemh("stg_6_factors_rom.txt", rom);//use path to rom file
end
assign {tw_real,tw_imag} = rom[address];
endmodule