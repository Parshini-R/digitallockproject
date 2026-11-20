# FSM Digital Lock with Failed-Attempt Counter (Nexys A7-100T)

A Verilog FSM-based digital lock for the Digilent Nexys A7 Artix-7 FPGA board, developed for Xilinx Vivado.

## Features
- 4-bit password entry from `SW[3:0]` (default password: `1010`)
- Submit with the Up button (`BTNU`)
- Three consecutive wrong entries cause permanent lockout until reset
- Correct entry unlocks until reset
- Center button (`BTNC`) resets the lock and failure counter
- Seven-segment display shows failure count (0-3)
- LEDs: `LED0` unlocked, `LED1` lockout, `LED[3:2]` attempts, `LED[7:4]` entered code

## Files
- `src/digital_lock.v`: FSM and failure counter
- `src/button_debounce.v`: button synchronizer/debounce filter
- `src/seven_segment.v`: hex display decoder
- `src/digital_lock_top.v`: board top-level integration
- `sim/digital_lock_tb.v`: simulation testbench
- `constraints/nexys_a7_100t.xdc`: pin constraints

## Password
The default code is `4'b1010`. Change the `PASSWORD` parameter in `digital_lock_top.v` if desired.

## Vivado setup
1. Create a new RTL project in Vivado.
2. Select **Nexys A7-100T** (Artix-7 `xc7a100tcsg324-1`). If board files aren't installed, select the part directly.
3. Add all Verilog files from `src/` as Design Sources.
4. Add `sim/digital_lock_tb.v` as Simulation Source.
5. Add `constraints/nexys_a7_100t.xdc` as Constraints.
6. Set `digital_lock_top` as top module for synthesis.
7. Set `digital_lock_tb` as simulation top for behavioral simulation.
8. Run Behavioral Simulation, then Synthesis, Implementation, Generate Bitstream.
9. Program the board using Hardware Manager.

## Board demonstration
1. Set switches `SW[3:0]` to `1010`.
2. Press Up (`BTNU`): LED0 should turn on (unlock).
3. Press Center (`BTNC`) to reset.
4. Enter a wrong value and press Up three times (reset between correct-state test only; not between failed attempts).
5. After third wrong entry, LED1 turns on and lockout remains until reset.

## Important note about XDC
The pin assignments in this file are based on the official Digilent Nexys A7-100T Master XDC. If your board is a different revision/model (for example, Nexys A7-50T), use its matching master constraints.
