// design for accumulator

module acc ( input clk, input reset, input load, input [7:0] d, output logic [7:0] q );
  always @(posedge clk) begin
    if ( reset )
      q <= 0;
    else if ( load )
      q <= d;
    
  end
endmodule

// i see no need for tb. this was copied directly from reg_8bit.sv, so there's really no reason to write another testbench.
