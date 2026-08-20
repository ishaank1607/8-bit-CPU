// 8-bit ALU design



module alu_8bit ( input [7:0] A,
                 input[7:0] B,
                 input Cin,
                 input [2:0] opcode,
                 output logic [7:0] result,
                 output logic C,
                 output logic Z,
                 output logic N,
                 output logic V);
  
  wire connC;
  wire upperC;

  wire[3:0] result1;
  wire[3:0] result2;
  
  
  
  
  
  alu_4bit instance1 ( .A(A[3:0]), .B(B[3:0]), .Cin(Cin), .sub_cin(1'b1), .opcode(opcode), .result(result1), .C(connC) );
  alu_4bit instance2 ( .A(A[7:4]), .B(B[7:4]), .Cin(connC), .sub_cin(connC), .opcode(opcode), .result(result2), .C(upperC) );
  
  always @(*) begin
    result = { result2 , result1 };
    
    
    if (opcode == 3'b110) begin
      result = A << 1;
      C = A[7];
    end
    else if (opcode == 3'b111) begin
      result = A >> 1;
      C = A[0];
    end
    else begin
      C = upperC;
    end
      
    Z = (result == 0);
    N = result[7];
    if (opcode == 3'b000)
      if (( ((A[7] & B[7] ) & ~result[7] ) | ( ~A[7] & ~B[7] & result[7] ) ) )
          V = 1;
        else
          V = 0;
      else if (opcode == 3'b001)
        if ( ((A[7] & ~B[7] & result[7])) | ((~A[7]&  B[7]& ~result[7])) )
          V = 1;
        else
          V = 0;
      else
        V = 0;
    
  end
                      
endmodule
