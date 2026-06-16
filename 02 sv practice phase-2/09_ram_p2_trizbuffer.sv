module ramp2 (
    inout reg [7:0] data,
    input [2:0] addr,
    input clk, read, write
);
    reg [7:0] ram [0:7];
    always @(posedge clk) begin
        if (write == 1'b1) ram[addr] <= data;
    end

    assign data = (read) ? ram[addr] : 8'bzzzzzzzz;
endmodule