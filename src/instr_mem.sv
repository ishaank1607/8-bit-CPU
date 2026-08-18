// instruction memory


module instr_mem (input [7:0] address, output logic [7:0] instruction );
  
  reg [7:0] memory [0:255];
  
  assign instruction = memory[address];
  
  initial begin
    memory[0] = 8'b0001_0001;
    memory[1] = 8'b0010_0010;
    memory[2] = 8'b0011_0011;
    memory[3] = 8'b0100_0100;
    memory[4] = 8'b0101_0101;
    memory[5] = 8'b0110_0110;
    memory[6] = 8'b0111_0111;
    memory[7] = 8'b1000_1000;
  end
  
endmodule