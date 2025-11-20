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
