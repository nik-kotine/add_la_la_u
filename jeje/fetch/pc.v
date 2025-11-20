module pc(PCF_curr, PCF, CLK, RESET);
  output reg [31:0] PCF_curr;
  input [31:0] PCF;
  input CLK, RESET;
  
  always @ (posedge CLK)
    begin
      if (RESET) PC_curr <= 32'b0;
      else PC_curr <= PC_next;
    end
endmodule
