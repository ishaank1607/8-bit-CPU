# 8-bit CPU

![RTL Testbenches](https://github.com/ishaank1607/8-bit-CPU/actions/workflows/testbenches.yml/badge.svg)

This is a custom 8-bit CPU that I designed and verified from scratch in SystemVerilog. It's an accumulator-based processor with a 16-instruction ISA, built module by module (full adder, ALU, register file, control unit, full datapath) and exhaustively verified with self-checking testbenches.

**[Try it live](https://ishaank1607.github.io/8-bit-CPU/)** - This is a JavaScript reimplementation of the verified ISA running in-browser, with a step/run interface, live register and flag display, and an animated datapath diagram. Not built with the RTL itself (there's no practical way to run SystemVerilog client-side without a much heavier toolchain), but built to match the real hardware's verified semantics exactly.

## Architecture

Single-cycle, accumulator-based, 8-bit datapath throughout.

| Component | Detail |
|---|---|
| Instruction width | 8 bits (4-bit opcode + 4-bit operand) |
| Registers | 8 general-purpose (`R0`–`R7`), 8 bits each |
| Accumulator | Dedicated 8-bit register, the target of most operations |
| ALU | 8-bit, built from two cascaded 4-bit stages, each built from a 4-bit ripple-carry adder, each built from four 1-bit full adders |
| Instruction memory | 256 × 8-bit, loaded via `$readmemh` from a parameterized `.hex` file |
| Program counter | 8-bit, synchronous reset/load/increment |
| Control unit | Fully combinational, single-cycle instruction decode (no FSM, no pipelining) |
| Flags | Latched `Z` (zero) and `C` (carry), updated only on ALU-producing instructions |

### Module hierarchy
fadd.sv, bitadd4.sv (add_4bit), alu_4bit.sv, alu_8bit.sv
reg_8bit.sv, reg_file.sv
acc.sv, acc_mux.sv, pc.sv, instr_mem.sv, isa.sv, ctrlu.sv, flags.sv
└── cpu.sv (top-level integration)


## Instruction Set

| Opcode | Mnemonic | Operation |
|---|---|---|
| `0000` | `NOP` | no operation |
| `0001` | `LOAD Rn` | `A ← R[n]` |
| `0010` | `STORE Rn` | `R[n] ← A` |
| `0011` | `ADD Rn` | `A ← A + R[n]` |
| `0100` | `SUB Rn` | `A ← A − R[n]` |
| `0101` | `AND Rn` | `A ← A & R[n]` |
| `0110` | `OR Rn` | `A ← A \| R[n]` |
| `0111` | `XOR Rn` | `A ← A ^ R[n]` |
| `1000` | `NOT` | `A ← ~A` |
| `1001` | `SHL` | `A ← A << 1` |
| `1010` | `SHR` | `A ← A >> 1` |
| `1011` | `JMP addr` | `PC ← addr` |
| `1100` | `JZ addr` | `PC ← addr` if `Z=1` |
| `1101` | `JC addr` | `PC ← addr` if `C=1` |
| `1110` | `IN` | `A ← external input` |
| `1111` | `OUT` | `external output ← A` |

`JMP`/`JZ`/`JC` targets come from the 4-bit operand field, zero-extended to the 8-bit PC. This is a real limitation of this ISA, so branches can only reach addresses 0–15 (for now).

## Verification

Every RTL module has a self-checking SystemVerilog testbench with an independently computed reference model, and every one is exhaustive over its full reachable input space unless noted. All 11 are continuously re-verified on every commit via the GitHub Actions badge above.

| Module | Test space | Result |
|---|---|---|
| `fadd` | 8 (directed, full truth table) | 8 PASS |
| `add_4bit` | 512 | 0 failures |
| `alu_4bit` | 4,096 | 0 failures |
| `alu_8bit` | 1,048,576 | 0 failures |
| `isa` | 256 | 0 failures |
| `reg_8bit` | 1,024 | 0 failures |
| `reg_file` | 8,192 | 0 failures |
| `pc` | 2,048 | 0 failures |
| `acc_mux` | 1,024 | 0 failures |
| `instr_mem` | 8 (directed) | 0 failures |
| `ctrlu` | 262,144 | 0 failures |
| **Total** | **1,327,888 exhaustive combinations** | **0 failures** |


**Swap tb_ctrlu.sv for any file in tb/ to run that module's testbench. The full suite runs automatically on every push via .github/workflows/testbenches.yml.**

The full CPU has also been validated end-to-end through 3 directed integration testbenches (13 self-checking assertions total), covering all 16 ISA opcodes running through the real, integrated datapath, including a targeted case forcing a two's-complement borrow across the ALU's internal nibble boundary, and all four combinations of `JZ`/`JC` taken and not-taken.

### A bug worth mentioning

While building the branch tests, I found the CPU had no latched condition-flags register. `Z`/`C` were wired directly, combinationally, to the ALU's live output, which is driven by whatever the *current* instruction happens to be decoding, not necessarily the last arithmetic result. Since the control unit always drives a register-read address from the current instruction's operand field (including for `JZ`/`JC`, whose operand is actually a jump target, not a register selector), the ALU was quietly recomputing a meaningless value on every non-arithmetic cycle, and the flags a conditional branch read could be disconnected from the arithmetic instruction that was supposed to have set them. Fixed by designing and adding `flags.sv`, a proper clocked register that latches `Z`/`C` only when an ALU-producing instruction actually runs.

## Running the tests

```bash
iverilog -g2012 -o sim src/*.sv tb/tb_ctrlu.sv
vvp sim



