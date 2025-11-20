module mux1_alu (
    output reg [31:0] srcAE,
    input [31:0] rd1E, resultW, aluResultM
    input [1:0] forwardAE,
);
    always @ (*) begin
        casez (forwardAE)
            2'b00: srcAE <= rd1E;
            2'b01: srcAE <= resultW; 
            2'b10: srcAE <= aluResultM;
            default: 
        endcase
    end
endmodule