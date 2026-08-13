// 4-bit ALU module

`include "bitadd4.sv"

module alu_4bit ( input[3:0] A, 
                 input[3:0] B, 
                 input Cin, 
                 input[2:0] opcode, 
                 output logic [3:0] result, 
                 output logic C, 
                 output logic Z, 
                 output logic N, 
                 output logic V);
  // I used flags here and they are represented with C, Z, N, V
  // C - Carry, Z - result is zero, N - result negative, V - arithmetic overflow

  wire[3:0] add_result; //meant to connect result of add_4bit to Result
  wire[3:0] sub_result;
  wire add_cout;
  wire sub_cout;
  
  add_4bit instance1 ( .a(A), .b(B), .cin(Cin), .sum(add_result), .cout(add_cout) );
  add_4bit instance2 ( .a(A), .b(~B), .cin(1'd1), .sum(sub_result), .cout(sub_cout) ); //inverted B and used cin = 1 for two's pair
  
  
  always @(*) begin
    case ( opcode )
      3'b000: begin 
        result = add_result; 
        C = add_cout;
      end
      
      3'b001: begin
        result = sub_result; 
        C = sub_cout;
      end
      
      3'b010: begin
        result = A & B; 
        C = 0;
      end
      
      3'b011: begin 
        result = A | B; 
        C = 0;
      end
      
      3'b100: begin 
        result = A ^ B; 
        C = 0;
      end
      
      3'b101: begin
        result = ~A; 
        C = 0;
      end
      
      3'b110: begin 
        result = A << 1; //shift left, assigned shifted-out bit to C
        C = A[3]; 
      end 
      
      3'b111: begin 
        result = A >> 1; // shift right, assigned shifted-out bit to C
        C = A[0]; 
      end
      
      default: begin
        result = 4'b0000; 
        C = 0;
      end
      
    endcase
    
  
  
    if (result == 0)
      Z = 1;
    else
      Z = 0;

    if ( result[3] )
      N = 1;
    else
      N = 0;

    if (opcode == 3'b000)
      if (( ((A[3] & B[3] ) & ~result[3] ) | ( ~A[3] & ~B[3] & result[3] ) ) )
        V = 1;
      else
        V = 0;
    else if (opcode == 3'b001)
      if ( ((A[3] & ~B[3] & result[3])) | ((~A[3]&  B[3]& ~result[3])) )
        V = 1;
      else
        V = 0;
    else
      V = 0;

  end
endmodule