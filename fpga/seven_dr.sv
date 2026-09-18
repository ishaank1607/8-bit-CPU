// driver to display on the fpga's seven-segment display digits

module seven_dr ( input clk, input [3:0] dig1, input [3:0] dig2, input [3:0] dig3, input [3:0] dig0, output logic [3:0]  an, output logic [3:0] val);
  
  logic [16:0] counter;
  logic [1:0] digit_sel;
  
  initial begin
    counter = 0;
  end
    
  always @(posedge clk) begin
    counter <= counter + 1;
    
    
    if ( (counter == 17'b11111111111111111) )
      begin
      counter <= 0;
      end
    
  end
  
  assign digit_sel = counter[16:15];
  
  always @(*) begin
    case ( digit_sel )
      2'b00: begin
        an = 4'b1110;
        val = dig0;
      end
      2'b01: begin
        an = 4'b1101;
        val = dig1;
      end
      2'b10: begin
        an = 4'b1011;
        val = dig2;
      end
      2'b11: begin
        an = 4'b0111;
        val = dig3;
      end
    endcase
  end
  
  
endmodule
