| Opcode | Instruction | Operation               |
| ------ | ----------- | ----------------------- |
| `0000` | NOP         | Nothing                 |
| `0001` | LOAD        | `A ← R[operand]`        |
| `0010` | STORE       | `R[operand] ← A`        |
| `0011` | ADD         | `A ← A + R[operand]`    |
| `0100` | SUB         | `A ← A - R[operand]`    |
| `0101` | AND         | `A ← A & R[operand]`    |
| `0110` | OR          | `A ← A \| R[operand]`   |
| `0111` | XOR         | `A ← A ^ R[operand]`    |
| `1000` | NOT         | `A ← ~A`                |
| `1001` | SHL         | `A ← A << 1`            |
| `1010` | SHR         | `A ← A >> 1`            |
| `1011` | JMP         | `PC ← address`          |
| `1100` | JZ          | `PC ← address` if `Z=1` |
| `1101` | JC          | `PC ← address` if `C=1` |
| `1110` | IN          | external input → `A`    |
| `1111` | OUT         | `A` → external output   |
