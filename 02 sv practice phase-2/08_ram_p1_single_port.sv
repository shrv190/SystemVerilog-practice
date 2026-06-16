// Coding Exercise: 8-Word x 4-Bit
// RAMSpecifications:Module Name: practice_ram
// Memory Size: The memory array must hold 8 words, and each word must be 4 bits wide.
// Address Width: Since 2^3 = 8, your addr input line needs to be exactly 3 bits wide ([2:0]).
// Clocking & Control: It must have a clock (clk) and a write-enable (we) signal.
// Synchronous Write: On the rising edge of the clock (posedge clk), if we is high (1), write the incoming 4-bit data (data_in) into the memory array at the specified address (addr).
// Asynchronous Read: Continuously assign the output port (data_out) to display whatever data is inside the memory array at the current address (addr), regardless of the clock.

module ram8in4bit (
    output [3:0] data_out,
    input [2:0] address,
    input [3:0] data_in,
    input read, write, clock
);
    reg [3:0] ram [0:7];

    always @(posedge clock) begin
        if (write) ram[address] <= data_in;
    end

    assign data_out = (read) ? ram[address] : 0;
endmodule


