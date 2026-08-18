// tb for instruction memory

module tb_instr_mem;
  
  reg[7:0] addr;
  wire[7:0] instr;
  
  instr_mem instance1 (.address(addr),
                       .instruction(instr) );
  
  
  reg[7:0] exp_instr;
  reg [7:0] mem_test [0:255];
  integer i;
  
  integer passcnt;
  integer failcnt;
  
  initial begin
    
    addr = 0;
    passcnt = 0;
    failcnt = 0;
    
    mem_test[0] = 8'b0001_0001;
    mem_test[1] = 8'b0010_0010;
    mem_test[2] = 8'b0011_0011;
    mem_test[3] = 8'b0100_0100;
    mem_test[4] = 8'b0101_0101;
    mem_test[5] = 8'b0110_0110;
    mem_test[6] = 8'b0111_0111;
    mem_test[7] = 8'b1000_1000;
    
    for (i = 0; i <= 7; i = i + 1) begin
      addr = i;
      exp_instr = mem_test[addr];
      
      if (exp_instr == instr)
        passcnt = passcnt + 1;
      else begin
        failcnt = failcnt + 1;
        $display("FAIL: Address = %b, Expected Instruction = %b, Actual Instruction = %b", addr, exp_instr, instr);
      
      end
    end
      
    $display("PASS = %d, FAILS = %d", passcnt, failcnt);
    $finish;
    
  end
endmodule