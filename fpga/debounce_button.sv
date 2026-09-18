// debounce for fpga buttons

module debounce_button ( input clk, input button, output logic debounce, output logic pulse);
  
  reg store;
  logic [20:0] counter;
  logic debounce_prev; 
  
  initial begin
    store = 0;
    counter = 0;
    debounce = 0;
  end
  
  always @(posedge clk) begin
    
    if ( (store == button) && (counter == 21'b111111111111111111111) ) 
      
      begin
      debounce <= button;
      end
    
    else if ( store == button ) 
      
      begin
      counter <= counter + 1;
      end
    
    else 
      
      begin
      store <= button;
      counter <= 0;
    end
    
    debounce_prev <= debounce;
    pulse <= debounce && !debounce_prev;
    
  end
endmodule
