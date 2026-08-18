// isa design

module isa (input [7:0] instruction, output logic[3:0] opcode, output logic[3:0] operand);
  
  assign opcode = instruction[7:4];
  assign operand = instruction[3:0];
  
  
endmodule