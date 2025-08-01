# AHB to APB Bridge Design

This repository implements a **parameterized AHB to APB Bridge System** in Verilog, consisting of the following three modules:

-  **AHB Master**  
-  **AHB-to-APB Bridge**  
-  **APB Slave**

These modules together demonstrate how to build a simple, customizable AHB-to-APB transaction system — ideal for on-chip communication between high-speed AHB components and low-speed APB peripherals.

---


##  Module Descriptions

###  AHB_master.v
- Generates AHB read/write transactions.
- Drives AHB signals like `HADDR`, `HTRANS`, `HWRITE`, `HWDATA`.
- Parameterized for `ADDR_WIDTH` and `DATA_WIDTH`.
- Handles response via `HREADY`, `HRESP`, and receives data via `HRDATA`.

### ahb2apb_bridge.v
- Translates AHB transactions into APB protocol format.
- Implements a finite state machine (FSM) to manage transaction stages.
- Controls APB signals like `PADDR`, `PWRITE`, `PWDATA`, `PSEL`, and `PENABLE`.

### APB_Slave.v
- Implements a simple APB-compliant memory-mapped slave.
- Reads/writes data to/from an internal memory array.
- Parameterized with `ADDR_WIDTH`, `DATA_WIDTH`, and `BASE_ADDR`.

---

