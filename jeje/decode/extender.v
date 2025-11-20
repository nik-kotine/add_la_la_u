module extender(imm, raw_imm, IMM_SRC);
  output reg [31:0] imm;
  input [24:0] raw_imm;
  input [2:0] IMM_SRC; // 000=I, 001=S, 010=B, 011=U, 100=J

  always @(*) begin
    case (IMM_SRC)
      // I-type: [31:20]
      3'b000: imm = {{20{raw_imm[24]}}, raw_imm[24:13]};
      // S-type: [31:25 | 11:7]
      3'b001: imm = {{20{raw_imm[24]}}, raw_imm[24:18], raw_imm[4:0]};
      // B-type: [31 | 7 | 30:25 | 11:8 | 0]
      3'b010: imm = {{19{raw_imm[24]}}, raw_imm[0], raw_imm[23:18], raw_imm[4:1], 1'b0};
      // U-type: [31:12 | 12 zeros]
      3'b011: imm = {raw_imm[24:5], 12'b0};
      // J-type: [31 | 19:12 | 20 | 30:21 | 0]
      3'b100: imm = {{11{raw_imm[24]}}, raw_imm[12:5], raw_imm[13], raw_imm[23:14], 1'b0};
      default: imm = 32'b0;
    endcase
  end
endmodule
