// top-level wrapper connecting the CPU to the Basys 3's physical
// switches, buttons, LEDs, and 7-segment display

module basys_top (
    input clk,
    input btnC,
    input btnU,
    input  [15:0] sw,
    output [15:0] led,
    output [6:0]  seg,
    output dp,
  output [3:0]  an );

  wire reset = btnC;

  // free-running slow clock for hands-off "watch it run" mode
  wire free_run_clk;
  clk_div divider (
    .reset(reset),
    .clock(clk),
    .clk(free_run_clk)
  );

  // debounced single-step button
  wire step_pulse;
  debounce_button step_btn (
    .clk(clk),
    .button(btnU),
    .debounce(),        // level output unused, we want the pulse instead
    .pulse(step_pulse)
  );

  // SW[15] selects free-run vs. manual single-step
  wire cpu_clk = sw[15] ? free_run_clk : step_pulse;

  wire [7:0] out_data;
  wire [7:0] debug_acc;
  wire [7:0] debug_pc;
  wire       debug_z;
  wire       debug_c;

  cpu #(.PROGRAM_FILE("program.hex")) dut (
    .clk(cpu_clk),
    .reset(reset),
    .in_data(sw[7:0]),
    .out_data(out_data),
    .debug_acc(debug_acc),
    .debug_pc(debug_pc),
    .debug_z(debug_z),
    .debug_c(debug_c)
  );

  seven_dr display (
    .clk(clk),
    .dig3(debug_acc[7:4]),
    .dig2(debug_acc[3:0]),
    .dig1(debug_pc[7:4]),
    .dig0(debug_pc[3:0]),
    .an(an),
    .seg(seg)
  );

  assign led[7:0]   = out_data;
  assign led[8]     = debug_z;
  assign led[9]     = debug_c;
  assign led[15:10] = 6'b0;

  assign dp = 1'b1;

endmodule
