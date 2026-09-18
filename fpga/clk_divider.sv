// basys 3 clk divider

module clk_div ( input reset, input clock, output logic clk);
  
  logic [24:0] counter;
  
  initial begin
    counter = 0;
    clk = 0;
  end
    
  always @(posedge clock) begin
    counter <= counter + 1;
    if (reset)
      clk <= 0;
      counter <= 0;
    else if ( (counter == 25'b1111111111111111111111111) )
      begin
      clk <= ~clk;
      counter <= 0;
      end
    end
  
endmodule
