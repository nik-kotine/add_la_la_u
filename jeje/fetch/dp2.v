`timescale 1ns/1ns

module top(
    input CLK, RESET
);

// wires
wire lw_stall, stall_F, stall_D, flush_E, flush_D;
wire PC_Src_E;
wire [31:0] PCF;
wire [1:0] forward_AE, forward_BE;
wire [31:0] PC_Plus4_F, PCF_next;
wire [31:0] result_W;
wire [31:0] ALU_Result_E;
wire [31:0] write_data_E;

// IF/ID wires

wire [31:0] inst_F;
wire [31:0] ins_D, PC_D;
wire [31:0] PCF_D;    
wire [31:0] PC_Plus4_D;


wire [6:0] op, f7;
wire [2:0] f3;
wire [4:0] add_1, add_2, add_3;
wire [24:0] raw_imm;


wire [4:0] rs1_D, rs2_D, rd_D;
wire [31:0] rd_1, rd_2;

wire [1:0] result_Src_D;
wire [2:0] imm_Src_D;
wire [3:0] ALU_Control_D;
wire ALU_Src_D, reg_write_D, mem_write_D, jump_D, branch_D;

wire [31:0] rd1_E, rd2_E, pc_E, ext_Imm_E, ext_Imm_D, PC_Plus4_E;
wire [4:0] rd_W, rs1_E, rs2_E;
wire reg_write_E, mem_write_E, jump_E, branch_E, ALU_Src_E;
wire [3:0] ALU_Control_E;
wire [1:0] result_Src_E;

wire [31:0] ALU_Result_M, write_data_M, PC_Plus4_M;
wire [4:0] rd_M, rd_E;
wire reg_write_M, mem_write_M;
wire [1:0] result_Src_M;

wire [31:0] read_data_M, read_data_W, ALU_Result_W, PC_Plus4_W;
wire reg_write_W;
wire [1:0] result_Src_W;

wire [31:0] src_AE, src_BE, mux2_out;
wire [31:0] PC_Target_E;
wire zero;

assign stall_F = 0;
assign stall_D = 0;
assign flush_D = 0;
assign flush_E = 0;


pc pc_inst(
    .PC_curr(PCF),
    .PC_next(PCF_next),
    .CLK(CLK),
    .RESET(RESET),
    .stallF(stall_F)
);

adder pc_plus_4_inst(
    .Q(PC_Plus4_F),
    .A(PCF),
    .B(32'd4)
);

ins_mem IMEM(
    .ins(inst_F),
    .address(PCF)
);

IFID IFID_inst(
    .insD(ins_D),
    .PCD(PC_D),
    .PCPlus4D(PC_Plus4_D),
    .flushD(flush_D),
    .stallD(stall_D),
    .CLK(CLK),
    .reset(RESET),
    .insF(inst_F),
    .PCPlus4F(PC_Plus4_F),
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
    .ins(ins_D)
);

reg_file RF(
    .r_data_1(rd_1),
    .r_data_2(rd_2),
    .add_1(add_1),
    .add_2(add_2),
    .add_3(rd_W),
    .write_data(result_W),
    .CLK(CLK),
    .RESET(RESET),
    .REG_WRITE_W(reg_write_W)
);

wire [4:0] rs1D = add_1;
wire [4:0] rs2D = add_2;
wire [4:0] rdD  = add_3;

control_unit control_unit_inst(
    .RES_SRC_D(result_Src_D),
    .REG_WRITE_D(reg_write_D),
    .MEM_WRITE_D(mem_write_D),
    .ALU_CONTROL_D(ALU_Control_D),
    .ALU_SRC_D(ALU_Src_D),
    .IMM_SRC_D(imm_Src_D),
    .JUMP_D(jump_D),
    .BRANCH_D(branch_D),
    .op(op),
    .f3(f3),
    .f7(f7)
);

extender extender_inst(
    .imm(ext_Imm_D),
    .raw_imm(raw_imm),
    .IMM_SRC(imm_Src_D)
);

IDEX IDEX_inst(
    .rd1E(rd1_E),
    .rd2E(rd2_E),
    .pcE(pc_E),
    .rs1E(rs1_E),
    .rs2E(rs2_E),
    .rdE(rd_E),
    .extImmE(ext_Imm_E),
    .PCPlus4E(PC_Plus4_E),
    .regWriteE(reg_write_E),
    .memWriteE(mem_write_E),
    .jumpE(jump_E),
    .branchE(branch_E),
    .ALUsrcE(ALU_Src_E),
    .ALUcontrolE(ALU_Control_E),
    .ResultSrcE(result_Src_E),
    .rd1(rd_1),
    .rd2(rd_2),
    .pcD(PC_D),
    .rs1D(rs1_D),
    .rs2D(rs2_D),
    .rdD(rd_D),
    .extImmD(ext_Imm_D),
    .PCPlus4D(PC_Plus4_D),
    .flushE(flush_E),
    .regWriteD(reg_write_D),
    .memWriteD(mem_write_D),
    .jumpD(jump_D),
    .branchD(branch_D),
    .ALUsrcD(ALU_Src_D),
    .CLK(CLK),
    .reset(RESET),
    .ALUcontrolD(ALU_Control_D),
    .ResultSrcD(result_Src_D)
);

mux1_alu m1(    
    .srcAE(src_AE),
    .rd1E(rd1_E),
    .resultW(result_W),
    .aluResultM(ALU_Result_M),
    .forwardAE(forward_AE)
);

mux2_alu m2(
    .mux2_out(mux2_out),
    .write_data_E(write_data_E),
    .rd2E(rd2_E),
    .resultW(result_W),
    .aluResultM(ALU_Result_M),
    .forwardBE(forward_BE)
);

assign src_BE = ALU_Src_E ? ext_Imm_E : mux2_out;

alu alu_inst(
    .ALUResultE(ALU_Result_E),
    .ZERO(zero),
    .src_A(src_AE),
    .src_B(src_BE),
    .ALUControlE(ALU_Control_E)
);

adder adder_branch(
    .Q(PC_Target_E),
    .A(pc_E),
    .B(ext_Imm_E)
);
assign PC_Src_E = jump_E | (zero & branch_E);

EXMEM exmem_inst(
    .rdM(rd_M),
    .aluResultM(ALU_Result_M),
    .writeDataM(write_data_M),
    .PCPlus4M(PC_Plus4_M),
    .regWriteM(reg_write_M),
    .memWriteM(mem_write_M),
    .ResultSrcM(result_Src_M),
    .regWriteE(reg_write_E),
    .memWriteE(mem_write_E),
    .CLK(CLK),
    .ResultSrcE(result_Src_E),
    .aluResultE(ALU_Result_E),
    .writeDataE(write_data_E),
    .PCPlus4E(PC_Plus4_E),
    .rdE(rd_E)
);

data_mem data_mem_inst(
    .r_data(read_data_M),
    .write_data(write_data_M),
    .res_add(ALU_Result_M),
    .MEM_WRITE(mem_write_M),
    .CLK(CLK)
);

MEMWB MEMWB_inst(
    .readDataW(read_data_W),
    .aluResultW(ALU_Result_W),
    .rdW(rd_W),
    .PC_plus_4W(PC_Plus4_W),
    .regWriteW(reg_write_W),
    .ResultSrcW(result_Src_W),
    .readDataM(read_data_M),
    .aluResultM(ALU_Result_M),
    .rdM(rd_M),
    .PC_plus_4M(PC_Plus4_M),
    .regWriteM(reg_write_M),
    .CLK(CLK),
    .ResultSrcM(result_Src_M)
);

result_mux result_mux_inst(
    .resultW(result_W),
    .ALUResultM(ALU_Result_W),
    .readDataW(read_data_W),
    .PCPlus4W(PC_Plus4_W),
    .RES_SRC_W(result_Src_W)
);

pc_mux pc_mux_inst(
    .PC_next(PCF_next),
    .PCPlus4F(PC_Plus4_F),
    .PC_target(PC_Target_E),
    .PC_SRC(PC_Src_E)
);

forwarding forwarding_instA(
    .forwardNE(forward_AE),
    .rsXE(rs1_E),
    .rdM(rd_M),
    .rdW(rd_W),
    .regWriteM(reg_write_M),
    .regWriteW(reg_write_W)
);

forwarding forwarding_instB(
    .forwardNE(forward_BE),
    .rsXE(rs2_E),
    .rdM(rd_M),
    .rdW(rd_W),
    .regWriteM(reg_write_M),
    .regWriteW(reg_write_W)
);

stallingUnit stalling_inst(
    .lwStall(lw_stall),
    .stallF(stall_F),
    .stallD(stall_D),
    .rs1D(rs1_D),
    .rs2D(rs2_D),
    .rdE(rd_E),
    .resultSrcE(result_Src_E)
);

flushingUnit flushing_inst(
    .flushD(flush_D),
    .flushE(flush_E),
    .lwStall(lw_stall),
    .PCSrcE(PC_Src_E)
);

    reg [7:0] cycle_cnt = 0;
    
    always @(posedge CLK) begin
        cycle_cnt <= cycle_cnt + 1;
    
        if (cycle_cnt > 5) begin
            $display("PC=%h | x9(s1)=%h | x5(t0)=%h",
                     PCF,
                     RF.rf[9],
                     RF.rf[5]);
        end
    end
    
    always @(posedge CLK) begin
    $display("PCF=%h | stall_F=%b | RESET=%b | PC_next=%h",
             PCF, stall_F, RESET, PCF_next);
end

    

endmodule
