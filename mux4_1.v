module mux4_1 (
    input [47:0] in1,
    input [47:0] in2,
    input [47:0] in3,
    output reg [47:0] out,
    input [1:0] sel
);
    always @(*) begin
        case (sel)
            2'b00: out = 0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
        endcase
    end
endmodule