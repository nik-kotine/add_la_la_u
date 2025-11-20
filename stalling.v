module stallingUnit(
    output wire lwStall, stallF, stallD, flushE
    input [1:0] resultSrcE,
    input [4:0] rs1D, rs2D,
    input [4:0] rdE
);

assign lwStall = resultSrcE[0] & ((rs1D == rdE) | (rs2D == rdE));
assign stallF = lwStall;
assign stallD = lwStall;
assign flushE = lwStall;
endmodule