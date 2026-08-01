# \# AHB-to-APB Bridge with Slave Interface (Verilog RTL)

# 

# A synthesizable RTL bridge that connects an AMBA AHB master to up to three APB peripherals, translating single-cycle AHB transactions into the two-phase (SETUP/ENABLE) APB protocol. Written in Verilog-2001, verified in ModelSim, and targeted for Quartus Prime synthesis.

# 

# \## Overview

# 

# The AHB and APB protocols operate very differently — AHB is pipelined and single-cycle per transfer, while APB requires a SETUP phase followed by an ENABLE phase for every access. This bridge decouples the two by:

# 

# 1\. Sampling and pipelining AHB address/data/control signals on the AHB slave interface

# 2\. Decoding the AHB address into one of three APB peripheral select lines

# 3\. Driving an 8-state FSM in the APB controller that sequences SETUP → ENABLE phases while stalling the AHB master (via `HREADYOUT`) exactly as long as needed

# 

# \## Architecture

# 

# ```

# &#x20;               ┌─────────────────────┐

# &#x20;  AHB Master → │  AHB\_slave\_interface │ → valid, haddr\_1/2, hwdata\_1/2, temp\_selx

# &#x20;               └─────────────────────┘

# &#x20;                          │

# &#x20;                          ▼

# &#x20;               ┌─────────────────────┐

# &#x20;               │    apb\_controller    │ → PSEL, PENABLE, PWRITE, PADDR, PWDATA

# &#x20;               │   (8-state FSM)      │

# &#x20;               └─────────────────────┘

# &#x20;                          │

# &#x20;                          ▼

# &#x20;                   APB Peripheral(s)

# ```

# 

# `Bridge\_top.v` instantiates and wires together `AHB\_slave\_interface` and `apb\_controller`.

# 

# \### `rtl/AHB\_slave\_interface.v`

# \- Pipelines `HADDR` and `HWDATA` through two register stages (`haddr\_1/2`, `hwdata\_1/2`) to align them with the APB controller's multi-cycle timing

# \- Decodes `HADDR` into a 3-bit peripheral select (`temp\_selx`) across three 64MB address windows: `0x8000\_0000`–`0x83FF\_FFFF`, `0x8400\_0000`–`0x87FF\_FFFF`, `0x8800\_0000`–`0x8BFF\_FFFF`

# \- Generates a `valid` transfer indicator from `HTRANS` (NONSEQ/SEQ) qualified with `HREADYIN` and the decoded address range

# \- Registers `HRDATA` from the APB read-data path (`PRDATA`)

# \- Drives a static `HRESP = OKAY`

# 

# \### `rtl/apb\_controller.v`

# \- 8-state Moore-ish FSM (`st\_idle`, `st\_wait`, `st\_write`, `st\_writep`, `st\_wenableb`, `st\_wenable`, `st\_read`, `st\_renable`) that sequences APB SETUP/ENABLE phases for both single and back-to-back (pipelined) write and read transactions

# \- Generates `PSEL`, `PENABLE`, `PWRITE`, `PADDR`, `PWDATA`

# \- Drives `HREADYOUT` low during the APB SETUP phase to stall the AHB master, and high once the APB transfer completes

# 

# \### `rtl/APB\_INTERFACE.v`

# A minimal APB slave model (combinational read/write passthrough with a fixed read-data response) used to exercise `apb\_controller` standalone in `tb/TB\_APB.v`. Not part of the bridge itself — this is a stand-in peripheral for verification.

# 

# \## Verification

# 

# \### `tb/AHB\_MASTER.v`

# An AHB bus-functional model (BFM) with tasks for `single\_write`, `single\_read`, and `burst\_write` (INCR-style, 3 beats). Used to drive `AHB\_slave\_interface` in simulation.

# 

# \### `tb/TB\_AHB\_SLAVE.v`

# Instantiates `AHB\_Master` + `AHB\_slave\_interface` and runs a burst-write sequence to check address/data pipelining, peripheral select decode, and `valid` generation.

# 

# \### `tb/TB\_APB.v`

# Instantiates `apb\_controller` + `APB\_INTERFACE` (dummy slave) and directly drives `valid`/`hwrite`/`haddr` stimulus to exercise single write, single read, and 3-beat burst-write sequences through the FSM, checking `PSEL`/`PENABLE`/`PWRITE`/`PADDR`/`PWDATA` and `HREADYOUT` timing.

# 

# \## Tools

# 

# \- \*\*Simulation:\*\* ModelSim (Verilog-2001)

# \- \*\*Synthesis:\*\* Quartus Prime

# 

# \## Running the simulation

# 

# ```bash

# \# Example ModelSim flow for the APB controller testbench

# vlib work

# vlog rtl/APB\_CONTROLLER.v rtl/APB\_INTERFACE.v tb/TB\_APB.v

# vsim -c tb\_apb -do "run -all; quit"

# 

# \# AHB slave interface testbench

# vlog rtl/AHB\_SLAVE\_INTERFACE.v tb/AHB\_MASTER.v tb/TB\_AHB\_SLAVE.v

# vsim -c tb\_ahb\_slave -do "run -all; quit"

# ```

# 

# Both testbenches dump a `.vcd` waveform (`tb\_apb.vcd`, `tb\_ahb\_slave.vcd`) that can be viewed in GTKWave or ModelSim's waveform viewer.

# 

# \## Design notes / challenges

# 

# \- Getting `HREADYOUT` timing right was the core challenge — it has to go low exactly during the APB SETUP phase to stall the AHB master, and come back high in sync with the ENABLE phase completing, without introducing bubble cycles on back-to-back transfers.

# \- The two-stage address/data pipeline (`haddr\_1/2`, `hwdata\_1/2`) exists to keep AHB data aligned with the FSM's multi-cycle APB timing, since AHB presents data on the cycle after the address while APB needs both held stable across SETUP+ENABLE.

# \- The FSM handles both isolated single transfers and pipelined back-to-back transfers (checking `valid` in states like `st\_wenableb`/`st\_renable` to decide whether to immediately start the next transfer or return to idle).

# 

# \## License

# 

# See \[LICENSE](LICENSE).

