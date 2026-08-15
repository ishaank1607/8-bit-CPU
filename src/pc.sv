// program counter PC

module pc (input clk,
           input reset,
           input load,
           input increment,
           input[7:0] d,
           output logic[7:0] q);
  
  always @(posedge clk) begin
    
    if (reset) begin
      q <= 0;
    end
    else if (load) begin
      q <= d;
    end
    else if (increment) begin
      q <= q + 1;
    end
    
  end
endmodule