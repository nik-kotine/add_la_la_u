// Code your testbench here
// or browse Examples

module tb();
  reg CLK, RESET;
  
  top test(
    .CLK(CLK),
    .RESET(RESET)
  );
  
  always #5 CLK = ~CLK;
  
  initial begin
    CLK = 1; RESET = 1; #5
    RESET = 0;
    #10000;
    $finish;
  end
  
  initial begin
    $dumpfile("test.vcd");
    $dumpvars();
  end
endmodule