// Construct a vending machine which accepts coins. User can cancel the purchase anytime. User select through 4 different products to vend the item.
// A Intermediate level project

module vending_machine (
    input clk, rst, vend, cancel,
    input [15:0] coin_in,
    input [1:0] sel,
    input [3:0] count,
    output reg [15:0] change,
    output reg item,
    output reg coin_in_valid, sel_valid
);
    reg [3:0] price, itemreg;
    reg [15:0] balance, total_price;
    reg [1:0] curr_state, next_state;
    reg item1, item2, item3, item4;

    parameter s0 = 2'b00;
    parameter s1 = 2'b01;
    parameter s2 = 2'b10;
    parameter s3 = 2'b11;

    always @(*) begin
        case (sel)
            2'b00 : begin price = 4'd5; itemreg = item1; end
            2'b01 : begin price = 4'd7; itemreg = item2; end
            2'b10 : begin price = 4'd10; itemreg = item3; end
            2'b11 : begin price = 4'd15; itemreg = item4; end
            default: begin price = 4'd00; itemreg = 0; end
        endcase

        if (vend) begin
            coin_in_valid = (coin_in > 0);
            sel_valid = 1'b1;
        end else begin
            coin_in_valid = 1'b0;
            sel_valid = 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) curr_state <= s0;
        else    curr_state <= next_state;
    end

    always @(*) begin
        next_state = curr_state;

        case (curr_state)
            s0: if (coin_in_valid) next_state = s1;
            s1: if (cancel) next_state = s0; 
                else if (sel_valid && balance >= total_price) next_state = s2;
                else next_state = s0;
            s2: begin
                    next_state = s3;           
                end
            s3: next_state = s1;
            default: next_state = s0;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            change <= 0;
            balance <= 0;
            total_price <= 0;
            item <= 0;
        end
        else begin
            case (curr_state)
                s0: begin
                    item = 2'b00;
                    if (coin_in_valid) begin
                        balance <= balance + coin_in;
                        total_price <= price * count;
                        change = 1'b0;
                    end
                end
                s1: if (cancel) begin
                        change <= balance;
                        balance <= 0;
                    end
                s2: begin
                    item <= itemreg;
                    change <= balance - total_price;
                end
                s3: begin
                    balance <= change;
                end
            endcase
        end
    end
endmodule