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
## ✅ Phase 3: SDRAM Initialization FSM
**RTL:** `rtl/init_fsm.sv`  
**Testbench:** `tb/tb_init_fsm.sv`

### Description
Implemented an initialization finite state machine (FSM) that performs the JEDEC-compliant SDRAM power-up sequence. The FSM coordinates startup delays and generates the required SDRAM commands before enabling normal memory transactions.

### Initialization Sequence
```text
RESET
  ↓
WAIT_100US
  ↓
PRECHARGE_ALL
  ↓
AUTO_REFRESH
  ↓
AUTO_REFRESH
  ↓
LOAD_MODE_REGISTER
  ↓
INIT_DONE
```

### Generated Commands
| State | Command |
|------|---------|
| WAIT_100US | NOP |
| PRECHARGE | PRECHARGE ALL |
| REFRESH1 | AUTO REFRESH |
| REFRESH2 | AUTO REFRESH |
| LOAD_MODE | LOAD MODE REGISTER |
| DONE | NOP + init_done = 1 |

### Interface


#### Inputs
- `clk` : System clock
- `rst` : Active-high reset
- `timer_done` : Indicates completion of the required delay


#### Outputs
- `cmd[2:0]` : Encoded SDRAM command
- `timer_start` : Starts a timing delay
- `timer_cycles[7:0]` : Number of cycles to wait
- `init_done` : Asserted when initialization is complete

### Verification
Implemented a self-checking testbench that verifies:
- Correct reset behavior
- Correct state transitions
- Correct command generation sequence
- Proper interaction with the timing interface
- Assertion of `init_done` after completing initialization

### Run Simulation

```bash
cd results
vvp init_fsm
```

### Simulation Result
```text
t=0      cmd=0 start=1 cycles=100 init_done=0
t=45000  cmd=4 start=0 cycles=0 init_done=0
t=55000  cmd=5 start=0 cycles=0 init_done=0
t=65000  cmd=5 start=0 cycles=0 init_done=0
t=75000  cmd=6 start=0 cycles=0 init_done=0
t=85000  cmd=0 start=0 cycles=0 init_done=1

[PASS] Initialization Completed
```
## ✅ Phase 4: Refresh Timer
**RTL:** `rtl/refresh_timer.sv`  
**Testbench:** `tb/tb_refresh_timer.sv`

### Description
Implemented a programmable refresh timer that periodically generates refresh requests for the SDRAM controller. The module counts clock cycles and asserts `refresh_req` after a predefined refresh interval. The request remains asserted until the refresh operation is acknowledged.

### Reason
SDRAM cells store data as charge in capacitors, which gradually leak over time. Therefore, every row must be refreshed periodically to prevent data loss.

### Functionality
```text
counter++
     |
     v
counter == REFRESH_PERIOD ?
     |
    Yes
     |
     v
refresh_req = 1
     |
     v
refresh_fsm performs refresh
     |
     v
refresh_ack = 1
     |
     v
counter = 0
refresh_req = 0
```

### Interface

#### Inputs
- `clk` : System clock
- `rst` : Active-high reset
- `refresh_ack` : Indicates completion of the refresh operation

#### Outputs
- `refresh_req` : Requests a refresh operation

### Parameter
- `REFRESH_PERIOD` : Number of clock cycles between consecutive refresh requests.

### Verification
Implemented a self-checking SystemVerilog testbench that verifies:
- Generation of `refresh_req` after the programmed interval.
- Proper clearing of `refresh_req` upon receiving `refresh_ack`.
- Counter restart after acknowledgement.
- Periodic generation of subsequent refresh requests.

### Run Simulation

```bash
cd results
vvp refresh_timer
```

### Simulation Result
```text
[PASS] Refresh request generated
[PASS] Refresh request cleared
[PASS] Second refresh request generated

All refresh timer tests passed.
```

### Integration in Controller
```text
refresh_timer
      |
      | refresh_req
      v
    arbiter
      |
      v
  refresh_fsm
      |
      | refresh_ack
      v
refresh_timer
```
