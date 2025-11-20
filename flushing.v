module flushingUnit(
    output reg flushD, flushE,
    input lwStall, PCSrcE,
);

    assign flushD = PCSrcE;
    assign flushE = lwStall | PCSrcE;

endmodule