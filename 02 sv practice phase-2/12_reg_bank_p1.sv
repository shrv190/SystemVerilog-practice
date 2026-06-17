module regbank_p1 (
    input [4:0] port1, port2, port3,
    output [31:0] readport1, readport2,
    input write, clk, rst,
    input [31:0] writeport3
);
    reg [31:0] reg_bank [0:31];
    assign readport1 = reg_bank[port1];
    assign readport2 = reg_bank[port2];
integer k;
    always @(posedge clk) begin
        if (rst) begin
            for (k=0; k < 32; k++ ) begin
                reg_bank[k] <= 32'b0;
            end
        end
        else begin 
            if (write) reg_bank[port3] <= writeport3;
        end
    end
endmodule