module reg3 (
    output reg [31:0] rdM, aluResultM, writeDataM, PCPlus4M,
    output reg regWriteM, memWriteM,
    output reg [1:0] ResultSrcM,
    input regWriteE, memWriteE, CLK,
    input [1:0] ResultSrcE,
    input [31:0] aluResultE, writeDataE, PCPlus4E, rdE
);

    always @ (posedge CLK) begin
        rdM <= rdE;
        aluResultM <= aluResultE;
        writeDataM <= writeDataE;
        PCPlus4M <= PCPlus4E;
        regWriteM <= regWriteE;
        memWriteM <= memWriteE;
        ResultSrcM <= ResultSrcE;
    end
endmodule