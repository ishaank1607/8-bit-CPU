// Code your testbench here
// or browse Examples


module tb_fadd;
  
  reg a;
  reg b;
  reg cin;
  
  wire sum;
  wire cout;
  
  fadd instance1 ( .in1(a), .in2(b), .cin(cin), .sum(sum), .cout(cout) );
  
  initial begin
    
    a = 0;
    b = 0;
    cin = 0;
    
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (!cout && !sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 0;
    b = 0;
    cin = 1;
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (!cout && sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 1;
    b = 0;
    cin = 0;
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (!cout && sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 1;
    b = 0;
    cin = 1;
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (cout && !sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 0;
    b = 1;
    cin = 0;
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (!cout && sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 0;
    b = 1;
    cin = 1;
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (cout && !sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 1;
    b = 1;
    cin = 0;
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (cout && !sum)
      $display("PASS");
    else
      $display("FAIL");
    
    a = 1;
    b = 1;
    cin = 1;
    
    
    #5;
    $display("a=%b b=%b cin=%b | sum=%b cout=%b",
         a, b, cin, sum, cout);
    
    if (cout && sum)
      $display("PASS");
    else
      $display("FAIL");
    
    $finish;
    
    
  end

endmodule
    