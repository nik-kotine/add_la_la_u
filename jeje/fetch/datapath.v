`timescale 1ns/1ns

module xd(
    output [31:0] PCF,
    input [31:0] PCF_next,
    input CLK, RESET
);

wire lwStall, stallF, stallD, flushE;
reg [31:0] insD, PCD, PCPlus4D, writeDataE, PCPlus4F;
reg [31:0] instF;
reg [6:0] op, f7;
reg [2:0] f3;
reg [4:0] add_1, add_2, add_3, rs1D, rs2D, rdD;
reg [24:0] raw_imm;
wire [31:0] rd1, rd2, rdW;
reg [1:0] resultSrcD;
reg [2:0] immSrcD;
reg [3:0] ALUControlD;
reg [31:0] rd1E, rd2E, pcE, rs1E, rs2E, rdE, extImmE, PCPlus4E;
reg regWriteE, memWriteE, jumpE, branchE, ALUsrcE, regWriteD, memWriteD, jumpD, branchD, ALUSrcD;
reg [3:0] ALUcontrolE;
reg [1:0] ResultSrcE;
reg [31:0] extImmD;
reg [31:0] mux2_out;
reg [31:0] srcAE;
wire zero;
wire [31:0] srcBE;
reg [31:0] rdM, aluResultM, writeDataM, PCPlus4M;
reg regWriteM, memWriteM;
reg [1:0] ResultSrcM;
wire [31:0] PCTargetE;
reg [31:0] readDataW, aluResultW, rdW, PCPlus4W;
reg regWriteW;
reg [1:0] ResultSrcW;
reg [31:0] readDataM;


pc pc_inst( // TODO: AGREGAR stallF
    .PCF_curr(PCF),
    .PCF(PCF_next),
    .CLK(CLK),
    .RESET(RESET),
    .stallF(stallF)
);

// pasamos el pc al adder para sumarle 4

adder pc_plus_4_inst(
    .Q(PCPlus4F),
    .A(PCF),
    .B(32'd4)
);


ins_mem IMEM(
    .ins(instF),
    .address(PCF)
);


IFID IFID_inst( // CORREGIR LOGICA STALLING y flushin walde matate:3
    .insD(insD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .flushD(flushD),
    .stallD(stallD),
    .CLK(CLK),
    .reset(RESET),
    .insF(instF),
    .PCPlus4F(PCPlus4F),
    .PCF(PCF)
);



decoder decoder_inst(
    .op(op),
    .f3(f3),
    .f7(f7),
    .add_1(add_1),
    .add_2(add_2),
    .add_3(add_3),
    .raw_imm(raw_imm), 
    .ins(insD)
);


reg_file reg_file_inst(
    .r_data_1(rd1),
    .r_data_2(rd2),
    .add_1(add_1),
    .add_2(add_2),
    .add_3(rdW),
    .write_data(resultW),
    .CLK(CLK),
    .REG_WRITE_W(regWriteW)
);

// ahora este neurotico duplica el a1(rs1D), a2(rs2D) y a3(rdD)

always @ (*) begin
    rs1D = add_1;
    rs2D = add_2;
    rdD = add_3;
end


control_unit control_unit_inst(
    .RES_SRC_D(resultSrcD),
    .REG_WRITE_D(regWriteD),
    .MEM_WRITE_D(memWriteD),
    .ALU_CONTROL_D(ALUControlD),
    .ALU_SRC_D(ALUSrcD),
    .IMM_SRC_D(immSrcD),
    .JUMP_D(jumpD),
    .BRANCH_D(branchD),
    .op(op),
    .f3(f3),
    .f7(f7)
);

extender extender_inst(
    .imm(extImmD),
    .raw_imm(raw_imm),
    .immSrc(immSrcD)
);

// bueno ya extendimos ahora toca pasarle las cosas al IDEX osea que ya fue ya



IDEX IDEX_inst(
    .rd1E(rd1E), 
    .rd2E(rd2E), 
    .pcE(pcE), 
    .rs1E(rs1E), 
    .rs2E(rs2E), 
    .rdE(rdE), 
    .extImmE(extImmE), 
    .PCPlus4E(PCPlus4E),
    .regWriteE(regWriteE),
    .memWriteE(memWriteE),
    .jumpE(jumpE),
    .branchE(branchE),
    .ALUsrcE(ALUsrcE),
    .ALUcontrolE(ALUcontrolE),
    .ResultSrcE(ResultSrcE),
    .rd1(rd1),
    .rd2(rd2),
    .pcD(PCD),
    .rs1D(rs1D),
    .rs2D(rs2D),
    .rdD(rdD),
    .extImmD(extImmD),
    .PC_plus_4D(PCPlus4D),
    .flushE(flushE),
    .regWriteD(regWriteD),
    .memWriteD(memWriteD),
    .jumpD(jumpD),
    .branchD(branchD),
    .ALUsrcD(ALUSrcD),
    .CLK(CLK),
    .reset(RESET),
    .ALUcontrolD(ALUControlD),
    .ResultSrcD(ResultSrcD)
);

// aqui vamos preparando el primer valor para el mux

mux1_alu m1(
    .srcAE(srcAE),
    .rd1E(rd1E),
    .resultW(resultW),
    .aluResultM(aluResultM),
    .forwardAE(forwardAE)
);

// aqui el otro 

mux2_alu m2(
    .mux2_out(mux2_out),
    .rd2E(rd2E),
    .resultW(resultW),
    .aluResultM(aluResultM),
    .forwardBE(forwardBE)
);

// mux final para srcBE

assign srcBE = ALUsrcE ? extImmE : mux2_out;

// add la, la, u time


alu alu_inst(
    .ALUResultE(aluResultE),
    .ZERO(zero),
    .src_A(srcAE),
    .src_B(srcBE),
    .ALUControlE(ALUcontrolE)
);

assign PCSrcE = jumpE || (zero && branchE);

// el adder ese para el pc


adder adder_branch(
    .Q(PCTargetE),
    .A(pcE),
    .B(extImmE)
);

// ahora el EXMEM osea execute y memory



EXMEM exmem_inst(
    .rdM(rdM),
    .aluResultM(aluResultM),
    .writeDataM(writeDataM),
    .PCPlus4M(PCPlus4M),
    .regWriteM(regWriteM),
    .memWriteM(memWriteM),
    .ResultSrcM(ResultSrcM),
    .regWriteE(regWriteE),
    .memWriteE(memWriteE),
    .CLK(CLK),
    .ResultSrcE(ResultSrcE),
    .aluResultE(aluResultE),
    .writeDataE(writeDataE),
    .PCPlus4E(PCPlus4E),
    .rdE(rdE)
);

// toca el data memory :3


data_mem data_mem_inst(
    .r_data(readDataM),
    .write_data(writeDataM),
    .res_add(aluResultM),
    .MEM_WRITE(memWriteM),
    .CLK(CLK)
);

// ahora el MEMWB osea memory y write back



MEMWB MEMWB_inst(
    .readDataW(readDataW),
    .aluResultW(aluResultW),
    .rdW(rdW),
    .PC_plus_4W(PCPlus4W),
    .regWriteW(regWriteW),
    .ResultSrcW(ResultSrcW),
    .readDataM(readDataM),
    .aluResultM(aluResultM),
    .rdM(rdM),
    .PC_plus_4M(PCPlus4M),
    .regWriteM(regWriteM),
    .CLK(CLK),
    .ResultSrcM(ResultSrcM)
);

// finalmente el mux del write back

result_mux result_mux_inst(
    .resultW(resultW),
    .ALUResultM(aluResultW),
    .readDataW(readDataW),
    .PCPlus4W(PCPlus4W),
    .RES_SRC_W(ResultSrcW)
);

// el pc mux :3

pc_mux pc_mux_inst(
    .PC_next(PCF_next),
    .PCPlus4F(PCPlus4F),
    .PCTargetE(PCTargetE),
    .PCSrcE(PCSrcE)
);

// hazard unit :V

// :3333

// para forwardAE 
forwarding forwarding_instA(
    .forwardNE(forwardAE),
    .rsXE(rs1E),
    .rdM(rdM),
    .rdW(rdW),
    .regWriteM(regWriteM),
    .regWriteW(regWriteW)
);

// para forwardBE

forwarding forwarding_instB(
    .forwardNE(forwardBE),
    .rsXE(rs2E),
    .rdM(rdM),
    .rdW(rdW),
    .regWriteM(regWriteM),
    .regWriteW(regWriteW)
);

// stalling unit 7w7


stalling stalling_inst(
    .lwStall(lwStall),
    .stallF(stallF),
    .stallD(stallD),
    .rs1D(rs1D),
    .rs2D(rs2D),
    .rdE(rdE)
);

flushing flushing_inst(
    .flushD(flushD),
    .flushE(flushE),
    .lwStall(lwStall),
    .PCSrcE(PCSrcE)
);
endmodule