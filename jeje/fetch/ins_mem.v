module ins_mem(ins, address);
  output [31:0] ins;
  input [31:0] address;

  reg [31:0] IMEM [0:63];

  assign ins = IMEM[address[31:2]];
  
  initial begin
    $readmemh("program.hex", IMEM);
  end
endmodule
