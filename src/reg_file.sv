// design for register file
`include "reg_8bit.sv"

module reg_file (input clk,
                  input reset,
                  input [2:0] read_addr,
                  input [2:0] write_addr,
                  input [7:0] write_data,
                  input write_enable,
                  output logic [7:0] read_data);
  wire[7:0] r0;
  wire[7:0] r1;
  wire[7:0] r2;
  wire[7:0] r3;
  wire[7:0] r4;
  wire[7:0] r5;
  wire[7:0] r6;
  wire[7:0] r7;
  
  logic r0_load;
  logic r1_load;
  logic r2_load;
  logic r3_load;
  logic r4_load;
  logic r5_load;
  logic r6_load;
  logic r7_load;
  
  
  
  reg_8bit instance1 (.clk(clk), .reset(reset), .load(r0_load), .d(write_data), .q(r0) );
  reg_8bit instance2 (.clk(clk), .reset(reset), .load(r1_load), .d(write_data), .q(r1) );
  reg_8bit instance3 (.clk(clk), .reset(reset), .load(r2_load), .d(write_data), .q(r2) );
  reg_8bit instance4 (.clk(clk), .reset(reset), .load(r3_load), .d(write_data), .q(r3) );
  reg_8bit instance5 (.clk(clk), .reset(reset), .load(r4_load), .d(write_data), .q(r4) );
  reg_8bit instance6 (.clk(clk), .reset(reset), .load(r5_load), .d(write_data), .q(r5) );
  reg_8bit instance7 (.clk(clk), .reset(reset), .load(r6_load), .d(write_data), .q(r6) );
  reg_8bit instance8 (.clk(clk), .reset(reset), .load(r7_load), .d(write_data), .q(r7) );
  
 
  
  
  always @(*) begin
    read_data = 0;
    case ( read_addr )
      3'b000: read_data = r0;
      3'b001: read_data = r1;
      3'b010: read_data = r2;
      3'b011: read_data = r3;
      3'b100: read_data = r4;
      3'b101: read_data = r5;
      3'b110: read_data = r6;
      3'b111: read_data = r7;
    endcase
  end
  
  always @(*) begin
    r0_load = 0;
    r1_load = 0;
    r2_load = 0;
    r3_load = 0;
    r4_load = 0;
    r5_load = 0;
    r6_load = 0;
    r7_load = 0;
    if (write_enable) begin
      case( write_addr )
        3'b000: r0_load = 1;
        3'b001: r1_load = 1;
        3'b010: r2_load = 1;
        3'b011: r3_load = 1;
        3'b100: r4_load = 1;
        3'b101: r5_load = 1;
        3'b110: r6_load = 1;
        3'b111: r7_load = 1;
      endcase
    end
  end

endmodule