module alu(
  output reg [31:0] ALUResultE,
  output ZERO,
  input [31:0] src_A, src_B,
  input [3:0] ALUControlE
  );

  wire [4:0] shift_param = src_B[4:0];
  
  always @(*)
    begin
      case (ALUControlE)
        // 00XX: arithmetic
        4'b0000: ALUResultE = src_A + src_B; // add
        4'b0001: ALUResultE = src_A - src_B; // sub
        // 01XX: logic
        4'b0100: ALUResultE = src_A & src_B; // and
        4'b0101: ALUResultE = src_A | src_B; // or
        4'b0110: ALUResultE = src_A ^ src_B; // xor
        // 10XX: comparison
        4'b1000: ALUResultE =
          ($signed(src_A) < $signed(src_B)) ? 32'b1 : 32'b0; // slt
        4'b1001: ALUResultE = (src_A < src_B) ? 32'b1 : 32'b0; // sltu
        // 11XX: shifting
        4'b1110: ALUResultE = src_A << shift_param; // sll
        4'b1101: ALUResultE = src_A >> shift_param; // srl
        4'b1111: ALUResultE = $signed(src_A) >>> shift_param; // sra
        default: ALUResultE = 32'b0;
      endcase
  	end
  assign ZERO = (ALUResultE == 32'b0);
endmodule
