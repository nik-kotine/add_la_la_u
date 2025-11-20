module decode_cycle (
    
);
    
// decoder
  decoder DEC(
    .op(op),
    .f3(f3),
    .f7(f7),
    .add_1(add_1),
    .add_2(add_2),
    .add_3(add_3),
    .raw_imm(raw_imm),
    .ins(instruction)
  );


endmodule