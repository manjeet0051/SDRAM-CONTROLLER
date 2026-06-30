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
## ✅ Phase 5: Refresh FSM
**RTL:** `rtl/refresh_fsm.sv`  
**Testbench:** `tb/tb_refresh_fsm.sv`

### Description
Implemented a finite state machine (FSM) that executes the SDRAM refresh sequence. The FSM responds to periodic refresh requests, issues the required SDRAM commands, waits for the refresh recovery time (`tRFC`), and generates a refresh acknowledgement upon completion.

### Motivation
SDRAM stores data as charge in capacitors, which gradually leaks over time. To preserve data integrity, the memory must be refreshed periodically. The Refresh FSM performs this protocol-compliant refresh operation.

### Refresh Sequence
```text
REFRESH_REQ
      ↓
PRECHARGE ALL
      ↓
AUTO REFRESH
      ↓
wait tRFC
      ↓
REFRESH_ACK
      ↓
IDLE
```

### State Diagram
```text
IDLE
 |
 | refresh_req
 v
PRECHARGE
 |
 v
REFRESH
 |
 v
WAIT_TRFC
 |
 | timer_done
 v
DONE
 |
 v
IDLE
```

### Interface

#### Inputs
- `clk` : System clock
- `rst` : Active-high reset
- `refresh_req` : Refresh request from `refresh_timer`
- `timer_done` : Indicates completion of the `tRFC` delay

#### Outputs
- `cmd[2:0]` : Encoded SDRAM command
- `timer_start` : Starts the timing manager
- `timer_cycles[7:0]` : Number of cycles for `tRFC`
- `refresh_ack` : Indicates refresh completion

### Generated Commands
| State | Command |
|-------|----------|
| IDLE | NOP |
| PRECHARGE | PRECHARGE ALL |
| REFRESH | AUTO REFRESH |
| WAIT_TRFC | NOP |
| DONE | NOP + `refresh_ack = 1` |

### Interaction with Other Modules
```text
refresh_timer
      |
      | refresh_req
      v
  refresh_fsm
      |
      | timer_start, timer_cycles
      v
timing_manager
      |
      | timer_done
      v
  refresh_fsm
      |
      | cmd
      v
command_encoder
      |
      v
CS_n RAS_n CAS_n WE_n
```

### Verification
Implemented a self-checking SystemVerilog testbench that verifies:
- Correct transition from `IDLE` to `PRECHARGE`
- Generation of `PRECHARGE ALL`
- Generation of `AUTO REFRESH`
- Proper interaction with the timing manager for `tRFC`
- Assertion of `refresh_ack` after refresh completion

### Run Simulation

```bash
cd results
vvp refresh_fsm
```

### Simulation Result
```text
[PASS] PRECHARGE command issued
[PASS] REFRESH command issued
[PASS] Refresh acknowledged

All refresh FSM tests passed.
```
## ✅ Phase 6: Address Decoder
**RTL:** `rtl/address_decoder.sv`  
**Testbench:** `tb/tb_address_decoder.sv`

### Description
Implemented a combinational address decoder that translates a linear system address into SDRAM-specific addressing fields: **Bank Address**, **Row Address**, and **Column Address**.

The decoder acts as an interface between the controller and SDRAM by converting CPU-generated addresses into the format required by the SDRAM protocol.

---

### Motivation
SDRAM does not access memory using a single linear address. Instead, every memory location is identified by:

- Bank Address (BA)
- Row Address (ROW)
- Column Address (COL)

Before issuing SDRAM commands such as `ACTIVE`, `READ`, or `WRITE`, the controller must determine which bank, row, and column correspond to the requested address.

---

### Address Mapping

For the assumed SDRAM organization:

- Banks: 4 → 2 bits
- Rows: 4096 → 12 bits
- Columns: 256 → 8 bits

Address partition:

```text
addr[21:20] → Bank Address
addr[19:8]  → Row Address
addr[7:0]   → Column Address
```

---

### Architecture

```text
System Address (22 bits)
            |
            v
    +-----------------+
    | Address Decoder |
    +-----------------+
            |
            +---- bank[1:0]
            +---- row[11:0]
            +---- col[7:0]
```

---

### Implementation Details

The decoder is purely combinational and performs simple bit extraction:

```text
bank = addr[21:20]
row  = addr[19:8]
col  = addr[7:0]
```

No clock, state machine, or counters are required.

---

### Interface

#### Inputs
- `addr[21:0]` : Linear system address

#### Outputs
- `bank[1:0]` : SDRAM bank number
- `row[11:0]` : SDRAM row address
- `col[7:0]` : SDRAM column address

---

### Run Simulation

```bash
cd results
vvp address_decoder
```

### Verification

Implemented a self-checking SystemVerilog testbench that verified:

- Correct bank extraction
- Correct row extraction
- Correct column extraction
- Boundary addresses
- Arbitrary addresses

Simulation Output:

```text
[PASS] addr=000000 -> bank=0 row=0 col=0
[PASS] addr=123456 -> bank=1 row=564 col=86
[PASS] addr=2abcde -> bank=2 row=2748 col=222
[PASS] addr=3fffff -> bank=3 row=4095 col=255

All address decoder tests passed.
```

---

### Integration with Controller

The decoded outputs will be used by the Read/Write FSM:

```text
CPU Request
      |
      v
Address Decoder
      |
      +---- bank
      +---- row
      +---- column
      |
      v
Read/Write FSM
```

Example:

```text
Address = 0x123456

Decoded Outputs:
Bank   = 1
Row    = 564
Column = 86
```

The Read/Write FSM can then execute:

```text
ACTIVE Bank 1, Row 564
READ/WRITE Column 86
```

---
