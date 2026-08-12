// testbench

module tb_add_4bit;
  
  reg[3:0] a;
  reg[3:0] b;
  reg cin;
  
  reg[3:0] sumtest; //testing sum with actual sum operation
  reg couttest; // testing carry out with actual carry operation
  integer passcnt; //counts passes
  integer failcnt; //counts fails
  
  integer i; //i j and k all are integer trackers for the for-loops since
  integer j; // a and b are 4 bit numbers and not decimal
  integer k;
  
  wire[3:0] sum;
  wire cout;
  
  add_4bit instance1 (.a(a),
                      .b(b),
                      .cin(cin),
                      .sum(sum),
                      .cout(cout) );
  
  initial begin
  
  	a = 4'b0000;
  	b = 4'b0000;
  	cin = 0;
    
    sumtest = 0;
    couttest = 0;
    passcnt = 0;
    failcnt = 0;
    
    for (i = 0; i <= 15; i = i + 1) begin
      for (j = 0; j <= 15; j = j + 1) begin
        for (k = 0; k <= 1; k = k + 1) begin
          
          #5;
          
          //actual addition/carry
          
          sumtest = a ^ b ^ cin;
          couttest = (a & b) | (a & cin) | (b & cin);
          
          #5;
          
          if ((sumtest == sum) & (couttest == cout))
          	passcnt = passcnt + 1;
          else
            failcnt = failcnt + 1;
          
          
        end
      end
    end
    $display("PASSES =%d FAILS =%d", passcnt, failcnt);
          
          #5;
    $finish;
    
  end
  
endmodule
  
  
    