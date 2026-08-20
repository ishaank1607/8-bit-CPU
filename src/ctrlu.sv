// design for control unit

module ctrlu (
    input [3:0] opcode,
    input [3:0] operand,
    input zflag,
    input cflag,
    input [7:0] input_data,
  
    output logic [2:0] alu_opcode,
    output logic acc_load,
    output logic [2:0] reg_read_addr,
    output logic [2:0] reg_write_addr,
    output logic reg_write_enable,
    output logic pc_load,
    output logic pc_increment,
  	output logic [1:0] acc_src,
    output logic out_enable,
    output logic sub_cin,
    output logic flags_load
);
  
  always @(*) begin
    sub_cin = 0;
    flags_load = 0;
    acc_load = 0;
    alu_opcode = 3'b000;
    reg_read_addr = 3'b000;
    reg_write_addr = 3'b000;
    reg_write_enable = 0;
    pc_load = 0;
    pc_increment = 1;
    reg_read_addr = operand[2:0];
    acc_src = 2'b00;
    out_enable = 0;
    
    case ( opcode )
      
      4'b0001: begin
        acc_src = 2'b01;
        acc_load = 1;
        pc_increment = 1;
      end
      
      4'b0010: begin
        reg_write_enable = 1;
        reg_write_addr = operand[2:0];
        pc_increment = 1;
      end
      
      4'b0011:begin
        alu_opcode = 3'b000;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
      
      4'b0100:begin
        alu_opcode = 3'b001;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        sub_cin = 1;
        flags_load = 1;
      end
      
      4'b0101:begin
        alu_opcode = 3'b010;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
      
      4'b0110:begin
        alu_opcode = 3'b011;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
      
      4'b0111:begin
        alu_opcode = 3'b100;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
      
      4'b1000:begin
        alu_opcode = 3'b101;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
        
      4'b1001:begin
        alu_opcode = 3'b110;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
      
      4'b1010:begin
        alu_opcode = 3'b111;
        acc_load = 1;
        reg_write_enable = 0;
        pc_increment = 1;
        flags_load = 1;
      end
      
      4'b1011: begin
        pc_load = 1;
        pc_increment = 0;
      end
      
      4'b1100: begin
        if (zflag) begin
          pc_load = 1;
          pc_increment = 0;
        end
        else
          pc_increment = 1;
      end
      
      4'b1101: begin
        if (cflag) begin
          pc_load = 1;
          pc_increment = 0;
        end
        else
          pc_increment = 1;
      end
      
      4'b1110: begin
        acc_load = 1;
        acc_src = 2'b10;
        pc_increment = 1;
      end
      
      4'b1111: begin
        out_enable = 1;
        pc_increment = 1;
      end
        
        
    endcase
  end
endmodule
