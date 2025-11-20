module adder(Q, A, B);
  output [31:0] Q;
  input [31:0] A, B;
  assign Q = A + B;
endmodule
