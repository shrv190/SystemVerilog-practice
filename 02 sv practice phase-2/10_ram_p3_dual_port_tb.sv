module ram_p3_tb ;
    // Universal clock
    reg clk;

    // Port 1
    wire [7:0] data_a;
    reg [7:0] data_a_in;
    reg [3:0] address_a;
    reg wrre_a;

    // Port 2
    wire [7:0] data_b;
    reg [7:0] data_b_in;
    reg [3:0] address_b;
    reg wrre_b;

    assign data_a = (wrre_a == 1'b1) ? data_a_in : 8'bzzzzzzzz;
    assign data_b = (wrre_b == 1'b1) ? data_b_in : 8'bzzzzzzzz;

    ram_p3 ram(
        .clk(clk), .data_a(data_a), .address_a(address_a), .wrre_a(wrre_a),
        .data_b(data_b), .address_b(address_b), .wrre_b(wrre_b)
    );
    

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        data_a_in = 0; address_a = 0; wrre_a = 0;
        data_b_in = 0; address_b = 0; wrre_b = 0;
        #5;
        @(posedge clk) wrre_a <= 1'b1; address_a <= 1; data_a_in <= 15;
        @(posedge clk) wrre_a <= 1'b1; address_a <= 8; data_a_in <= 30;
        @(posedge clk) wrre_b <= 1'b1; address_b <= 7; data_b_in <= 45;
        @(posedge clk) wrre_b <= 1'b1; address_b <= 6; data_b_in <= 60;
        #1;
        wrre_a <= 0; wrre_b <= 0;
        address_a <= 1;  address_a <= 8;  address_b <= 7;  address_b <= 6;


        data_a_in <= 0; address_a <= 0; wrre_a <= 1; wrre_a <= 0;

        data_b_in <= 0; address_b <= 0; wrre_b <= 1; wrre_b <= 0;

        #50;
        // 1. Write from Port B
        @(posedge clk);
        wrre_b <= 1; address_b <= 7; data_b_in <= 8'hAA;

        // 2. Wait for the write to complete
        @(posedge clk);
        wrre_b <= 0; address_b <= 0; // Release Port B

        // 3. Read from Port A
        @(posedge clk);
        wrre_a <= 0; address_a <= 7; // Request the data written by Port B


        #50 $finish;

    end

    initial begin
        $dumpfile("ramp3.vcd");
        $dumpvars(0,ram_p3_tb);
        $display("Initialisation begins");
        $monitor("Time=%4t || Data A in =%d Sel A =%d Data A out =%d || Data B in =%d Sel B =%d Data B out =%d ", $time, data_a_in, address_a, data_a, data_b_in, address_b, data_b);
    end
endmodule