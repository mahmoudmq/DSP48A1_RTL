module dsp48A1 #(
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

    dsp #(
        .A0REG(A0REG),
        .A1REG(A1REG),
        .B0REG(B0REG),
        .B1REG(B1REG),
        .CREG(CREG),
        .DREG(DREG),
        .MREG(MREG),
        .PREG(PREG),
        .CARRYINREG(CARRYINREG),
        .CARRYOUTREG(CARRYOUTREG),
        .OPMODEREG(OPMODEREG),
        .CARRYINSEL(CARRYINSEL),
        .B_INPUT(B_INPUT),
        .RSTTYPE(RSTTYPE)
    ) uut (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .CARRYIN(CARRYIN),
        .M(M),
        .P(P),
        .CARRYOUT(CARRYOUT),
        .CARRYOUTF(CARRYOUTF),

        // Control Input Ports
        .CLK(CLK),
        .OPMODE(OPMODE),

        // Clock Enable Input Ports
        .CEA(CEA),
        .CEB(CEB),
        .CEC(CEC),
        .CECARRYIN(CECARRYIN),
        .CED(CED),
        .CEM(CEM),
        .CEOPMODE(CEOPMODE),
        .CEP(CEP),

        // Reset Input Ports
        .RSTA(RSTA),
        .RSTB(RSTB),
        .RSTC(RSTC),
        .RSTCARRYIN(RSTCARRYIN),
        .RSTD(RSTD),
        .RSTM(RSTM),
        .RSTOPMODE(RSTOPMODE),
        .RSTP(RSTP),

        // Cascade Ports
        .BCIN(BCIN),
        .BCOUT(BCOUT),
        .PCIN(PCIN),
        .PCOUT(PCOUT)
    );

endmodule