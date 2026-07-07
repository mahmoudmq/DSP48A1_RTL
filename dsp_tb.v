module dsp_tb();
    parameter A0REG = 0;
    parameter A1REG = 1;
    parameter B0REG = 0;
    parameter B1REG = 1;
    parameter CREG = 1;
    parameter DREG = 1;
    parameter MREG = 1;
    parameter PREG = 1;
    parameter CARRYINREG = 1;
    parameter CARRYOUTREG = 1;
    parameter OPMODEREG = 1;
    parameter CARRYINSEL = "OPMODE5"; // takes "OPMODE5" or "CARRYIN"
    parameter B_INPUT = "DIRECT"; // takes "DIRECT" or "CASCADE"
    parameter RSTTYPE = "SYNC"; // takes "SYNC" or "ASYNC"

    reg [17:0] A;
    reg [17:0] B;
    reg [17:0] D;
    reg [47:0] C;
    reg CARRYIN;
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT;
    wire CARRYOUTF;

    reg CLK;
    reg [0:7] OPMODE;

    reg CEA;
    reg CEB;
    reg CEC;
    reg CECARRYIN;
    reg CED;
    reg CEM;
    reg CEOPMODE;
    reg CEP;

    reg RSTA;
    reg RSTB;
    reg RSTC;
    reg RSTCARRYIN;
    reg RSTD;
    reg RSTM;
    reg RSTOPMODE;
    reg RSTP;

    reg [17:0] BCIN;
    wire [17:0] BCOUT;
    reg [47:0] PCIN;
    wire [47:0] PCOUT;

    // instatiate the DSP module
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

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100 MHz clock
    end
    
    // Testbench stimulus
    initial begin
        // Assert all active-high reset signals by setting them to 1
        RSTA = 1; 
        RSTB = 1; 
        RSTC = 1; 
        RSTCARRYIN = 1; 
        RSTD = 1; 
        RSTM = 1; 
        RSTOPMODE = 1; 
        RSTP = 1;
        A = $random;
        B = $random;
        C = $random;
        D = $random;
        CARRYIN = $random;
        OPMODE = $random;
        CEA = $random;
        CEB = $random;
        CEC = $random;
        CECARRYIN = $random;
        CED = $random;
        CEM = $random;
        CEOPMODE = $random;
        CEP = $random;
        BCIN = $random;
        PCIN = $random;
        @ (negedge CLK); // Wait for a clock edge
        // Self-Checking to verify all outputs are zero
        if (P !== 0 || M !== 0 || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test failed: Outputs are not zero after reset.");
        end else begin
            $display("Test passed: Outputs are zero after reset.");
        end
        // Deassert reset signals
        RSTA = 0;
        RSTB = 0;
        RSTC = 0;
        RSTCARRYIN = 0;
        RSTD = 0;
        RSTM = 0;
        RSTOPMODE = 0;
        RSTP = 0;
        // assert all clock enable signals to validate the functionality of the subsequent DSP paths
        CEA = 1;
        CEB = 1;
        CEC = 1;
        CECARRYIN = 1;
        CED = 1;
        CEM = 1;
        CEOPMODE = 1;
        CEP = 1;
        @ (negedge CLK);

        // Verify DSP Path 1
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        OPMODE = 8'b11011101;
        BCIN = $random;
        PCIN = $random;
        CARRYIN = $random;
        repeat (6) @(negedge CLK); 
        // Self-Checking outputs
        if (P !== 'h32 || PCOUT !== 'h32 || M !== 'h12c || BCOUT !== 'hf|| CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test failed: DSP Path 1 outputs are incorrect.");
        end else begin
            $display("Test passed: DSP Path 1 outputs are correct.");
        end

        // Verify DSP Path 2
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        OPMODE = 8'b00010000;
        BCIN = $random;
        PCIN = $random;
        CARRYIN = $random;
        repeat (5) @(posedge CLK); 
        // Self-Checking outputs
        if (P !== 'h0 || PCOUT !== 'h0 || M !== 'h2bc || BCOUT !== 'h23 || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test failed: DSP Path 2 outputs are incorrect.");
        end else begin
            $display("Test passed: DSP Path 2 outputs are correct.");
        end

        // Verify DSP Path 3
        OPMODE = 8'b00001010;
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        BCIN = $random;
        PCIN = $random;
        CARRYIN = $random;
        repeat (5) @(posedge CLK);
        // Self-Checking outputs
        if (P !== 'h0 || PCOUT !== 'h0 || M !== 'hc8 || BCOUT !== 'ha || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test failed: DSP Path 3 outputs are incorrect.");
        end else begin
            $display("Test passed: DSP Path 3 outputs are correct.");
        end

        // Verify DSP Path 4
        OPMODE = 8'b10100111;
        A = 5;
        B = 6;
        C = 350;
        D = 25;
        PCIN = 3000;
        BCIN = $random;
        CARRYIN = $random;
        repeat (5) @(posedge CLK);
        // Self-Checking outputs
        if (P !== 'hfe6fffec0bb1 || PCOUT !== 'hfe6fffec0bb1 || M !== 'h1e || BCOUT !== 'h6 || CARRYOUT !== 1 || CARRYOUTF !== 1) begin
            $display("Test failed: DSP Path 4 outputs are incorrect.");
        end else begin
            $display("Test passed: DSP Path 4 outputs are correct.");
        end

        $finish; // End simulation
    end

endmodule