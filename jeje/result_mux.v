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
