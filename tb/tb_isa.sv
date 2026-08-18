// isa test bench

module tb_isa;
  
  reg[7:0] test_instr;
  wire[3:0] test_opc;
  wire[3:0] test_opr;
  
  isa instance1 ( .instruction(test_instr), .opcode(test_opc), .operand(test_opr) );
  
  reg[3:0] exp_opc;
  reg[3:0] exp_opr;
  
  integer i;
  
  integer passcnt;
  integer failcnt;
  
  
  initial begin
    exp_opc = 0;
    exp_opr = 0;
    test_instr = 0;
    
    passcnt = 0;
    failcnt = 0;
    
    for (i = 0; i <= 255; i = i + 1) begin
      test_instr = i;
      
      
      exp_opc = test_instr[7:4];
      exp_opr = test_instr[3:0];
      
      #1;
      
      if ( (exp_opc == test_opc) & (exp_opr == test_opr) ) begin
        passcnt = passcnt + 1;
      end
      else begin
        failcnt = failcnt + 1;
        $display("FAIL | Test instruction = %b, Test Operand = %d, Test Opcode = %d | Expected Operand = %d, Expected Opcode = %d", test_instr, test_opc, test_opr, exp_opc, exp_opr);
        
      end
      
      
      
      
    end
    $display("PASSES = %d, FAILS = %d", passcnt, failcnt);
    $finish;
  end
  
endmodule
    
  