// design for flags register - latches Z and C only when an ALU op actually commits its
// result to the accumulator, and holds its value on every other cycle (LOAD, STORE, IN,
// OUT, JMP, JZ, JC, NOP) so JZ/JC test the result of the last arithmetic/logic instruction
// instead of whatever the ALU happens to be live-computing on the current cycle.

module flags ( input clk,
               input reset,
               input load,
               input z_in,
               input c_in,
               output logic zflag,
               output logic cflag );
  always @(posedge clk) begin
    if ( reset ) begin
      zflag <= 0;
      cflag <= 0;
    end
    else if ( load ) begin
      zflag <= z_in;
      cflag <= c_in;
    end
  end
endmodule
