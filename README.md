# 256-Point Radix-2 SDF FFT: From MATLAB Model to GDSII

A fully pipelined 256-point FFT based on the radix-2 Decimation-in-Frequency (DIF) Single-Delay-Feedback (SDF) architecture. The project covers the complete digital design flow: algorithm modeling on MATLAB, RTL design, UVM style verification, and physical implementation on the open-source SkyWater 130nm PDK using OpenLane.

## Overview

| Parameter | Value |
|---|---|
| Radix | 2 |
| Decimation type | Decimation in Frequency (DIF) |
| Architecture | Single Delay Feedback (SDF) |
| Size | 256-point |
| Data format | Fixed-point |
| Input | Complex, 16-bit real + 16-bit imaginary, natural order |
| Output | Complex, 16-bit real + 16-bit imaginary, bit-reversed order |
| Latency | 262 cycles (255 + 7 pipeline registers) |

## How It Works

The SDF architecture computes the DFT serially, one sample per clock. Each stage alternates between two modes, selected by a control signal:

1. **Store (control = 0):** the first half of the incoming samples is written into the stage's shift register, while the previously stored difference terms pass through the twiddle multiplier to the next stage.
2. **Butterfly (control = 1):** the stage computes the sum and difference of the stored and incoming samples. The sum goes to the output, and the difference is stored in the shift register.

Eight stages are cascaded with shift-register depths of 128, 64, 32, 16, 8, 4, 2, and 1. The sum of the depths gives the 255-cycle base latency. The control unit is a single counter whose bits drive the stages in reverse order, so the first stage toggles every 128 cycles, the second every 64, and so on. Pipeline registers between stages shorten the critical path and add 7 cycles of latency.

Each stage contains:
- A shift register (depth set by stage position)
- A twiddle-factor ROM with an address counter
- A complex multiplier
- An add/subtract butterfly unit
- Input and output muxes driven by the control signal

## System Modeling (MATLAB)

A stage-accurate MATLAB model was built and compared against MATLAB's built-in `fft()` using randomized inputs.

- Integer bit widths were derived from instrumentation of the signals across stages (inputs, intermediate stage outputs, and final outputs).
- Fractional bit widths were chosen from SQNR analysis.
- A custom `fimath` with `Floor` rounding matches the RTL's bit truncation.
- The model was run with double, single, and fixed-point data types.
- The test dumps input and output vectors to text files (used as golden data in verification) and the twiddle factors for the ROMs.

**Fixed-point word lengths used:**

| Signal | Format (signed, integer + fraction) |
|---|---|
| Input `x` | 4 + 12 |
| Twiddle `WN` | 2 + 22 |
| Stages 1 | 4 + 20 |
| Stages 2-3 | 5 + 19 |
| Stages 4-5 | 6 + 18 |
| Stages 6-7 | 7 + 17 |
| Stage 8 | 8 + 16 |
| Output `y` | 8 + 8 |

**Result over 4000 random seeds:** average SQNR of **73.83 dB**, average error of 3.44e-3.

## Verification

A SystemVerilog testbench drives and checks the design against the MATLAB golden output.

- **Generator:** reads the MATLAB input file and creates transactions.
- **Driver:** drives the DUT through a clocking block shortly after the positive clock edge.
- **Monitor:** samples the interface through its clocking block shortly before the positive clock edge.
- **Scoreboard:** forwards data to the subscriber for coverage, and when the DUT's valid flag is asserted, compares the output against the MATLAB golden output.
- **Subscriber:** collects functional coverage.

**Results:**

| Metric | Result |
|---|---|
| Tests passed / failed | 1,024,000 / 0 |
| Functional coverage | 100% |
| Branch / condition / expression / statement coverage | 100% |
| Toggle coverage | 98.08% |
| Total code coverage | 99.61% |

Toggle coverage falls short of 100% because the ROMs in the last stages hold simple twiddle values such as 1 and -j, which toggle fewer of the 24 bits.

## Physical Implementation (OpenLane)

| Setting | Value |
|---|---|
| PDK | SkyWater 130nm (`sky130A`) |
| Standard cells | `sky130_fd_sc_hd` (high density) |
| Synthesis strategy | AREA 0 |
| Clock period | 17 ns |
| Setup / hold uncertainty | 100 ps / 200 ps |

The flow covers synthesis, floorplanning, placement, clock tree synthesis, routing, and final GDS generation.

**Results:**

| Metric | Result |
|---|---|
| Synthesized cell count | 103,054 |
| Synthesized chip area | ~1,046,385 µm² |
| WNS / TNS | 0.00 / 0.00 |
| Worst setup slack | 0.39 ns |
| Worst hold slack | 0.30 ns |
| Fmax | ~60.2 MHz |
| Final die area | 1446.24 µm × 1444.32 µm |
| Utilization | 51.1% |
| Total power (typical corner) | ~1.48 W |
| DRC violations | 0 |
| LVS | Clean |

## Tools

- MATLAB (Fixed-Point Designer) for modeling
- SystemVerilog for RTL and testbench
- OpenLane with the SkyWater `sky130A` PDK for the ASIC flow

## Author

Ahmed Hussien Ashour
