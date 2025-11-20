module decoder(op, f3, f7, add_1, add_2, add_3, raw_imm, ins);
  output [6:0] op;
  output [2:0] f3;
  output [6:0] f7;
  output [4:0] add_1, add_2, add_3;
  output [24:0] raw_imm;
  input [31:0] ins;
  
  assign op = ins[6:0];
  assign f3 = ins[14:12];
  assign f7 = ins[31:25];
  assign add_1 = ins[19:15];
  assign add_2 = ins[24:20];
  assign add_3 = ins[11:7];
  assign raw_imm = ins[31:7];
  
endmodule
