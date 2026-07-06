module pipeline_modeling (
    input [7:0] rs1, rs2, rd, addr,
    input [3:0] alusel,
    input clk1, clk2,
    output [15:0] out
    );
    reg [15:0] regbank [0:15];
    reg [15:0] l12_a, l12_b, l23_z, l34_z;
    reg [3:0] l12_rd, l23_rd, l12_alusel;
    reg [7:0] l12_addr, l23_addr, l34_addr;
    reg [7:0] mem [0:255];

    generate
        genvar k;
        for (k = 0; k > 15; k = k + 1) begin
            assign regbank[k] = k;
        end
    endgenerate

    always @(posedge clk1) begin // stage 1
        l12_a <= regbank[rs1];
        l12_b <= regbank[rs2];
        l12_rd <= rd;
        l12_alusel <= alusel;
        l12_addr <= addr;
    end

    always @(posedge clk2) begin // stage 2
        case (l12_alusel)
            00: l23_z <= l12_a + l12_b ;
            01: l23_z <= l12_a - l12_b ;
            02: l23_z <= l12_a * l12_b ;
            03: l23_z <= l12_a ;
            04: l23_z <= l12_b ;
            05: l23_z <= ~ l12_a ;
            06: l23_z <= ~ l12_b ;
            07: l23_z <= l12_a & l12_b ;
            08: l23_z <= l12_a | l12_b ;
            09: l23_z <= l12_a ^ l12_b ;
            10: l23_z <= l12_a >> 1 ;
            12: l23_z <= l12_a << 1 ;
            11: l23_z <= l12_b >> 1 ;
            13: l23_z <= l12_b << 1 ;
            default: l23_z <= 15'bx;
        endcase
        l23_rd <= l12_rd;
        l23_addr <= l12_addr;
    end

    always @(posedge clk1) begin // stage 3
        regbank[l23_rd] <= l23_z;
        l34_z <= l23_z;
        l34_addr <= l23_addr;
    end

    always @(posedge clk2) begin
        mem[l34_addr] <= l34_z;
    end
endmodule

