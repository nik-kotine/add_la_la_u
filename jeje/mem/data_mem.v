module data_mem(r_data, res_add, write_data, CLK, MEM_WRITE);
  output [31:0] r_data;
  input [31:0] res_add, write_data;
  input CLK, MEM_WRITE;
  
  reg [31:0] RAM [63:0];
  
  assign r_data = RAM[res_add[31:2]];
  
  always @ (posedge CLK)
    begin
      if (MEM_WRITE) RAM[res_add[31:2]] <= write_data;
    end
endmodule
