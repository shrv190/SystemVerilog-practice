// FSMD Finite State Machine with Datapath
// This Design file with testbench file is named as prefix lnp2 means "Learning and practicing 2st design"
// Design an GCD Computation machine
// Below is the datapath given
// Step 1: Input A and B , A and B are 16 bit binary numbers
// Step 2: If A > B then A - B else if A < B then B - A else if A = B then output A/B
// Step 3: Stop

module PIPO (
    output reg [15:0] d_out,
    input [15:0] d_in,
    input ld, clk
);
    always @(posedge clk) begin
        if (ld) d_out <= d_in;
    end
endmodule

module mux(
    output [15:0] out,
    input [15:0] in1,in2,
    input sel
    );
    assign out = sel ? in1 : in2;
endmodule

module subtractor (
    output reg [15:0] out,
    input [15:0] in1, in2
);
    always @(*) out = in1 - in2;
endmodule

module comparator (
    output less,grt, eq,
    input [15:0] in1, in2
);
    assign less = (in1 < in2);
    assign grt = (in1 > in2);
    assign eq = (in1 == in2);
endmodule

module gcd_datapath(
    input [15:0] d_in,
    input lda, ldb, sel1, sel2, selin, clk,
    output less, grt, eq,
    output [15:0] s_out
);

    wire [15:0] a_out, b_out, x, y, bus;

    mux m1(x, a_out, b_out, sel1);
    mux m2(y, a_out, b_out, sel2);
    mux min(bus, d_in, s_out, selin);
    PIPO a(a_out, bus, lda, clk);
    PIPO b(b_out, bus, ldb, clk);
    subtractor sub(s_out, x, y);
    comparator compare(less, grt, eq, a_out, b_out);
endmodule

module gcd_controlpath(
    output reg lda, ldb, sel1, sel2, selin, done,
    input less, grt, eq, start, clk, rst
);
    reg [2:0] state;
    parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4, S5 = 3'd5;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= S0;
        else begin
            case (state)
                S0 : begin if (start) state <= S1;
                           else       state <= S0;
                end
                S1 : state <= S2;
                S2 : begin
                    if      (less) state <= S3;
                    else if (grt) state <= S4;
                    else if (eq) state <= S5;
                end
                S3 : begin
                    if      (less) state <= S3;
                    else if (grt) state <= S4;
                    else if (eq) state <= S5;
                end
                S4 : begin
                    if      (less) state <= S3;
                    else if (grt) state <= S4;
                    else if (eq) state <= S5;
                end
                S5 : state <= S5;
                default: state <= S0;
            endcase
        end
    end

    always @(*) begin
        lda = 1'b0; ldb = 1'b0; sel1 = 1'b0;  sel2 = 1'b0; selin = 1'b0; done = 1'b0;

        case (state)
            S0 : begin
                selin = 1'b1; lda = 1'b1;
            end
            S1 : begin
                selin = 1'b1; lda = 1'b0; ldb = 1'b1;
            end
            S2, S3, S4 : begin
                if      (less) begin sel2 = 1'b1; lda = 1'b0; ldb = 1'b1; end
                else if (grt ) begin sel1 = 1'b1; lda = 1'b1; ldb = 1'b0; end
                else if (eq  ) begin done = 1'b1; end
            end
            S5 : begin done = 1'b1; end
            default: begin
                    lda = 1'b0; ldb = 1'b0; sel1 = 1'b0;  sel2 = 1'b0; selin = 1'b0; done = 1'b0;
                end
        endcase
    end
endmodule