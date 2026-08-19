// testbench for acc input mux

module tb_accmux;
  
  reg[1:0] srct;
  reg[7:0] alut;
  reg[7:0] regt;
  reg[7:0] inpt;
  
  wire [7:0] acct;
  
  
  acc_mux instance1 ( .src(srct), .alu_data(alut), .reg_data(regt), .input_data(inpt), .acc_data(acct) );
  
  reg[7:0] exp_out;
  integer i;
  integer j;
  integer k;
  integer l;
  
  integer passcnt;
  integer failcnt;
  
  initial begin
    srct = 0;
    alut = 0;
    regt = 0;
    inpt = 0;
    passcnt = 0;
    failcnt = 0;
    
    for (i = 0; i <= 3; i = i + 1) begin
      for (j = 0; j <= 255; j = j + 1) begin

        srct = i;
        alut = 8'h00;
        regt = 8'h00;
        inpt = 8'h00;

        case (srct)
          2'b00: begin
            alut = j;
            exp_out = alut;
          end

          2'b01: begin
            regt = j;
            exp_out = regt;
          end

          2'b10: begin
            inpt = j;
            exp_out = inpt;
          end

          default: begin
            exp_out = 8'h00;
          end
        endcase

        
        if (acct != exp_out) begin
          failcnt = failcnt + 1;
          $display("FAIL | Src = %b, alu data = %b, reg data = %b, input data = %b, expected output = %b, actual output = %b", srct, alut, regt, inpt, exp_out, acct);
        end
        else
          passcnt = passcnt + 1;
            
            
          
      end
    end
    $display("PASSES = %d, FAILS = %d", passcnt, failcnt);
    $finish;
  end
endmodule