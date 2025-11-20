
// Code your design here

// ===================
// pc_mux
// ===================
module pc_mux(PC_next, PCPlus4F, PC_target, ALU_result, PC_SRC);
  input [31:0] PCPlus4F, PC_target, ALU_result;
  input PC_SRC;
  output reg [31:0] PC_next;
  
  always @ (*)
    case (PC_SRC)
      1'b0: PC_next = PCPlus4F;
      1'b1: PC_next = PC_target;
      default: PC_next = PCPlus4F;
    endcase
endmodule
