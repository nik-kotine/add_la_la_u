// changed ALU_SRC_B to ALU_SRC_D
// we are assumming ALU_SRC_A will not be used in the future
// and will be ignored promptly

// ===================
// control_unit
// ===================
module control_unit(
  output reg [1:0] RES_SRC_D,
  output reg MEM_WRITE_D, ALU_SRC_D, REG_WRITE_D, JUMP_D, BRANCH_D,
  output reg [3:0] ALU_CONTROL_D,
  output reg [2:0] IMM_SRC_D,
  input [6:0] op, f7,
  input [2:0] f3
);
  
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
          RES_SRC_D = 2'b01; // data memory
          MEM_WRITE_D = 1'b0; // read-only
          ALU_CONTROL_D = 4'b0000; // add
          ALU_SRC_D = 1'b1; // use immediate
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          IMM_SRC_D = 3'b000; // I-type
          REG_WRITE_D = 1'b1; // write on rd
        end
      I_TYPE_OP:
        begin
          RES_SRC_D = 2'b00; // ALU result
          MEM_WRITE_D = 1'b0; // read-only
          ALU_SRC_D = 1'b1; // use immediate
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          IMM_SRC_D = 3'b000; // I-type
          REG_WRITE_D = 1'b1; // write on rd
          case (f3)
            3'b000: ALU_CONTROL_D = 4'b0000; // sum
            3'b001: ALU_CONTROL_D = 4'b1110; // shift left logical
            3'b010: ALU_CONTROL_D = 4'b1000; // lesser signed
            3'b011: ALU_CONTROL_D = 4'b1001; // lesser unsigned
            3'b100: ALU_CONTROL_D = 4'b0110; // xor
            3'b101:
              case (f7)
                7'b0000000: ALU_CONTROL_D = 4'b1101; // shift right logical
                7'b0100000: ALU_CONTROL_D = 4'b1111; // shift right arithmetic
              endcase
            3'b110: ALU_CONTROL_D = 4'b0101; // or
            3'b111: ALU_CONTROL_D = 4'b0100; // and
          endcase
        end
      S_TYPE:
        begin
          RES_SRC_D = 2'bXX; // unused
          MEM_WRITE_D = 1'b1; // write on memory
          ALU_CONTROL_D = 4'b0000; // add
          //ALU_SRC_A = 1'b0; // rd1
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          ALU_SRC_B_D = 1'b1; // immediate
          IMM_SRC_D = 3'b001; // S-type
          REG_WRITE_D = 1'b0; // read-only
        end
      U_TYPE_AUIPC:
        begin
          RES_SRC_D = 2'b11; // PCTarget
          MEM_WRITE_D = 1'b0; // read-only
          ALU_CONTROL_D = 4'bXXXX; // unused
          //ALU_SRC_A = 1'bX; // unused
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          ALU_SRC_D = 1'bX; // unused
          IMM_SRC_D = 3'b011; // U-type
          REG_WRITE_D = 1'b1; // write on rd
        end
      R_TYPE:
        begin
          RES_SRC_D = 2'b00; // ALU result
          MEM_WRITE_D = 1'b0; // read-only
          //ALU_SRC_A = 1'b0; // rd1
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          ALU_SRC_D = 1'b0; // rd2
          IMM_SRC_D = 3'bXXX; // unused
          REG_WRITE_D = 1'b1; // write on rd
          case (f3)
            3'b000:
              case (f7)
                7'b0000000: ALU_CONTROL_D = 4'b0000;
                7'b0100000: ALU_CONTROL_D = 4'b0001;
              endcase
            3'b001: ALU_CONTROL_D = 4'b1110; // shift left logical
            3'b010: ALU_CONTROL_D = 4'b1000; // lesser signed
            3'b011: ALU_CONTROL_D = 4'b1001; // lesser unsigned
            3'b100: ALU_CONTROL_D = 4'b0110; // xor
            3'b101:
              case (f7)
                7'b0000000: ALU_CONTROL_D = 4'b1101; // shift right logical
                7'b0100000: ALU_CONTROL_D = 4'b1111; // shift right arithmetic
              endcase
            3'b110: ALU_CONTROL_D = 4'b0101; // or
            3'b111: ALU_CONTROL_D = 4'b0100; // and
          endcase
        end
      U_TYPE_LUI:
        begin
          RES_SRC_D = 2'b00; // ALU result
          MEM_WRITE_D = 1'b0; // read-only
          ALU_CONTROL_D = 4'b0000; // add
          //ALU_SRC_A = 1'b1; // zero
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          ALU_SRC_D = 1'b1; // immediate
          IMM_SRC_D = 3'b011; // U-type
          REG_WRITE_D = 1'b1; // write on rd
        end
      B_TYPE:
        begin
          RES_SRC_D = 2'bXX; // unused
          MEM_WRITE_D = 1'b0; // read-only
          //ALU_SRC_A = 1'b0; // rd1
          ALU_SRC_D = 1'b0; // rd2
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b1; // branch usage
          IMM_SRC_D = 3'b010; // B-type
          REG_WRITE_D = 1'b0; // read-only
          case (f3)
            3'b000: begin
              ALU_CONTROL_D = 4'b0001;
            end
            3'b001: begin
              ALU_CONTROL_D = 4'b0001;
            end
            3'b100: begin
              ALU_CONTROL_D = 4'b1000;
            end
            3'b101: begin
              ALU_CONTROL_D = 4'b1000;
            end
            3'b110: begin
              ALU_CONTROL_D = 4'b1001;
            end
            3'b111: begin
              ALU_CONTROL_D = 4'b1001;
            end
          endcase
        end
      I_TYPE_JALR:
        begin
          RES_SRC_D = 2'b10; // data memory
          MEM_WRITE_D = 1'b0; // read-only
          ALU_CONTROL_D = 4'b0000; // add
          //ALU_SRC_A = 1'b0; // rs1
          ALU_SRC_D = 1'b1; // immediate
          JUMP_D = 1'b0; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          IMM_SRC_D = 3'b000; // I-type
          REG_WRITE_D = 1'b1; // write rd=PC+4
        end
      J_TYPE:
        begin
          RES_SRC_D = 2'b10; // PC+4
          MEM_WRITE_D = 1'b0; // read-only
          ALU_CONTROL_D = 4'bXXXX; // unused
          //ALU_SRC_A = 1'bX; // unused
          ALU_SRC_D = 1'bX; // unused
          JUMP_D = 1'b1; // no jump usage
          BRANCH_D = 1'b0; // no branch usage
          IMM_SRC_D = 3'b100; // J-type
          REG_WRITE_D = 1'b1; // write rd=PC+4
        end
      default:
        begin-
          RES_SRC_D = 2'bXX;
          MEM_WRITE_D = 1'bX;
          ALU_CONTROL_D = 4'bXXXX;
          //ALU_SRC_A = 1'bX;
          ALU_SRC_D = 1'bX;
          JUMP_D = 1'bX; // no jump usage
          BRANCH_D = 1'bX; // no branch usage
          IMM_SRC_D = 3'bXXX;
          REG_WRITE_D = 1'bX;
        end
    endcase
  
endmodule
