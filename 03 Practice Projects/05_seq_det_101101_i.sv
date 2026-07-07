// ‼️Today's Problem Statement
// Design a Moore FSM to detect the binary sequence 101101.
// Requirements
// - Support overlapping sequence detection.
// - Assert the output for exactly one clock cycle.
// - Use synchronous reset, synthesizable Verilog only.

// Expected Time: 15 minutes
// Difficulty: Medium

module moore_seq_det_101101 (
    input in, clk, rst,
    output reg out
    );

    localparam s0 = 3'b0, s1 = 3'd1, s2 = 3'd2, s3 = 3'd3, s4 = 3'd4, s5 = 3'd5, s6 = 3'd6, s7 = 3'd7;
    reg [2:0] state, next_state;

    always @(*) begin
        case (state)
        s0 : next_state = (in) ? s1 : s0 ; // 1
        s1 : next_state = (in) ? s1 : s2 ; // 10
        s2 : next_state = (in) ? s3 : s0 ; // 101
        s3 : next_state = (in) ? s4 : s2 ; // 1011
        s4 : next_state = (in) ? s1 : s5 ; // 10110
        s5 : next_state = (in) ? s6 : s0 ; // 101101
        s6 : next_state = (in) ? s4 : s2 ; // 101101?
        default : next_state = s0;
        endcase
    end
    always @(posedge clk) begin
        if (rst) state <= s0 ;
        else state <= next_state ;
    end
    always @(*) begin
        out = (state == s6);
    end
endmodule