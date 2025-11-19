# Parameterizable ALU in Verilog (8/16/32/64-bit)
A parameterizable Arithmetic Logic Unit (ALU) implemented in Verilog, supporting arithmetic, logical, and shift operations with carry, overflow, zero, and negative flag generation. Includes a fully self-checking testbench with directed, edge-case, and randomized testing.

## Project Structure
```
src/
├── alu.v           # RTL ALU design (parametric WIDTH)
tb/
├── tb_alu.v        # Self-checking testbench
README.md
```

## Design Overview
This ALU is parameterized for WIDTH, allowing testing and synthesis at 4, 8, 16, 32, and 64 bits (tested).

### Supported Operations
| Opcode | Name | Function                        |
| ------ | ---- | ------------------------------- |
| 000    | ADD  | Signed/unsigned addition        |
| 001    | SUB  | Signed/unsigned subtraction     |
| 010    | AND  | Bitwise and                     |
| 011    | OR   | Bitwise or                      |
| 100    | XOR  | Bitwise xor                     |
| 101    | SLL  | Logical shift left (unsigned)   |
| 110    | SRL  | Logical shift right (unsigned)  |
| 111    | SRA  | Arithmetic shift right (signed) |

### Flag Logic
| Flag     | Meaning                       | When Active                               |
| -------- | ----------------------------- | ----------------------------------------- |
| carry    | Unsigned carry/borrow         | MSB of temp result (`temp_result[WIDTH]`) |
| overflow | Signed overflow               | Sign mismatch between result and operands |
| zero     | Output is zero                | `y == 0`                                  |
| negative | Signed negative               | `y[WIDTH-1] == 1`                         |

## Simulation & Testing
### Compile and Run (for default WIDTH=8)
```bash
iverilog -o sim src/alu.v tb/tb_alu.v
vvp sim
```

### Testing for other WIDTHs
```bash
# WIDTH = 4
iverilog -P tb_alu.WIDTH=4 -o sim src/alu.v tb/tb_alu.v
vvp sim

# WIDTH = 16
iverilog -P tb_alu.WIDTH=16 -o sim src/alu.v tb/tb_alu.v
vvp sim

# WIDTH = 32
iverilog -P tb_alu.WIDTH=32 -o sim src/alu.v tb/tb_alu.v
vvp sim

# WIDTH = 64
iverilog -P tb_alu.WIDTH=64 -o sim src/alu.v tb/tb_alu.v
vvp sim
```

### Viewing Waveforms
```bash
surfer tb_alu.vcd
```

## Waveform Results
### Signed Overflow - Example: `{0111_1111} + {0000_0001} = {1000_0000}`
<img width="1624" height="998" alt="Screenshot 2025-11-19 at 5 31 30 AM" src="https://github.com/user-attachments/assets/9d5a8bc1-bb7d-4de4-bff4-3ba7900bf639" />

| Signal   | Value / Behavior                     |
| -------- | ------------------------------------ |
| a        | 0111_1111 (+127)                     |
| b        | 0000_0001 (+1)                       |
| y        | 1000_0000 (wraps to -128)            |
| overflow | 1 (signed overflow occurred)         |
| carry    | 0 (no unsigned carry)                |

### Arithmetic Shift Right (SRA) - Example: `{1000_0000} >>> 1 = {1100_0000}`
<img width="1624" height="998" alt="Screenshot 2025-11-19 at 5 21 09 AM" src="https://github.com/user-attachments/assets/7051a014-11ca-42be-8161-5c2470b4622b" />

| Signal   | Value / Behavior                    |
| -------- | ----------------------------------- |
| a        | 1000_0000 (−128)                    |
| b        | 0000_0001 (shift amount = 1)        |
| y        | 1100_0000 (MSB preserved)           |
| negative | 1 (MSB preserved as sign bit)       |
| zero     | 0 (output not zero)                 |

### Saturated Shift (Shift Amount ≥ WIDTH) – Example: `{0000_0001} << {8} = {1000_0000}`
<img width="1624" height="998" alt="Screenshot 2025-11-19 at 5 27 53 AM" src="https://github.com/user-attachments/assets/a205da59-18ee-480e-b298-51aa72df431b" />

| Signal   | Value / Behavior                 |
| -------- | -------------------------------- |
| a        | 0000_0001 (LSB = 1)              |
| b        | WIDTH (8)                        |
| y        | 1000_0000 (MSB only, saturated)  |
| negative | 1 (MSB for signed)               |
| zero     | 0 (output not zero)              |

## Testbench Features
- Self-checking
- Golden model built inside testbench
- Directed test cases for each opcode
- Edge-case tests for for carry/borrow, overflow, and shift saturation
- Randomized test loop (500+ iterations)
- Prints mismatches with expected vs actual values

**Example error output:**
```
----- ERROR (test 184, width=8) a=128, b=1, op=001 -----
expected y=127,      got y=255
expected carry=1,    got carry=0
expected overflow=1, got overflow=0
expected zero=0,     got zero=0
expected negative=0, got negative=1
```

## Tools Used
- Icarus Verilog (RTL simulation)
- Surfer (Waveform viewer)
- VS Code (Editing)
