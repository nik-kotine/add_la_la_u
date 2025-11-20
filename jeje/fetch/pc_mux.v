
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
