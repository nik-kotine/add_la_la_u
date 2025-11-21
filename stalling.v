module stallingUnit(
    output wire lwStall, stallF, stallD,
    input [1:0] resultSrcE,
    input [4:0] rs1D, rs2D, rdE
);

assign lwStall = resultSrcE[0] & ((rs1D == rdE) | (rs2D == rdE));
assign stallF = lwStall;
assign stallD = lwStall;
endmodule