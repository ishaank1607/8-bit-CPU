// code

`include "fadd"
module add_4bit ( input[3:0] a, input[3:0] b, input cin, output[3:0] sum, output cout );
  
  wire conn1;
  wire conn2;
  wire conn3;
  
  fadd instance1 ( .in1(a[0]), 
                  .in2(b[0]), 
                  .cin(cin), 
                  .sum(sum[0]), 
                  .cout(conn1));
  fadd instance2 ( .in1(a[1]), 
                  .in2(b[1]), 
                  .cin(conn1), 
                  .sum(sum[1]), 
                  .cout(conn2));
  fadd instance3 ( .in1(a[2]), 
                  .in2(b[2]), 
                  .cin(conn2), 
                  .sum(sum[2]), 
                  .cout(conn3));
  fadd instance4 ( .in1(a[3]), 
                  .in2(b[3]), 
                  .cin(conn3), 
                  .sum(sum[3]), 
                  .cout(cout));
endmodule