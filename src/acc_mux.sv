// design for acc input mux


module acc_mux ( input [1:0] src,
                input[7:0] alu_data,
                input[7:0] reg_data,
                input[7:0] input_data,
                output logic [7:0] acc_data );
  
  
  always @(*) begin
    case ( src )
      2'b00: acc_data = alu_data;
      2'b01: acc_data = reg_data;
      2'b10: acc_data = input_data;
      default: acc_data = 8'b0;
    endcase
  end
endmodule