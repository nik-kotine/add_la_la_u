`timescale 1ns/1ns

module IDEX (
    output reg [31:0] rd1E, rd2E, pcE, extImmE,PCPlus4E,
    output reg regWriteE, memWriteE, jumpE, branchE, ALUsrcE,
    output reg [4:0] rs1E, rs2E,rdE,
    output reg [3:0] ALUcontrolE,
    output reg [1:0] ResultSrcE,
    input [31:0] rd1, rd2, pcD,  extImmD,PCPlus4D,
    input [4:0] rs1D, rs2D, rdD,
    input flushE, regWriteD, memWriteD, jumpD, branchD, ALUsrcD, CLK, reset,
    input [3:0] ALUcontrolD,
    input [1:0] ResultSrcD
    );

    always @ (posedge CLK) begin
        if (reset || flushE) begin
            rd1E <= 32'b0;
            rd2E <= 32'b0;
            pcE <= 32'b0;
            rs1E <= 5'b0;
            rs2E <= 5'b0;
            rdE <= 5'b0;
            extImmE <= 32'b0;
            PCPlus4E <= 32'b0;
            regWriteE <= 1'b0;
            memWriteE <= 1'b0;
            jumpE <= 1'b0;
            branchE <= 1'b0;
            ALUsrcE <= 1'b0;
            ALUcontrolE <= 4'b0;
            ResultSrcE <= 2'b0;
        end
        else begin
            rd1E <= rd1;
            rd2E <= rd2;
            pcE  <= pcD;
            rs1E <= rs1D;
            rs2E <= rs2D;
            rdE  <= rdD;
            extImmE <= extImmD;
            PCPlus4E <= PCPlus4D;
            regWriteE <= regWriteD;
            memWriteE <= memWriteD;
            jumpE <= jumpD;
            branchE <= branchD;
            ALUsrcE <= ALUsrcD;
            ALUcontrolE <= ALUcontrolD;
            ResultSrcE <= ResultSrcD;
        end
    end
endmodule

module ins_mem(ins, address);
  output [31:0] ins;
  input [31:0] address;

  reg [31:0] IMEM [0:63];

  assign ins = IMEM[address[31:2]];
  
  initial begin
    $readmemh("/home/yaarii/Documentos/utec/arqui/add_la_la_u/program.hex", IMEM);
  end
endmodule


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

module reg_file(r_data_1, r_data_2, add_1, add_2, add_3, write_data, CLK, REG_WRITE_W, RESET);
  output [31:0] r_data_1, r_data_2;
  input CLK, REG_WRITE_W, RESET;
  input [4:0] add_1, add_2, add_3;
  input [31:0] write_data;
  
  reg [31:0] rf [31:0];
  
  assign r_data_1 = (add_1 == 5'b0) ? (32'b0) : (rf[add_1]);
  assign r_data_2 = (add_2 == 5'b0) ? (32'b0) : (rf[add_2]);
  integer i;
 
  always @ (posedge CLK)
    begin      
      if(RESET) begin 
          for (i = 0; i < 32; i = i + 1) begin
            rf[i] <= 32'b0;
          end
      end else begin 
          if ((REG_WRITE_W) && (add_3 != 5'b0)) 
                rf[add_3] <= write_data;
            end
      end
      
endmodule

module EXMEM (
    output reg [31:0] aluResultM, writeDataM, PCPlus4M,
    output reg regWriteM, memWriteM,
    output reg [1:0] ResultSrcM,
    output reg [4:0] rdM,
    input regWriteE, memWriteE, CLK,
    input [1:0] ResultSrcE,
    input [31:0] aluResultE, writeDataE, PCPlus4E, 
    input [4:0] rdE
);

    always @ (posedge CLK) begin
        rdM <= rdE;
        aluResultM <= aluResultE;
        writeDataM <= writeDataE;
        PCPlus4M <= PCPlus4E;
        regWriteM <= regWriteE;
        memWriteM <= memWriteE;
        ResultSrcM <= ResultSrcE;
    end
endmodule

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

module mux1_alu (
    output reg [31:0] srcAE,
    input [31:0] rd1E, resultW, aluResultM,
    input [1:0] forwardAE
);
    always @ (*) begin
        casez (forwardAE)
            2'b00: srcAE = rd1E;
            2'b01: srcAE = resultW; 
            2'b10: srcAE = aluResultM;
            default: srcAE = rd1E;
        endcase
    end
endmodule

module mux2_alu(
    output reg [31:0] mux2_out, write_data_E,
    input [31:0] rd2E, resultW, aluResultM,
    input [1:0] forwardBE
);
    always @ (*) begin
        casez (forwardBE)
            2'b00: mux2_out = rd2E;
            2'b01: mux2_out = resultW; 
            2'b10: mux2_out = aluResultM;
            default: mux2_out = rd2E;
        endcase
        write_data_E <= resultW;
    end
endmodule


module IFID (
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
        else if (stallD) begin
        end
        else begin
            insD <= insF;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end
    
    always @(posedge CLK) begin
    $display("IFID: stallD=%b reset=%b flushD=%b insF=%h insD=%h",
        stallD, reset, flushD, insF, insD);
end


endmodule

module pc(PC_curr, PC_next, CLK, RESET, stallF);
  output reg [31:0] PC_curr;
  input [31:0] PC_next;
  input CLK, RESET, stallF;
  
  always @ (posedge CLK)
    begin
      if (RESET) PC_curr <= 32'b0;
      else if (!stallF) begin
            PC_curr <= PC_next;
        end
    end
endmodule

// ===================
// pc_mux
// ===================
module pc_mux(PC_next, PCPlus4F, PC_target, PC_SRC);
  input [31:0] PCPlus4F, PC_target;
  input PC_SRC;
  output reg [31:0] PC_next;
  
  always @ (*)
    case (PC_SRC)
      1'b0: PC_next = PCPlus4F;
      1'b1: PC_next = PC_target;
      default: PC_next = PCPlus4F;
    endcase
endmodule


module MEMWB(
    output reg [31:0] readDataW, aluResultW, PC_plus_4W,
    output reg [4:0] rdW,
    output reg regWriteW,
    output reg [1:0] ResultSrcW,
    input [31:0] readDataM,
    input [31:0] aluResultM,  PC_plus_4M,
    input regWriteM, CLK,
    input [1:0] ResultSrcM,
    input [4:0] rdM
);
    always @ (posedge CLK) begin
        readDataW <= readDataM;
        aluResultW <= aluResultM;
        rdW <= rdM;
        PC_plus_4W <= PC_plus_4M;
        regWriteW <= regWriteM;
        ResultSrcW <= ResultSrcM;
    end
endmodule

module adder(Q, A, B);
  output [31:0] Q;
  input [31:0] A, B;
  assign Q = A + B;
endmodule

module data_mem(r_data, res_add, write_data, CLK, MEM_WRITE);
  output [31:0] r_data;
  input [31:0] res_add, write_data;
  input CLK, MEM_WRITE;
  
  reg [31:0] RAM [63:0];
  
  assign r_data = RAM[res_add[31:2]];
  
  always @ (posedge CLK)
    begin
      if (MEM_WRITE) RAM[res_add[31:2]] <= write_data;
    end
endmodule

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
          ALU_SRC_D = 1'b1; // immediate
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
        begin
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

module result_mux(resultW, ALUResultM, readDataW, PCPlus4W, RES_SRC_W);
  output reg [31:0] resultW;
  input [31:0] ALUResultM, readDataW, PCPlus4W;
  // input [31:0] PC_target;
  input [1:0] RES_SRC_W;
  
  always @ (*)
    begin
      case (RES_SRC_W)
        2'b00: resultW = ALUResultM;
        2'b01: resultW = readDataW;
        2'b10: resultW = PCPlus4W;
        //2'b11: resultW = PC_target;
        default: resultW = ALUResultM;
      endcase
    end
endmodule

module flushingUnit(
    output flushD, flushE,
    input lwStall, PCSrcE
);
    assign flushD = PCSrcE;
    assign flushE = lwStall | PCSrcE;

endmodule

module forwarding(
  output reg [1:0] forwardNE,
  input [4:0] rsXE, rdM, rdW,
  input regWriteM, regWriteW
);
  
  always @ (*) begin
    if (((rsXE == rdM) & regWriteM) & (rsXE != 0)) begin
      forwardNE = 2'b10;
    end
    else if (((rsXE == rdW) & regWriteW) & (rsXE != 0)) begin
      forwardNE = 2'b01;
    end
    else begin 
    	forwardNE = 2'b00;
    end
  end
endmodule

module stallingUnit(
    output wire lwStall, stallF, stallD,
    input [1:0] resultSrcE,
    input [4:0] rs1D, rs2D, rdE
);

assign lwStall = resultSrcE[0] & ((rs1D == rdE) | (rs2D == rdE));
assign stallF = lwStall;
assign stallD = lwStall;
endmodule: