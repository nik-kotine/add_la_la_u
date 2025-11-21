module pc(PCF_curr, PCF, CLK, RESET, stallF);
  output reg [31:0] PCF_curr;
  input [31:0] PCF;
  input CLK, RESET, stallF;
  
  always @ (posedge CLK)
    begin
      if(!stallF) begin
        PCF_curr <= PCF;
      end
      else begin
      end
      
      if (RESET) PC_curr <= 32'b0;
      else PC_curr <= PC_next;

    end
endmodule
