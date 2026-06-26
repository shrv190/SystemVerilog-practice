// Construct a vending machine which accepts coins. User can cancel the purchase anytime. User select through 4 different products to vend the item.
// A Intermediate level project

// This DUT doesn't even work as
//                              1> The datapath and control path fsmd are declared separately instead of merging into one for better modelling
//                              2> Multiple statement and functions are declared separately in separate module instead of doing all in one using the built in some statements like conditional statements(case statement) which make handling and managing the machine difficult
// The DUT with all the above problem fixed is present in "./03 Practice Projects/03_vending_machine_i.sv"

module mux4in1 (
    input in1, in2, in3, in4, enable,
    input [1:0] sel, 
    output reg out
);
    always @(*) begin
        if (enable) begin
            case (sel)
                2'b00: out = in1;
                2'b01: out = in2;
                2'b10: out = in3; 
                2'b11: out = in4;
                default: out = 1'b0;
            endcase
        end
    end
endmodule

module mux4in1_4bit (
    input [3:0] in1, in2, in3, in4,
    input [1:0] sel, 
    output reg [3:0] out
);
    always @(*) begin
        case (sel)
            2'b00: out = in1;
            2'b01: out = in2;
            2'b10: out = in3; 
            2'b11: out = in4;
            default: out = 1'b0;
        endcase
    end
endmodule

module comparator(
    input [3:0] m_in,
    input [3:0] itemselprice,
    input vend, cancel,
    output reg [3:0] out, m_out, itemselprice_out
);
    always @(*) begin
        if (vend) begin
            itemselprice_out = itemselprice;
            if (m_in >= itemselprice) begin
                out = m_in;
            end else begin
                m_out = m_in;
            end
        end else if (cancel) begin
            m_out = m_in;
        end
    end
endmodule

module vending_machine_dp (
    input [3:0] m_in,
    input [1:0] sel,
    input item1, item2, item3, item4, cancel, clk, vend,
    output reg [3:0] itemselprice, subout,
    output [3:0] m_out,
    output item,
    output reg enable
);
    reg [3:0] m_inreg;
    wire [15:0] z, w;
    wire [3:0] x, y;

    mux4in1 itemselmux (item1, item2, item3, item4, enable, sel, item);
    mux4in1_4bit itemselpricemux (4'd5, 4'd7, 4'd10, 4'd15, sel, itemselprice);
    comparator twopricecompare (m_inreg, itemselprice, vend, cancel, x, m_out, y);
    always @(posedge clk) begin
        if (y >= x) begin
            subout <= x - y;
            enable <= 1'b1;
            m_inreg <= x-y ;
        end
        else begin
            m_inreg = m_in;
            enable <= 0;
        end
    end
endmodule

module vending_machine_cp (
    input [15:0] m_out, itemselprice,
    input item, clk, clr, start,
    output [15:0] m_in,
    output [1:0] sel,
    output clr_m_in, ld_m_in, clr_cancel, ld_cancel, clr_vend, ld_vend, enable, item1, item2, item3, stop
);
    // always @(posedge clk or posedge clear) begin
        
    // end
endmodule