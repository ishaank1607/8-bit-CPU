// top level CPU module design
`include "pc.sv"
`include "instr_mem.sv"
`include "isa.sv"
`include "ctrlu.sv"
`include "reg_file.sv"
`include "alu_8bit.sv"
`include "acc_mux.sv"
`include "acc.sv"
`include "flags.sv"



module cpu #(
    parameter PROGRAM_FILE = "program.hex"
) ( input clk,
    input reset,
    input[7:0] in_data,
    output[7:0] out_data );
  
  //pc to instr wires
  wire [7:0] pc_value;
  wire [7:0] instruction;
  //isa to ctrlu wires
  wire [3:0] opcode;
  wire [3:0] operand;
  //reg file wires
  wire [7:0] reg_data;
  wire [2:0] reg_read_addr;
  wire [2:0] reg_write_addr;
  wire reg_write_enable;
  //alu wires
  wire [7:0] alu_result;
  wire [2:0] alu_opcode;
  wire sub_cin;
  wire alu_z;   // live ALU zero flag - only meaningful during the cycle the ALU op itself runs
  wire alu_c;   // live ALU carry flag
  //flags wires
  wire zflag;   // latched zero flag, held until the next ALU-producing instruction
  wire cflag;   // latched carry flag
  wire flags_load;
  //acc wires
  wire [7:0] acc_value;
  wire acc_load;
  wire [1:0] acc_src;
  // acc mux wires
  wire [7:0] acc_mux_out;
  // pc ctrl wires
  wire pc_load;
  wire pc_increment;
  //output wire
  wire out_enable;
  
  pc instance_pc ( .clk(clk),
                .reset(reset),
                .load(pc_load),
                .increment(pc_increment),
                .d({4'b0000, operand}),
                .q(pc_value) );
  
  instr_mem #(.PROGRAM_FILE(PROGRAM_FILE)) instance1 (.address(pc_value), .instruction(instruction) );
  
  isa instance_isa (.instruction(instruction), .opcode(opcode), .operand(operand) );
  
  ctrlu instance_ctrlu ( .opcode(opcode), .operand(operand), .zflag(zflag), .cflag(cflag), .input_data(in_data), .alu_opcode(alu_opcode), .acc_load(acc_load), .reg_read_addr(reg_read_addr), .reg_write_addr(reg_write_addr), .reg_write_enable(reg_write_enable), .pc_load(pc_load), .pc_increment(pc_increment), .acc_src(acc_src), .out_enable(out_enable), .sub_cin(sub_cin), .flags_load(flags_load) );
  
                   
  reg_file instance_reg_file ( .clk(clk), .reset(reset), .read_addr(reg_read_addr), .write_addr(reg_write_addr), .write_data(acc_value), .write_enable(reg_write_enable), .read_data(reg_data) );
  
  alu_8bit instance_alu ( .A(acc_value), .B(reg_data), .Cin(sub_cin), .opcode(alu_opcode), .Z(alu_z), .C(alu_c), .result(alu_result) );
  
  flags instance_flags ( .clk(clk), .reset(reset), .load(flags_load), .z_in(alu_z), .c_in(alu_c), .zflag(zflag), .cflag(cflag) );
  
  acc_mux instance_acc_mux ( .alu_data(alu_result), .src(acc_src), .reg_data(reg_data), .input_data(in_data), .acc_data(acc_mux_out) );
  
  acc instance_acc ( .clk(clk), .reset(reset), .load(acc_load), .d(acc_mux_out), .q(acc_value) );
  
  assign out_data = out_enable ? acc_value : 8'b0;
  
endmodule
