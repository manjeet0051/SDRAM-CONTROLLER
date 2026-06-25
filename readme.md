# SDRAM Controller (SystemVerilog)

A modular SDRAM controller implementation in SystemVerilog following the JEDEC SDRAM protocol. The project is being developed incrementally with self-checking testbenches for each module and focuses on reusable, scalable, synthesizable RTL design and verification.

## Tools Used

* SystemVerilog
* Icarus Verilog (iverilog)
* VS Code Editor
* GTKWave
* Self-checking Testbenches
* Git & GitHub

## ✅ Phase 1: Command Encoder

**RTL:** `rtl/command_encoder.sv`
**Testbench:** `tb/tb_command_encoder.sv`

### Description

Implemented a combinational command encoder that converts internal SDRAM commands into JEDEC-compliant control signals (`CS_n`, `RAS_n`, `CAS_n`, `WE_n`).

### Supported Commands

| Command   | CS_n | RAS_n | CAS_n | WE_n |
| --------- | ---- | ----- | ----- | ---- |
| NOP       | 0    | 1     | 1     | 1    |
| ACTIVE    | 0    | 0     | 1     | 1    |
| READ      | 0    | 1     | 0     | 1    |
| WRITE     | 0    | 1     | 0     | 0    |
| PRECHARGE | 0    | 0     | 1     | 0    |
| REFRESH   | 0    | 0     | 0     | 1    |
| LOAD MODE | 0    | 0     | 0     | 0    |

### Verification

Implemented a self-checking SystemVerilog testbench that:

* Exercises all valid SDRAM commands.
* Verifies generated control signals against the JEDEC truth table.
* Tests an invalid command (`cmd = 3'b111`) and safely maps it to `NOP`.
* Reports automatic PASS/FAIL status without requiring manual waveform inspection.

### Run Simulation

```bash
cd results
vvp command_encoder
```

### Simulation Result

```text
[PASS] cmd=0 -> CS=0 RAS=1 CAS=1 WE=1
[PASS] cmd=1 -> CS=0 RAS=0 CAS=1 WE=1
[PASS] cmd=2 -> CS=0 RAS=1 CAS=0 WE=1
[PASS] cmd=3 -> CS=0 RAS=1 CAS=0 WE=0
[PASS] cmd=4 -> CS=0 RAS=0 CAS=1 WE=0
[PASS] cmd=5 -> CS=0 RAS=0 CAS=0 WE=1
[PASS] cmd=6 -> CS=0 RAS=0 CAS=0 WE=0
[PASS] cmd=7 -> CS=0 RAS=1 CAS=1 WE=1

All command encoder tests passed.
```

---

## ✅ Phase 2: Timing Manager

**RTL:** `rtl/timing_manager.sv`
**Testbench:** `tb/tb_timing_manager.sv`

### Description

Implemented a reusable cycle-based timer for SDRAM protocol delays. The module generates a `busy` indication while counting down and asserts a one-cycle `done` pulse when the programmed delay expires.

### Interface

#### Inputs

* `clk` : System clock
* `rst` : Active-high reset
* `start` : Starts a new timing operation
* `cycles[7:0]` : Number of clock cycles to wait

#### Outputs

* `busy` : Indicates timer is active
* `done` : One-cycle completion pulse

### Operation

```text
start = 1
cycles = N
      |
      v
counter loaded with N
      |
busy = 1
      |
count down every clock
      |
counter reaches 0
      |
busy = 0
done = 1 for one cycle
```

### Run Simulation

```bash
cd results
vvp timing_manager
```

### Simulation Result

```text
[PASS] Timer delay = 2 cycles
[PASS] Timer delay = 5 cycles

All timing manager tests passed.
```
