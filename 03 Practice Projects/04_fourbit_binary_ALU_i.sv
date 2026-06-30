//==============================================================================
// Company:        Your Company / University Name
// Designer:       https://github.com/dir190 or https://www.linkedin.com/in/dir190/
// 
// Design Name:    Four bit binary ALU
// Module Name:    alu_4bit
// Project Name:   Multi functional ALU
//
// Description:    A synchronous ALU with possible gate level modelling which can perform
//                  > addition (Using Ripple carry adder - RCAs),
//                  > subtraction (Using Ripple carry adder - RCAs),
//                  > multiplication (Using Booth's multiplication algorithm),
//                  > division (Using Non restoring division algorithm)
//                 with active-high asynchronous reset.
//==============================================================================

// Learnt / What's optimised code
// Introduced a "sub_cont" input which can be used to handle addition and subtraction using only one module


module alu (
    input [3:0] in1, in2,
    input start, clk, rst, restart,
    input [1:0] sel,
    output reg [9:0] out,
    output reg [3:0] remcarry,
    output reg done
    );
    wire donemul, donediv;
    wire [3:0] outw_addsub;
    wire [9:0] outw_mul;
    wire carryw;
    wire [3:0] quot, remw;

    wire sub_cont = (sel == 2'b01);
    four_bit_fulladdersubtractor addersubt(outw_addsub, carryw, in1, in2, sub_cont);

    boothmul multiplier(in1, in2, start, clk, rst, restart, outw_mul, donemul);
    non_restoring_divider divider(in1, in2, start, clk, rst, restart, quot, remw, donediv);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 0;
            remcarry <= 0;
        end else if (start) begin
            case (sel)
                2'b00: begin
                    out <= {5'b0,carryw,outw_addsub};
                    remcarry <= carryw;
                end
                2'b01: begin
                    out <= {6'b0,outw_addsub};
                    remcarry <= 1'bx;
                end
                2'b10: begin
                    out <= outw_mul;
                    done <= donemul;
                    remcarry <= 1'bx;
                end
                2'b11: begin
                    out <= {6'b0,quot};
                    remcarry <= remw;
                    done <= donediv;
                end
            endcase
        end
    end
endmodule

// One bit adder using NAND Gates
module one_bit_adder (
    output sum, carry,
    input a, b, cin
    );
    wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;

    // Sum Logic

        // A XOR B
    nand(w1, a, b);
    nand(w2, a, w1);
    nand(w3, w1, b);
    nand(w4, w2, w3);

        // A XOR B XOR Cin == Sum
    nand(w5, w4, cin);
    nand(w6, w4, w5);
    nand(w7, w5, cin);
    nand(sum, w6, w7);

    // Carry logic -- final polishing
    nand(w8, a, b);
    nand(w10, cin, w4);
    nand(carry, w8, w10);

endmodule

// ================================
// Adder/subtractor module
// ================================

// for adder, sub_cont = 0
// for subtractor, sub_cont = 1
module four_bit_fulladdersubtractor (
    output [3:0] sum,
    output carry,
    input [3:0] a, b,
    input sub_cont
    );
    wire [3:0] sumw;
    wire [3:0] cw, bx;

    xor x0 (bx[0], b[0], sub_cont);
    xor x1 (bx[1], b[1], sub_cont);
    xor x2 (bx[2], b[2], sub_cont);
    xor x3 (bx[3], b[3], sub_cont);

    one_bit_adder adder1(sumw[0], cw[0], a[0], bx[0], sub_cont);
    one_bit_adder adder2(sumw[1], cw[1], a[1], bx[1], cw[0]);
    one_bit_adder adder3(sumw[2], cw[2], a[2], bx[2], cw[1]);
    one_bit_adder adder4(sumw[3], carry, a[3], bx[3], cw[2]);

    assign sum = sumw;
endmodule

// ====================================
// Declaring Helper module for Booth's Multiplier moduloe
// ====================================

module mux2in1 (
    output out,
    input sel,
    input in1, in2
    );
    wire w1, w2, w3, w4, w5, w6, w7;

    nand(w1, sel, sel);
    nand(w2, in1, w1);
    nand(w3 ,sel, in2);
    nand(out, w3, w2);
endmodule

// ================================
// Multiplier module
// ================================

module boothmul (
    input [3:0] in1, in2,
    input start, clk, rst, restart,
    output reg [9:0] mul,
    output reg done
    );
    wire [4:0] matheval, upcom_tval;
    wire sub_cont, carry;
    reg [2:0] counter;
    reg [4:0] t, a, b;
    reg bn;

    // if b[0] and bn is 10 then sub count is 1 -->> sub fn
    // if b[0] and bn is 01 then sub count is 0 -->> add fn
    assign sub_cont = b[0] & ~bn;

    four_bit_fulladdersubtractor addsub(matheval[3:0], carry, t[3:0], a[3:0], sub_cont);

    // Calculating 1 to 4th bit of upcoming value of t
    generate
        genvar i;
        for (i=0; i<4; i=i+1) begin
            mux2in1 mux(upcom_tval[i], (b[0] ^ bn), t[i], matheval[i]);
        end   
    endgenerate

    // Calculating 5th bit of upcoming value of t
    assign matheval[4] = t[4] ^ (a[4] ^ sub_cont) ^ carry;
    mux2in1 m4(upcom_tval[4], (b[0] ^ bn), t[4], matheval[4]);

    reg [1:0] state;
    localparam s_init = 2'b00, s_proc = 2'b01, s_done = 2'b10;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mul <= 0;
            done <= 0;
            t <= 0;
            a <= 0;
            b <= 0;
            counter <=3'd5;
            bn <= 0;
            state <= s_init;
        end
        else case (state) 
            s_init: begin
                if (start) begin
                    mul <= 0;
                    done <= 0;
                    t <= 0;
                    a <= {1'b0,in1[3:0]};
                    b <= {1'b0,in2[3:0]};
                    counter <=3'd5;
                    bn <= 0;
                    state <= s_proc;
                end
            end
            s_proc: begin
                if (counter > 0 ) begin
                    bn <= b[0];
                    b <= {upcom_tval[0],b[4:1]};
                    t <= {upcom_tval[4],upcom_tval[4:1]};
                    counter <= counter - 1;
                end
                else state <= s_done;
            end
            s_done: begin
               done <= 1'b1;
               mul <= {t,b};
                if (restart) state <= s_init;
                else         state <= s_done;
            end
            default: state <= s_init;
        endcase
    end
endmodule

// ================================
//  Divider module
// ================================

module non_restoring_divider (
    input [3:0] divdt, divsr,
    input start, clk, rst, restart,
    output reg [3:0] quot, rem,
    output reg done
    );
    reg [4:0] acc, b;
    reg [3:0] a;
    reg [1:0] counter, state;

    wire [4:0] matheval;
    wire carry;
    wire sub_cont = (state == s_eval) ? !acc[4] : 1'b0;
    localparam s_init = 2'b00, s_eval = 2'b01, s_done = 2'b10;

    wire [4:0] addsub_in = (state == s_eval) ? {acc[3:0], a[3]} : acc;
    four_bit_fulladdersubtractor addsub(matheval[3:0], carry, addsub_in[3:0], b[3:0], sub_cont);

    wire bxor = b[4] ^ sub_cont;
    assign matheval[4] = addsub_in[4] ^ bxor ^ carry;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            quot <= 0;
            rem <= 0;
            done <= 0;
            acc <= 0;
            a <= 0;
            b <= 0;
            counter <= 2'd3;
            state <= s_init;
        end 
        else case (state)
        s_init: begin
            if (start) begin
                quot <= 0;
                rem <= 0;
                done <= 0;
                acc <= 0;
                a <= divdt;
                b <= {1'b0,divsr};
                counter <= 2'd3;
                state <= s_eval;
            end 
            else state <= s_init;
        end
        s_eval: begin
            acc <= matheval;
            a <= {a[2:0], !matheval[4]};
            counter <= counter - 1;

            if(counter == 2'd0) state <= s_done;
            else state <= s_eval;
        end
        s_done:begin
            rem <= (acc[4]) ? matheval[3:0] : acc[3:0];
            quot <= a;
            done <= 1'b1;
            
            if (restart) state <= s_init;
        end
        default: state <= s_init;
        endcase
    end
endmodule