module shift_reg #(
    parameter width = 8,
    parameter depth = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic [width-1:0] din,
    output logic [width-1:0] dout
);

logic [width-1:0] reg_array [0:depth-1];

// Stage 0
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) reg_array[0] <= 0;
    else if (en) reg_array[0] <= din;
end

// Stages 1 to depth-1
genvar i;
generate
    for (i = 1; i < depth; i++) begin : shift_stages
        always_ff @(posedge clk) begin
             if (en) reg_array[i] <= reg_array[i-1];
        end
    end
endgenerate

assign dout = reg_array[depth-1];

endmodule