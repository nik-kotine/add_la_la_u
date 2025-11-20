`timescale 1ps/1ps

module reg1 (
    output reg [31:0] insD, PCD, PCPlus4D,
    input flushD, stallD, CLK, reset,
    input [31:0] insF, PCPlus4F, PCF
);

    always @ (posedge CLK) begin
        if(reset || flushD) begin
            insD <= 32'b0;
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;
        end
        else if (!stallD) begin
            // hold values :3
        end
        else begin
            insD <= insF;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end
endmodule