module fetch_cycle(
    output [31:0] PC_curr,
    output [31:0] PC_next,
    output [31:0] PC_plus_4,
    output [31:0] PC_target,
    output [31:0] instruction,
    input CLK, RESET,
    input PCSrcE, // del execute stage
    input stallF, stallD, flushD,
    input [31:0] imm,
  );

// TODO: implement ts

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

endmodule