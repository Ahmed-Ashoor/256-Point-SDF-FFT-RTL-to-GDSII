module counter#(
    parameter max_count = 128
) (
    input clk,
    input rst_n,
    input en,
    output reg [$clog2(max_count)-1:0] count
);
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (en)
            count <= count + 1;
    end
endmodule