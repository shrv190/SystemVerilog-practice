`timescale 1ps/1ps
module regbank_p1_tb ;
    reg [4:0] port1, port2, port3;
    wire [31:0] readport1, readport2;
    reg write, clk, rst;
    reg [31:0] writeport3;
    integer k ;

    regbank_p1 regbank (.port1(port1), .port2(port2), .port3(port3), .readport1(readport1), .readport2(readport2), .write(write), .clk(clk), .rst(rst), .writeport3(writeport3));

    initial begin
        port1 = 0; port2=0; port3 = 1'bx; write = 0; clk= 0 ; rst = 0; writeport3 = 1'bx;
        #5;
        @(posedge clk) rst <= 1; #5; @(posedge clk)rst <= 0;

        #12; write = 1;
        for(k=0; k<32; k=k+1) begin
            @(posedge clk) port3 <= k; writeport3 <= k;
        end

        @(posedge clk); #15; port3 <= 0; write <= 0; writeport3 <= 0;

        for(k=0; k<17; k=k+1) begin
            @(posedge clk) port1 <= k;
            @(posedge clk)
            $display("%4t Port%3d || Reading%d",$time, port1,readport1);

            @(posedge clk) port2 <= k+15;
            @(posedge clk)
            $display("%4t Port%3d || Reading%d",$time, port2,readport2);
        end

        #20;
        $finish;
    end
    always #5 clk = ~clk;
    initial begin
        $dumpfile("regbank.vcd");
        $dumpvars(0,regbank_p1_tb);
    end
endmodule