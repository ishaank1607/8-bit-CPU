// design for 8-bit register


module reg_8bit ( input clk, input reset, input load, input [7:0] d, output logic [7:0] q );
  
  
  always @(posedge clk) begin
    if ( reset )
      q <= 0;
    else if ( load )
      q <= d;
    
  end
endmodule