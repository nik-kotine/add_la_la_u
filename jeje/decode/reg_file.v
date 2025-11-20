module reg_file(r_data_1, r_data_2, add_1, add_2, add_3, write_data, CLK, REG_WRITE_W);
  output [31:0] r_data_1, r_data_2;
  input CLK, REG_WRITE_W;
  input [4:0] add_1, add_2, add_3;
  input [31:0] write_data;
  
  reg [31:0] rf [31:0];
  
  assign r_data_1 = (add_1 == 5'b0) ? (32'b0) : (rf[add_1]);
  assign r_data_2 = (add_2 == 5'b0) ? (32'b0) : (rf[add_2]);
  
  always @ (negedge CLK)
    begin
      if ((REG_WRITE_W) && (add_3 != 5'b0))
        rf[add_3] <= write_data;
    end
endmodule
