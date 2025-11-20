module MEMWB(
    output reg [31:0] readDataW, aluResultW, rdW, PC_plus_4W,
    output reg regWriteW,
    output reg [1:0] ResultSrcW,
    input [31:0] readDataM,
    input [31:0] aluResultM, rdM, PC_plus_4M,
    input regWriteM, CLK,
    input [1:0] ResultSrcM,
);
    always @ (posedge CLK) begin
        readDataW <= readDataM;
        aluResultW <= aluResultM;
        rdW <= rdM;
        PC_plus_4W <= PC_plus_4M;
        regWriteW <= regWriteM;
        ResultSrcW <= ResultSrcM;
    end
endmodule