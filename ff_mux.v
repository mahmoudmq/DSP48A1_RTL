module ff_mux #(
    parameter reset_type = "SYNC", // takes "SYNC" or "ASYNC"
    parameter WIDTH = 18
) (
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out,
    input sel,
    input CLK,
    input Enable,
    input RST
);
    // Synchronous reset handling
    always @(posedge CLK) begin
        if (reset_type == "SYNC") begin
            if (RST) begin
                out = 0; // Reset the register
            end else if (Enable) begin
                if (sel) begin
                    out <= in;
                end else begin
                    out = in;
                end
            end else begin
                out = out; // Hold previous value if not enabled
            end
        end
    end
    // Asynchronous reset handling
    always @(posedge CLK or posedge RST) begin
        if (reset_type == "ASYNC") begin
            if (RST) begin
                out <= 0; // Reset output
            end else if (Enable) begin
                if (sel) begin
                    out <= in; // Update output with the registered value
                end else begin
                    out = in; // Directly assign input to output if not selected
                end 
            end else begin
                out = out; // Hold previous value if not enabled
            end
        end
    end
endmodule