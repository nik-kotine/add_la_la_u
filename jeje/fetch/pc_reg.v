module pc_reg (
    output [31:0] PCF,
    input [31:0] PCFx,
    input CLK, reset, stallF
);
    always @ (posedge CLK) begin
        if (reset) begin
            PCF <= 32'b0;
        end
        else if (!stallF) begin
            // hold value :3
        end
        else begin
            PCF <= PCFx;
        end
    end
endmodule