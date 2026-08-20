// instruction memory


module instr_mem #(
    parameter PROGRAM_FILE = "program.hex"
) (
    input [7:0] address,
    output logic [7:0] instruction
);

  reg [7:0] memory [0:255];

  assign instruction = memory[address];

  initial begin
    $readmemh(PROGRAM_FILE, memory);
  end

endmodule
