module ram_p3 (

    input clk,          // Universal clock

    // Port 1
    inout [7:0] data_a,
    input [3:0] address_a,
    input wrre_a,

    // Port 2
    inout [7:0] data_b,
    input [3:0] address_b,
    input wrre_b
);
    reg [7:0] ram [0:15];

    always @(posedge clk) begin
        if(wrre_a) ram[address_a] <= data_a;

        if(wrre_b) ram[address_b] <= data_b;
    end
    assign data_a = (!wrre_a) ? ram[address_a] : 8'bzzzzzzzz;

    assign data_b = (!wrre_b) ? ram[address_b] : 8'bzzzzzzzz;
endmodule

