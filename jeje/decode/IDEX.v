module reg2 (
    output reg [31:0] rd1E, rd2E, pcE, rs1E, rs2E, rdE, extImmE,PCPlus4E,
    output reg regWriteE, memWriteE, jumpE, branchE, ALUsrcE,
    output reg [3:0] ALUcontrolE,
    output reg [1:0] ResultSrcE,

    input [31:0] rd1, rd2, pcD, rs1D, rs2D, rdD, extImmD,PCPlus4D,
    input flushE, regWriteD, memWriteD, jumpD, branchD, ALUsrcD, CLK, reset,
    input [3:0] ALUcontrolD,
    input [1:0] ResultSrcD
    );

    always @ (posedge CLK) begin
        if (reset || flushE) begin
            rd1E        <= 32'b0;
            rd2E        <= 32'b0;
            pcE         <= 32'b0;
            rs1E        <= 32'b0;
            rs2E        <= 32'b0;
            rdE         <= 32'b0;
            extImmE     <= 32'b0;
            PCPlus4E  <= 32'b0;
            regWriteE   <= 1'b0;
            memWriteE   <= 1'b0;
            jumpE       <= 1'b0;
            branchE     <= 1'b0;
            ALUsrcE     <= 1'b0;
            ALUcontrolE <= 4'b0;
            ResultSrcE  <= 2'b0;
        end
        else begin
            rd1E        <= rd1;
            rd2E        <= rd2;
            pcE         <= pcD;
            rs1E        <= rs1D;
            rs2E        <= rs2D;
            rdE         <= rdD;
            extImmE     <= extImmD;
            PCPlus4E  <= PCPlus4D;

            regWriteE   <= regWriteD;
            memWriteE   <= memWriteD;
            jumpE       <= jumpD;
            branchE     <= branchD;
            ALUsrcE     <= ALUsrcD;
            ALUcontrolE <= ALUcontrolD;
            ResultSrcE  <= ResultSrcD;
        end
    end

endmodule