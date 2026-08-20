module tb_ctrlu;
  
  reg[3:0] opct;
  reg[3:0] oprt;
  reg zt;
  reg ct;
  reg[7:0] inpdt;
  
  wire[2:0] aluopct;
  wire acclt;
  wire[2:0] readaddrt;
  wire[2:0] writeaddrt;
  wire writent;
  wire pclt;
  wire pcinrt;
  wire[1:0] accsrct;
  wire outent;
  wire sub_cin_t; 
  
  ctrlu instance1 (.opcode(opct), .operand(oprt), .zflag(zt), .cflag(ct), .input_data(inpdt), .alu_opcode(aluopct), .acc_load(acclt), .reg_read_addr(readaddrt), .reg_write_addr(writeaddrt), .reg_write_enable(writent), .pc_load(pclt), .pc_increment(pcinrt), .acc_src(accsrct), .out_enable(outent), .sub_cin(sub_cin_t) );
  
  integer i;
  integer j;
  integer k;
  integer l;
  integer m;
  
  integer passcnt;
  integer failcnt;
  
  //expected value registers
  reg [2:0] exp_alu_opcode;
  reg exp_acc_load;
  reg [2:0] exp_reg_read_addr;
  reg [2:0] exp_reg_write_addr;
  reg exp_reg_write_enable;
  reg exp_pc_load;
  reg exp_pc_increment;
  reg [1:0] exp_acc_src;
  reg exp_out_enable;
  reg exp_sub_cin;
  
  initial begin
    opct = 0;
    oprt = 0;
    zt = 0;
    ct = 0;
    inpdt = 0;
    
    passcnt = 0;
    failcnt = 0;
    
    
    
    for (i = 0; i <=15; i = i + 1) begin
      for (j = 0; j <=15; j = j + 1) begin
        for (k = 0; k <=1; k = k + 1) begin
          for (l = 0; l <=1; l = l + 1) begin
            for (m = 0; m <=255; m = m + 1) begin
              opct = i;
              oprt = j;
              zt = k;
              ct = l;
              inpdt = m;
              
              exp_alu_opcode = 3'b000;
              exp_acc_load = 0;
              exp_reg_read_addr  = oprt[2:0];
              exp_reg_write_addr  = 3'b000;
              exp_reg_write_enable = 0;
              exp_pc_load = 0;
              exp_pc_increment = 1;
              exp_acc_src = 2'b00;
              exp_out_enable = 0;
              exp_sub_cin = 0;
              
              case (opct)

                4'b0000: begin 
                end

                4'b0001: begin 
                  exp_acc_load = 1;
                  exp_acc_src = 2'b01;
                end

                4'b0010: begin 
                  exp_reg_write_enable = 1;
                  exp_reg_write_addr = oprt[2:0];
                end

                4'b0011: begin
                  exp_alu_opcode = 3'b000;
                  exp_acc_load = 1;
                end

                4'b0100: begin 
                  exp_alu_opcode = 3'b001;
                  exp_acc_load = 1;
                  exp_sub_cin = 1;
                end

                4'b0101: begin 
                  exp_alu_opcode = 3'b010;
                  exp_acc_load = 1;
                end

                4'b0110: begin 
                  exp_alu_opcode = 3'b011;
                  exp_acc_load = 1;
                end

                4'b0111: begin 
                  exp_alu_opcode = 3'b100;
                  exp_acc_load = 1;
                end

                4'b1000: begin 
                  exp_alu_opcode = 3'b101;
                  exp_acc_load = 1;
                end

                4'b1001: begin 
                  exp_alu_opcode = 3'b110;
                  exp_acc_load = 1;
                end

                4'b1010: begin 
                  exp_alu_opcode = 3'b111;
                  exp_acc_load = 1;
                end

                4'b1011: begin 
                  exp_pc_load = 1;
                  exp_pc_increment = 0;
                end

                4'b1100: begin
                  exp_pc_load = zt;
                  exp_pc_increment = !zt;
                end

                4'b1101: begin 
                  exp_pc_load = ct;
                  exp_pc_increment = !ct;
                end

                4'b1110: begin
                  exp_acc_load = 1;
                  exp_acc_src = 2'b10;
                end

                4'b1111: begin 
                  exp_out_enable = 1;
                end

			endcase
              
              if ({aluopct, acclt, readaddrt, writeaddrt, writent, pclt, pcinrt, accsrct, outent, sub_cin_t}!={exp_alu_opcode, exp_acc_load, exp_reg_read_addr, exp_reg_write_addr,exp_reg_write_enable, exp_pc_load, exp_pc_increment, exp_acc_src, exp_out_enable, exp_sub_cin}) begin

                failcnt = failcnt + 1;

                $display("FAIL | Opcode = %b, Operand = %b, Z flag = %b, C flag = %b, Input data = %b", opct, oprt, zt, ct, inpdt);
              end
			else
              passcnt = passcnt + 1;
              
            end
          end
        end
      end
    end
    $display("PASS = %d, FAIL = %d", passcnt, failcnt);
    $finish;
  end
endmodule
