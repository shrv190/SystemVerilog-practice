// This is a RAM of Variable address and variable data input length
// Calculate memory size from addr_size mem_size and data_size
// 2^addr_size * data_size
// OR
// data_size * mem_size
// To easy view the memory size in bytes, take a extra 3 addr_size.
// To easy view the memory size in Kilobytes, take a extra 10+3 addr_size.

// ==============================================================
// The below data size taken is in KiB (Kilobytes)
// ===============================================================


module ram_variable_size #(
    parameter d_size = 13,         // Data size is in KiB as 2^3 = 1Byte =>> 2^10 = 1KiB
    // parameter d_size = 23,         // Data size is in MiB as 2^3 = 1Byte =>> 2^10 = 1KiB =>> 2^10 = 1MiB
    parameter addr_size = 13       // 13 x 1KiB = 13 KiB
)(
    input clk, write,
    input [addr_size-1:0] address,
    input [d_size - 1:0] d_in,
    output reg [d_size - 1:0] d_out
);
    reg [d_size-1:0] ram [0:(1 << addr_size )-1];

    always @(posedge clk) begin
        if (write) ram[address] <= d_in;
        else d_out <= ram[address];
    end
endmodule