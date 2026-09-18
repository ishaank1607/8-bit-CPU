// driver to display on the fpga's seven-segment display digits

module seven_dr ( input clk, input [3:0] dig1, input [3:0] dig2, input [3:0] dig3, input [3:0] dig0, output logic [3:0]  an, output logic [6:0] seg);
  
  logic [16:0] counter;
  logic [1:0] digit_sel;
  logic [3:0] val;
  
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
      default: begin
        an = 4'b1111;
        val = 0;
      end
    endcase
    
    case ( val )
      4'h0: seg = 7'b1000000;
      4'h1: seg = 7'b1111001;
      4'h2: seg = 7'b0100100;
      4'h3: seg = 7'b0110000;
      4'h4: seg = 7'b0011001;
      4'h5: seg = 7'b0010010;
      4'h6: seg = 7'b0000010;
      4'h7: seg = 7'b1111000;
      4'h8: seg = 7'b0000000;
      4'h9: seg = 7'b0010000;
      4'hA: seg = 7'b0001000;
      4'hB: seg = 7'b0000011;
      4'hC: seg = 7'b1000110;
      4'hD: seg = 7'b0100001;
      4'hE: seg = 7'b0000110;
      4'hF: seg = 7'b0001110;
      default: seg = 7'b1111111;
    endcase
    
  end
  
  
endmodule
