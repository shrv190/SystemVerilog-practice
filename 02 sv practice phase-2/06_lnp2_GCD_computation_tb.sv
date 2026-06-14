// FSMD Finite State Machine with Datapath
// This testbench file with Design file is named as prefix lnp2 means "Learning and practicing 2st design"
// Design an GCD Computation machine
// Below is the datapath given
// Step 1: Input A and B , A and B are 16 bit binary numbers
// Step 2: If A > B then A - B else if A < B then B - A else if A = B then output A/B
// Step 3: Stop

`timescale 1ps/1ps
module gcd_tb;
    reg [15:0] d_in;
    reg start, clk, rst;
    wire done;
    wire [15:0] s_out;

    wire lda, ldb, sel1, sel2, selin, less, grt, eq;

    gcd_datapath gcd_datapath(
        .d_in(d_in), .lda(lda), .ldb(ldb), .sel1(sel1), .sel2(sel2), .selin(selin), .clk(clk), .less(less), .grt(grt), .eq(eq), .s_out(s_out)
        );
    gcd_controlpath gcd_controlpath(
        .lda(lda), .ldb(ldb), .sel1(sel1), .sel2(sel2), .selin(selin), .done(done), .less(less), .grt(grt), .eq(eq), .start(start), .clk(clk), .rst(rst)
        );

    initial begin
        rst = 1'b1; clk = 1'b0; start = 1'b0; d_in = 1'b0;
        #10; rst = 1'b0; start = 1'b1;
    end

    always #5 clk = ~clk;

    initial begin
        @(posedge clk) d_in = 13 ;
        @(posedge clk) d_in = 169;
        @(posedge clk) start = 1'b0;
        wait(done);
        #5; $finish;
    end

    initial begin
        $dumpfile("gcd.vcd");
        $dumpvars(0,gcd_tb);
        $monitor("Time=%4t | Main Input = %d | InputA = %d InputB = %d Output = %d | Start=%b Done=%b", $time, d_in, lda, ldb, s_out, start, done);
    end
endmodule