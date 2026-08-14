// testbench for 8-bit ALU

module tb_alu_8bit;
  
  reg[7:0] a;
  reg[7:0] b;
  reg cin;
  reg[2:0] op;
  
  reg[8:0] addtemp;

  reg [8:0] a9; //I used these to force a and b to be 5-bit numbers for add. So basically ensures the proper sizes 
  reg [8:0] b9; // for checking their results
  
  wire[7:0] sum;
  wire cout;
  wire zero;
  wire negative;
  wire overflow;
  
  reg[7:0] expectresult;//testing sum/sub with actual operation
  reg expectc; // testing carry out with actual carry operation
  reg expectz;
  reg expectn;
  reg expectv;
  
  integer passcnt; //counts passes
  integer failcnt; //counts fails
  
  integer i; //i j and k all are integer trackers for the for-loops since
  integer j; // a and b are 4 bit numbers and not decimal
  integer k;
  integer l;
  
  alu_8bit instance1 (.A(a),
                      .B(b),
                      .Cin(cin),
                      .result(sum),
                      .C(cout),
                      .opcode(op),
                      .Z(zero),
                      .N(negative),
                      .V(overflow) );
  
  initial begin
  
  	a = 8'b0000000;
    b = 8'b0000000;
    cin = 0;
    op = 3'b000;
    expectc = 0;
    
    passcnt = 0;
    failcnt = 0;
    
    for (i = 0; i <= 255; i = i + 1) begin
      for (j = 0; j <= 255; j = j + 1) begin
        for (k = 0; k <= 1; k = k + 1) begin
          for (l = 0; l <= 7; l = l + 1) begin
            
            a = i;
            b = j;
            cin = k;
            op = l;
            
            
            #5;

            case(l)
                3'b000: begin
                  a9 = {1'b0, a};
                  b9 = {1'b0, b};
                  addtemp = a9  + b9 + cin; 
                  expectresult =  addtemp[7:0];
                  expectc = addtemp[8];
                end
                
                3'b001: begin
                  expectresult = a - b;
                  expectc = (a >= b);
                end
                
                3'b010: begin
                  expectresult = a & b; 
                  expectc = 0;
                end
                
                3'b011: begin 
                  expectresult = a | b; 
                  expectc = 0;
                end
                
                3'b100: begin 
                  expectresult = a ^ b; 
                  expectc = 0;
                end
                
                3'b101: begin
                  expectresult = ~a; 
                  expectc = 0;
                end
                
                3'b110: begin
                  expectresult = (a << 1); 
                  expectc = a[7];
                end
                
                3'b111: begin
                  expectresult = (a >> 1); 
                  expectc = a[0];
                end
                
                default: begin
                  expectresult = 0; 
                  expectc = 0;
                end
              
             
            endcase
            
            
            //checking results, reused my 4 bit adder checker
            
            expectz = (expectresult == 0);
            expectn = expectresult[7];
            if (op == 3'b000)
              if (( ((a[7] & b[7] ) & ~expectresult[7] ) | ( ~a[7] & ~b[7] & expectresult[7] ) ) )
                expectv = 1;
              else
                expectv  = 0;
            else if (op == 3'b001)
              if ( (( a[7] & ~b[7] & expectresult[7])) | (( ~a[7]&  b[7] & ~ expectresult[7])) )
                expectv  = 1;
              else
                expectv  = 0;
            else
              expectv  = 0;
            
            if ((expectresult == sum) & (expectc == cout) & (expectz == zero) & (expectn == negative) & (expectv == overflow) )
              passcnt = passcnt + 1;
            else begin
              failcnt = failcnt + 1;
              #5
              $display("a=%b, b=%b, cin = %d, cout=%d, actual result = %b opcode=%b | expected result=%b, expected c = %d, expected z = %d, expected n = %d, expected v = %d, fail number %d", a, b, cin, cout, sum, op, expectresult, expectc, expectz, expectn, expectv, failcnt);
            end
            
          end
        end
      end
    end
      $display("PASSES =%d FAILS =%d", passcnt, failcnt);

            #5;
      $finish;
    
  end
  
endmodule