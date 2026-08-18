// testbench for register file

module tb_reg_file;
  
  reg[7:0] r_test;
  reg reset;
  reg clk;
  reg [2:0] addt; //using for both read and write
  
  reg [7:0] write_datat;
  reg write_ent;
  wire [7:0] read_datat;
  
  integer i;
  integer j;
  integer k;
  integer l;
  integer m;
  
  integer passcnt;
  integer failcnt;
  
  reg [7:0] expected [0:7];
  
  reg_file instance1 ( .clk(clk),
                      .reset(reset),
                      .read_addr(addt),
                      .write_addr(addt),
                      .write_data(write_datat),
                      .write_enable(write_ent),
                      .read_data(read_datat) );
  
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
	
  end
  
  initial begin
    write_ent = 0;
    reset = 0;
    addt = 0;
    write_datat = 0;
    
    
    passcnt = 0;
    failcnt = 0;
    
    for (k = 0; k < 8; k = k + 1)
        expected[k] = 0;
    
    reset = 1;
    @(posedge clk);
    #1;
    reset = 0;
    
    for (i = 0; i <= 1; i = i + 1) begin
      for (j = 0; j <= 1; j = j + 1) begin
        for (k = 0; k <= 7; k = k + 1) begin      
          for (l = 0; l <= 255; l = l + 1) begin
            write_ent = i;
            reset = j;
            addt = k;
            write_datat = l;
            
            
            if (reset) begin
              for (m = 0; m < 8; m = m + 1)
                expected[m] = 0;
            end
            else if (write_ent)
              expected[addt] = write_datat;
            
            @(posedge clk);
            #1;
            
            if ((read_datat == expected[addt]))
            	passcnt = passcnt + 1;
            else begin
                failcnt = failcnt + 1;
                $display("Write data = %b, Read dat = %b, Address = %b, expected = %b", 
                         write_datat, read_datat, addt, expected[addt] );
            end
            
            
            
          end
        end
      end
    end
    $display("PASSES = %d, FAILS = %d", passcnt, failcnt );
    $finish;
  end 
  
  
endmodule
            
    
  