// Instantiate your ram8in4bit module inside it.
// Create a clock generator that toggles every 5 time units.
// In an initial block, do the following step-by-step:
// Step A: Turn on write, set address to 3'd5, and set data_in to 4'b1010. Wait for one clock edge.
// Step B: Turn off write (set it to 0).
// Step C: Change address to 3'd5 to see if data_out instantly reads back your 4'b1010.

module ram8in4bit_tb;
    wire [3:0] data_out;
    reg [2:0] address;
    reg [3:0] data_in;
    reg read, write, clock;

    ram8in4bit ram(
        .data_out(data_out), .data_in(data_in), .address(address), .read(read), .write(write), .clock(clock)
    );
    
    always #5 clock = ~ clock;
    initial begin
        clock=0; read = 0; address=0; data_in= 0; write = 0;
        #5;
        @(posedge clock) write = 1'b1; address = 3'd5; data_in=4'd10;
        @(posedge clock) write <= 1'b0; address <= 3'd5; read <= 1'b1;
        #50; $finish;
    end

    initial begin
        $dumpfile("ramp1.vcd");
        $dumpvars(0, ram8in4bit_tb);
    end

endmodule