module mux2_alu(
    output reg [31:0] mux2_out,
    input [31:0] rd2E, resultW, aluResultM,
    input [1:0] forwardBE,
);
    always @ (*) begin
        casez (forwardBE)
            2'b00: mux2_out <= rd2E;
            2'b01: mux2_out <= resultW; 
            2'b10: mux2_out <= aluResultM;
            default: ;
        endcase
    end
endmodule
