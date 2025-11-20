module forwarding(
  output reg [1:0] forwardNE,
  input [4:0] rsXE, rdM, rdW,
  input regWriteM, regWriteW
);
  
  always @ (*) begin
    if (((rsXE == rdM) & regWriteM) & (rsXE != 0)) begin
      forwardNE <= 2'b10;
    end
    else if (((rsXE == rdW) & regWriteW) & (rsXE != 0)) begin
      forwardNE <= 2'b01;
    end
    else begin 
    	forwardNE <= 2'b00;
    end
  end
endmodule