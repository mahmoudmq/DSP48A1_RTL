module dsp #(
    parameter A0REG = 0,
    parameter A1REG = 1,
    parameter B0REG = 0,
    parameter B1REG = 1,
    parameter CREG = 1,
    parameter DREG = 1,
    parameter MREG = 1,
    parameter PREG = 1,
    parameter CARRYINREG = 1,
    parameter CARRYOUTREG = 1,
    parameter OPMODEREG = 1,
    parameter CARRYINSEL = "OPMODE5", // takes "OPMODE5" or "CARRYIN"
    parameter B_INPUT = "DIRECT", // takes "DIRECT" or "CASCADE"
    parameter RSTTYPE = "SYNC" // takes "SYNC" or "ASYNC"
) (
    // Data Ports
    input [17:0] A,
    input [17:0] B,
    input [47:0] C,
    input [17:0] D,
    input CARRYIN,
    output [35:0] M,
    output [47:0] P,
    output CARRYOUT,
    output CARRYOUTF,

    // Control Input Ports
    input CLK,
    input [0:7] OPMODE,

    // Clock Enable Input Ports
    input CEA,
    input CEB,
    input CEC,
    input CECARRYIN,
    input CED,
    input CEM,
    input CEOPMODE,
    input CEP,

    // Reset Input Ports
    input RSTA,
    input RSTB,
    input RSTC,
    input RSTCARRYIN,
    input RSTD,
    input RSTM,
    input RSTOPMODE,
    input RSTP,

    // Cascade Ports
    input [17:0] BCIN,
    output [17:0] BCOUT,
    input [47:0] PCIN,
    output [47:0] PCOUT
);
    // Internal signals
    wire [7:0] OPMODE_reg;
    wire [17:0] A0_stage;
    wire [17:0] B0_stage;
    wire [47:0] C1_stage;
    wire [17:0] D1_stage;
    wire [17:0] B_selected;
    reg [17:0] pre_adder;
    wire [17:0] pre_adder_mux;
    wire [17:0] A1_stage;
    wire [17:0] B1_stage;
    wire [35:0] multiplier_out;
    wire carry_in;
    wire CIN;
    wire [47:0] M_extended;
    wire [47:0] concatenated;
    wire [47:0] z_out;
    wire [47:0] x_out;
    reg [47:0] post_adder;
    reg post_adder_co;

    // B input selection
    assign B_selected = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0;
    
    // First Stage in Pipeline
    ff_mux #(.WIDTH(8)) OPMODE_stage (.in(OPMODE), .out(OPMODE_reg), .sel(OPMODEREG), 
    .CLK(CLK), .Enable(CEOPMODE), .RST(RSTOPMODE));
    ff_mux D_stage (.in(D), .out(D1_stage), .sel(DREG), .CLK(CLK), .Enable(CED), .RST(RSTD));
    ff_mux A_stage (.in(A), .out(A0_stage), .sel(A0REG), .CLK(CLK), .Enable(CEA), .RST(RSTA));
    ff_mux B_stage (.in(B_selected), .out(B0_stage), .sel(B0REG), .CLK(CLK), .Enable(CEB), .RST(RSTB));
    ff_mux #(.WIDTH(48)) C_stage (.in(C), .out(C1_stage), .sel(CREG), .CLK(CLK), .Enable(CEC), .RST(RSTC));

    // Pre-Adder/Subtraction
    always @(posedge CLK) begin
      case (OPMODE_reg[6])
        1'b0: pre_adder = D1_stage + B0_stage;
        1'b1: pre_adder = D1_stage - B0_stage;
      endcase
    end

    // MUX for Pre-Adder Output
    assign pre_adder_mux = (OPMODE_reg[4]) ? pre_adder : B0_stage;

    // Second Stage in Pipeline
    ff_mux A1_stage_ff (.in(A0_stage), .out(A1_stage), .sel(A1REG), .CLK(CLK), .Enable(CEA), .RST(RSTA));
    ff_mux B1_stage_ff (.in(pre_adder_mux), .out(B1_stage), .sel(B1REG), .CLK(CLK), .Enable(CEB), .RST(RSTB));
    
    // Cascade output for Port B
    assign BCOUT = B1_stage;

    // Multiplier Out
    assign multiplier_out = A1_stage * B1_stage;
    // Carry IN Cascade
    assign carry_in = (CARRYINSEL == "OPMODE5") ? OPMODE_reg[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0;

    // Third Stage in Pipeline
    ff_mux #(.WIDTH(36)) M_stage (.in(multiplier_out), .out(M), .sel(MREG), .CLK(CLK), .Enable(CEM), .RST(RSTM));
    ff_mux #(.WIDTH(1)) CYI (.in(carry_in), .out(CIN), .sel(CARRYINREG), .CLK(CLK), .Enable(CECARRYIN), .RST(RSTCARRYIN));
    assign M_extended = {12'b0, M};

    // Z MUX out
    mux4_1 z_mux (.in3(C1_stage), .in2(PCOUT), .in1(PCIN), .sel(OPMODE_reg[3:2]), .out(z_out));
    // X MUX out
    assign concatenated = {D1_stage[11:0], A1_stage[17:0], B1_stage[17:0]};
    mux4_1 x_mux (.in3(concatenated), .in2(PCOUT), .in1(M_extended), .sel(OPMODE_reg[1:0]), .out(x_out));

    // Post-Adder Subtractor
    always @(posedge CLK) begin
      case (OPMODE_reg[7])
      1'b0: {post_adder_co, post_adder} = x_out + z_out + CIN;
      1'b1: {post_adder_co, post_adder} = z_out - (x_out + CIN);
      endcase
    end

    // CASCADE CARRY OUT
    ff_mux #(.WIDTH(1)) CYO (.in(post_adder_co), .out(CARRYOUT), .sel(CARRYOUTREG), 
    .CLK(CLK), .Enable(CECARRYIN), .RST(RSTCARRYIN));
    assign CARRYOUTF = CARRYOUT;

    // Output P
    ff_mux #(.WIDTH(48)) P_out (.in(post_adder), .out(P), .sel(PREG), .CLK(CLK), .Enable(CEP), .RST(RSTP));
    assign PCOUT = P;

endmodule