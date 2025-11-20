
// Code your design here

// ===================
// pc_mux
// ===================
module pc_mux(PC_next, PC_plus_4, PC_target, ALU_result, PC_SRC);
  input [31:0] PC_plus_4, PC_target, ALU_result;
  input [1:0] PC_SRC;
  output reg [31:0] PC_next;
  
  always @ (*)
    case (PC_SRC)
      2'b00: PC_next = PC_plus_4;
      2'b01: PC_next = PC_target;
      2'b10: PC_next = ALU_result;
      default: PC_next = PC_plus_4;
    endcase
endmodule

// ===================
// pc
// ===================
module pc(PC_curr, PC_next, CLK, RESET);
  output reg [31:0] PC_curr;
  input [31:0] PC_next;
  input CLK, RESET;
  
  always @ (posedge CLK)
    begin
      if (RESET) PC_curr <= 32'b0;
      else PC_curr <= PC_next;
    end
endmodule

// ===================
// ins_mem
// ===================
module ins_mem(ins, address);
  output [31:0] ins;
  input [31:0] address;

  reg [31:0] IMEM [0:63];

  assign ins = IMEM[address[31:2]];
  
  initial begin
    $readmemh("program.hex", IMEM);
  end
endmodule

// ===================
// decoder
// ===================
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

// ===================
// extender
// ===================
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

// ===================
// reg_file
// ===================
module reg_file(r_data_1, r_data_2, add_1, add_2, add_3, write_data, CLK, REG_WRITE);
  output [31:0] r_data_1, r_data_2;
  input CLK, REG_WRITE;
  input [4:0] add_1, add_2, add_3;
  input [31:0] write_data;
  
  reg [31:0] rf [31:0];
  
  assign r_data_1 = (add_1 == 5'b0) ? (32'b0) : (rf[add_1]);
  assign r_data_2 = (add_2 == 5'b0) ? (32'b0) : (rf[add_2]);
  
  always @ (posedge CLK)
    begin
      if ((REG_WRITE) && (add_3 != 5'b0))
        rf[add_3] <= write_data;
    end
endmodule

// ===================
// alu
// ===================
module alu(ALU_result, ZERO, src_A, src_B, ALU_CONTROL);
  output reg [31:0] ALU_result;
  output ZERO;
  input [31:0] src_A;
  input [31:0] src_B;
  input [3:0] ALU_CONTROL;
  
  wire [4:0] shift_param = src_B[4:0];
  
  always @(*)
    begin
      case (ALU_CONTROL)
        // 00XX: arithmetic
        4'b0000: ALU_result = src_A + src_B; // add
        4'b0001: ALU_result = src_A - src_B; // sub
        // 01XX: logic
        4'b0100: ALU_result = src_A & src_B; // and
        4'b0101: ALU_result = src_A | src_B; // or
        4'b0110: ALU_result = src_A ^ src_B; // xor
        // 10XX: comparison
        4'b1000: ALU_result =
          ($signed(src_A) < $signed(src_B)) ? 32'b1 : 32'b0; // slt
        4'b1001: ALU_result = (src_A < src_B) ? 32'b1 : 32'b0; // sltu
        // 11XX: shifting
        4'b1110: ALU_result = src_A << shift_param; // sll
        4'b1101: ALU_result = src_A >> shift_param; // srl
        4'b1111: ALU_result = $signed(src_A) >>> shift_param; // sra
        default: ALU_result = 32'b0;
      endcase
  	end
  assign ZERO = (ALU_result == 32'b0);
endmodule

// ===================
// data_mem
// ===================
module data_mem(r_data, res_add, write_data, CLK, MEM_WRITE);
  input CLK, MEM_WRITE;
  input [31:0] res_add, write_data;
  output [31:0] r_data;
  
  reg [31:0] RAM [63:0];
  
  assign r_data = RAM[res_add[31:2]];
  
  always @ (posedge CLK)
    begin
      if (MEM_WRITE) RAM[res_add[31:2]] <= write_data;
    end
endmodule

// ===================
// result_mux
// ===================
module result_mux(add_3, ALU_result, r_data, PC_plus_4, PC_target, RES_SRC);
  output reg [31:0] add_3;
  input [31:0] ALU_result, r_data, PC_plus_4, PC_target;
  input [1:0] RES_SRC;
  
  always @ (*)
    begin
      case (RES_SRC)
        2'b00: add_3 = ALU_result;
        2'b01: add_3 = r_data;
        2'b10: add_3 = PC_plus_4;
        2'b11: add_3 = PC_target;
        default: add_3 = ALU_result;
      endcase
    end
endmodule

// ===================
// adder
// ===================
module adder(Q, A, B);
  output [31:0] Q;
  input [31:0] A, B;
  assign Q = A + B;
endmodule

// ===================
// control_unit
// ===================
module control_unit(PC_SRC, RES_SRC, REG_WRITE, MEM_WRITE, ALU_CONTROL, ALU_SRC_A, ALU_SRC_B, IMM_SRC, op, f3, f7, ZERO);
  output reg [1:0] PC_SRC, RES_SRC;
  output reg MEM_WRITE, ALU_SRC_A, ALU_SRC_B, REG_WRITE;
  output reg [3:0] ALU_CONTROL;
  output reg [2:0] IMM_SRC;
  input [6:0] op, f7;
  input [2:0] f3;
  input ZERO;
  
  parameter I_TYPE_LOAD = 7'b0000011;
  parameter I_TYPE_OP = 7'b0010011;
  parameter U_TYPE_AUIPC = 7'b0010111;
  parameter S_TYPE = 7'b0100011;
  parameter R_TYPE = 7'b0110011;
  parameter U_TYPE_LUI = 7'b0110111;
  parameter B_TYPE = 7'b1100011;
  parameter I_TYPE_JALR = 7'b1100111;
  parameter J_TYPE = 7'b1101111;
  
  always @ (*)
    case (op)
      I_TYPE_LOAD:
        begin
          PC_SRC = 2'b00; // PC+4
          RES_SRC = 2'b01; // data memory
          MEM_WRITE = 1'b0; // read-only
          ALU_CONTROL = 4'b0000; // add
          ALU_SRC_A = 1'b0; // rd1
          ALU_SRC_B = 1'b1; // immediate
          IMM_SRC = 3'b000; // I-type
          REG_WRITE = 1'b1; // write on rd
        end
      I_TYPE_OP:
        begin
          PC_SRC = 2'b00; // PC+4
          RES_SRC = 2'b00; // ALU result
          MEM_WRITE = 1'b0; // read-only
          ALU_SRC_A = 1'b0; // rd1
          ALU_SRC_B = 1'b1; // immediate
          IMM_SRC = 3'b000; // I-type
          REG_WRITE = 1'b1; // write on rd
          case (f3)
            3'b000: ALU_CONTROL = 4'b0000; // sum
            3'b001: ALU_CONTROL = 4'b1110; // shift left logical
            3'b010: ALU_CONTROL = 4'b1000; // lesser signed
            3'b011: ALU_CONTROL = 4'b1001; // lesser unsigned
            3'b100: ALU_CONTROL = 4'b0110; // xor
            3'b101:
              case (f7)
                7'b0000000: ALU_CONTROL = 4'b1101; // shift right logical
                7'b0100000: ALU_CONTROL = 4'b1111; // shift right arithmetic
              endcase
            3'b110: ALU_CONTROL = 4'b0101; // or
            3'b111: ALU_CONTROL = 4'b0100; // and
          endcase
        end
      S_TYPE:
        begin
          PC_SRC = 2'b00; // PC+4
          RES_SRC = 2'bXX; // unused
          MEM_WRITE = 1'b1; // write on memory
          ALU_CONTROL = 4'b0000; // add
          ALU_SRC_A = 1'b0; // rd1
          ALU_SRC_B = 1'b1; // immediate
          IMM_SRC = 3'b001; // S-type
          REG_WRITE = 1'b0; // read-only
        end
      U_TYPE_AUIPC:
        begin
          PC_SRC = 2'b00; // PC+4
          RES_SRC = 2'b11; // PCTarget
          MEM_WRITE = 1'b0; // read-only
          ALU_CONTROL = 4'bXXXX; // unused
          ALU_SRC_A = 1'bX; // unused
          ALU_SRC_B = 1'bX; // unused
          IMM_SRC = 3'b011; // U-type
          REG_WRITE = 1'b1; // write on rd
        end
      R_TYPE:
        begin
          PC_SRC = 2'b00; // PC+4
          RES_SRC = 2'b00; // ALU result
          MEM_WRITE = 1'b0; // read-only
          ALU_SRC_A = 1'b0; // rd1
          ALU_SRC_B = 1'b0; // rd2
          IMM_SRC = 3'bXXX; // unused
          REG_WRITE = 1'b1; // write on rd
          case (f3)
            3'b000:
              case (f7)
                7'b0000000: ALU_CONTROL = 4'b0000;
                7'b0100000: ALU_CONTROL = 4'b0001;
              endcase
            3'b001: ALU_CONTROL = 4'b1110; // shift left logical
            3'b010: ALU_CONTROL = 4'b1000; // lesser signed
            3'b011: ALU_CONTROL = 4'b1001; // lesser unsigned
            3'b100: ALU_CONTROL = 4'b0110; // xor
            3'b101:
              case (f7)
                7'b0000000: ALU_CONTROL = 4'b1101; // shift right logical
                7'b0100000: ALU_CONTROL = 4'b1111; // shift right arithmetic
              endcase
            3'b110: ALU_CONTROL = 4'b0101; // or
            3'b111: ALU_CONTROL = 4'b0100; // and
          endcase
        end
      U_TYPE_LUI:
        begin
          PC_SRC = 2'b00; // PC+4
          RES_SRC = 2'b00; // ALU result
          MEM_WRITE = 1'b0; // read-only
          ALU_CONTROL = 4'b0000; // add
          ALU_SRC_A = 1'b1; // zero
          ALU_SRC_B = 1'b1; // immediate
          IMM_SRC = 3'b011; // U-type
          REG_WRITE = 1'b1; // write on rd
        end
      B_TYPE:
        begin
          RES_SRC = 2'bXX; // unused
          MEM_WRITE = 1'b0; // read-only
          ALU_SRC_A = 1'b0; // rd1
          ALU_SRC_B = 1'b0; // rd2
          IMM_SRC = 3'b010; // B-type
          REG_WRITE = 1'b0; // read-only
          case (f3)
            3'b000: begin
              ALU_CONTROL = 4'b0001;
              PC_SRC = { 1'b0, ZERO };
            end
            3'b001: begin
              ALU_CONTROL = 4'b0001;
              PC_SRC = { 1'b0, ~ZERO };
            end
            3'b100: begin
              ALU_CONTROL = 4'b1000;
              PC_SRC = { 1'b0, ZERO };
            end
            3'b101: begin
              ALU_CONTROL = 4'b1000;
              PC_SRC = { 1'b0, ~ZERO };
            end
            3'b110: begin
              ALU_CONTROL = 4'b1001;
              PC_SRC = { 1'b0, ZERO };
            end
            3'b111: begin
              ALU_CONTROL = 4'b1001;
              PC_SRC = { 1'b0, ~ZERO };
            end
          endcase
        end
      I_TYPE_JALR:
        begin
          PC_SRC = 2'b10; // ALU result
          RES_SRC = 2'b10; // data memory
          MEM_WRITE = 1'b0; // read-only
          ALU_CONTROL = 4'b0000; // add
          ALU_SRC_A = 1'b0; // rs1
          ALU_SRC_B = 1'b1; // immediate
          IMM_SRC = 3'b000; // I-type
          REG_WRITE = 1'b1; // write rd=PC+4
        end
      J_TYPE:
        begin
          PC_SRC = 2'b01; // ALU result
          RES_SRC = 2'b10; // PC+4
          MEM_WRITE = 1'b0; // read-only
          ALU_CONTROL = 4'bXXXX; // unused
          ALU_SRC_A = 1'bX; // unused
          ALU_SRC_B = 1'bX; // unused
          IMM_SRC = 3'b100; // J-type
          REG_WRITE = 1'b1; // write rd=PC+4
        end
      default:
        begin
          PC_SRC = 2'bXX;
          RES_SRC = 2'bXX;
          MEM_WRITE = 1'bX;
          ALU_CONTROL = 4'bXXXX;
          ALU_SRC_A = 1'bX;
          ALU_SRC_B = 1'bX;
          IMM_SRC = 3'bXXX;
          REG_WRITE = 1'bX;
        end
    endcase
  
endmodule

// ===================
// top
// ===================
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

  // =================== WORKFLOW ===================

  // pc
  pc PC_inst(
    .PC_curr(PC_curr),
    .PC_next(PC_next),
    .CLK(CLK),
    .RESET(RESET)
  );
  
  adder PCplus4_inst(
    .Q(PC_plus_4),
    .A(PC_curr),
    .B(32'd4)
  );
  
  adder PCtarget_inst(
    .Q(PC_target),
    .A(PC_curr),
    .B(imm)
  );

  // instruction memory
  ins_mem IMEM(
    .ins(instruction),
    .address(PC_curr)
  );

  // decoder
  decoder DEC(
    .op(op),
    .f3(f3),
    .f7(f7),
    .add_1(add_1),
    .add_2(add_2),
    .add_3(add_3),
    .raw_imm(raw_imm),
    .ins(instruction)
  );

  // control unit
  control_unit CTRL(
    .PC_SRC(PC_SRC),
    .RES_SRC(RES_SRC),
    .REG_WRITE(REG_WRITE),
    .MEM_WRITE(MEM_WRITE),
    .ALU_CONTROL(ALU_CONTROL),
    .ALU_SRC_A(ALU_SRC_A),
    .ALU_SRC_B(ALU_SRC_B),
    .IMM_SRC(IMM_SRC),
    .op(op),
    .f3(f3),
    .f7(f7),
    .ZERO(ZERO)
  );

  // extender
  extender EXT(
    .imm(imm),
    .raw_imm(raw_imm),
    .IMM_SRC(IMM_SRC)
  );

  // register file
  reg_file RF(
    .r_data_1(r_data_1),
    .r_data_2(r_data_2),
    .add_1(add_1),
    .add_2(add_2),
    .add_3(add_3),
    .write_data(write_data),
    .CLK(CLK),
    .REG_WRITE(REG_WRITE)
  );

  // ALU source MUX
  assign src_A = (ALU_SRC_A) ? 32'b0 : r_data_1;
  assign src_B = (ALU_SRC_B) ? imm : r_data_2;

  // ALU
  alu ALU(
    .ALU_result(ALU_result),
    .ZERO(ZERO),
    .src_A(src_A),
    .src_B(src_B),
    .ALU_CONTROL(ALU_CONTROL)
  );

  // data memory
  data_mem DMEM(
    .r_data(r_data),
    .res_add(ALU_result),
    .write_data(r_data_2),
    .CLK(CLK),
    .MEM_WRITE(MEM_WRITE)
  );

  // result MUX
  result_mux RMUX(
    .add_3(write_data),
    .ALU_result(ALU_result),
    .r_data(r_data),
    .PC_plus_4(PC_plus_4),
    .PC_target(PC_target),
    .RES_SRC(RES_SRC)
  );

  // next PC MUX
  pc_mux PCMUX(
    .PC_next(PC_next),
    .PC_plus_4(PC_plus_4),
    .PC_target(PC_target),
    .ALU_result(ALU_result),
    .PC_SRC(PC_SRC)
  );

endmodule
