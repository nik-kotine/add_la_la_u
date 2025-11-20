module result_mux(resultW, ALUResultM, readDataW, PCPlus4W, RES_SRC);
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
