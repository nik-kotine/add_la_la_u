module top(CLK, RESET);

  wire [31:0] PC_curr, PC_next, PC_plus_4, PC_target;
  wire [31:0] instruction;
  wire [6:0] op, f7;
  wire [2:0] f3;
  wire [4:0] add_1, add_2, add_3;
  wire [24:0] raw_imm;
  wire [31:0] imm;

  wire [31:0] r_data_1, r_data_2, src_A, src_B;
  wire [31:0] ALU_result;
  wire ZERO;

  wire [31:0] r_data;
  wire [31:0] write_data;

  wire [1:0] PC_SRC, RES_SRC;
  wire [2:0] IMM_SRC;
  wire [3:0] ALU_CONTROL;
  wire REG_WRITE, MEM_WRITE, ALU_SRC_A, ALU_SRC_B;
  
  input CLK, RESET;
