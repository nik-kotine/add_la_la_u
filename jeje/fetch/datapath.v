module xd(
    output [31:0] PCF,
    input [31:0] PCF_next,
    input CLK, RESET,
);

// iniciamos con el fokin pc

pc pc_inst(
    .PCF_curr(PCF),
    .PCF(PCF_next),
    .CLK(CLK),
    .RESET(RESET)
)

// pasamos el pc al adder para sumarle 4

adder pc_plus4_inst(
    .Q(PCPlus4F), // mi nuevo pc
    .A(PCF),
    .B(32'd4)
);

// metemos el fokin pc al inst mem
reg [31:0] instF;

ins_mem IMEM(
    .ins(instF),
    .address(PCF)
);

// ahora hay q usar el IFID para guardas las mariconaditas

reg [31:0] insD, PCD, PCPlus4D;

IFID IFID_inst(
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

// ya tengo las mariconaditas en el IFID ahora a la siguiente etapa :333
// el de fokin code

reg [6:0] op;
reg [2:0] f3;
reg [6:0] f7;
reg [4:0] add_1, add_2, add_3;
reg [4:0] rs1D, rs2D, rdD;
reg [24:0] raw_imm;

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

// chucha medio q me olvide de hacer el register file

wire [31:0] rd1, rd2, rdW;

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

// como olvidarse del control unit el culpable de todas mis despgracias
// encima tengo q declarar todas las salidas

reg regWriteD, memWriteD, jumpD, branchD, ALUSrcD;
reg [1:0] resultSrcD;
reg [2:0] immSrcD;
reg [3:0] ALUControlD;

control_unit control_unit_inst(
    .RES_SRC_D(resultSrcD),
    .REG_WRITE_D(regWriteD),
    .MEM_WRITE_D(memWriteD),
    .ALU_CONTROL_D(ALUControlD),
    .ALU_SRC_D(ALUSrcD),
    .IMM_SRC_D(immSrcD),
    .op(op),
    .f3(f3),
    .f7(f7)
);
// walde adapta tu control pls :'3
// supongamos q soy tan pro q ya tengo las señales del control unit
// aqui usamos raw_imm para sacar extImmD

reg [31:0] extImmD;
extender extender_inst(
    .imm(extImmD),
    .raw_imm(raw_imm),
    .immSrc(immSrcD)
);

// bueno ya extendimos ahora toca pasarle las cosas al IDEX osea que ya fue ya

reg [31:0] rd1E, rd2E, pcE, rs1E, rs2E, rdE, extImmE, PCPlus4E;
reg regWriteE, memWriteE, jumpE, branchE, ALUsrcE;
reg [3:0] ALUcontrolE;
reg [1:0] ResultSrcE;

IDEX IDEX_inst(
    .rd1E(rd1E), 
    .rd2E(rd2E), 
    .pcE(pcE), 
    .rs1E(rs1E), 
    .rs2E(rs2E), 
    .rdE(rdE), 
    .extImmE(extImmE), 
    .PCPlus4E(PC_plus_4E),
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
reg [31:0] srcAE;

mux1_alu m1(
    .srcAE(srcAE),
    .rd1E(rd1E),
    .resultW(resultW),
    .aluResultM(aluResultM),
    .forwardAE(forwardAE),
);

// aqui el otro p
reg [31:0] mux2_out;

mux2_alu m2(
    .mux2_out(mux2_out),
    .rd2E(rd2E),
    .resultW(resultW),
    .aluResultM(aluResultM),
    .forwardBE(forwardBE),
);

// mux final para srcBE

wire [31:0] srcBE;
assign srcBE = ALUsrcE ? extImmE : mux2_out;

// add la, la, u time

wire zero;

alu alu_inst(
    .ALUResultE(aluResultE),
    .ZERO(zero),
    .src_A(srcAE),
    .src_B(srcBE),
    .ALUControlE(ALUcontrolE)
);

// ahora si hago la magia del branch

assign PCSrcE = jumpE || (zero && branchE);

// el adder ese para el pc

wire [31:0] PCTargetE;
adder adder_branch(
    .Q(PCTargetE),
    .A(pcE),
    .B(extImmE)
);

// ahora el EXMEM osea execute y memory

reg [31:0] rdM, aluResultM, writeDataM, PCPlus4M;
reg regWriteM, memWriteM;
reg [1:0] ResultSrcM;

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
 
);

endmodule