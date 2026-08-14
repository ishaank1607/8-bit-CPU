// testbench for 8-bit register

module tb_reg;
  
  reg clk;
  reg[7:0] d_test;
  reg load;
  reg reset;
  wire[7:0] q_test;
  reg[7:0] expected;
  
  
  integer i;
  integer j;
  integer k;
  
  integer passcnt;
  integer failcnt;
  
  reg_8bit instance1 (.clk(clk),
                      .d(d_test),
                      .reset(reset),
                      .load(load),
                      .q(q_test) );
  
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end
  
  initial begin
    expected = 0;
    passcnt = 0;
    failcnt = 0;
    
    d_test = 0;
    reset = 1;
    load = 0;

    @(posedge clk);
    #1;

    reset = 0;
    expected = 0;
    
    for (i = 0; i <= 255; i = i + 1) begin
      for (j = 0; j <= 1; j = j + 1) begin
        for (k = 0; k <= 1; k = k + 1) begin
          
          d_test = i;
          reset = j;
          load = k;
          
          if ( reset ) begin
            expected = 0;
          end
          else if ( load ) begin
            expected = d_test;
          end
          
          @(posedge clk);
          #1;
          
          if ( q_test == expected ) begin
            passcnt = passcnt + 1;
          end
          else begin
            failcnt = failcnt + 1;
            $display("Fail number %d with values d=%b, reset=%d, load=%d, expected=%b, actual=%b", failcnt, d_test, reset, load, expected, q_test);
          end
        end    
        #5;      
      end      
    end    
    $display("PASSES = %d, FAILS = %d", passcnt, failcnt);
    $finish;    
  end  
endmodule