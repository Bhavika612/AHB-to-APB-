# AHB to APB Bridge Design 

This repository contains a Verilog implementation of an AHB to APB Bridge along with a testbench for simulation and verification. It is based on the AMBA specifications and includes FSM logic to translate pipelined AHB transactions to non-pipelined APB transfers.
---

##  Features:

- FSM-based bridge module with 8 states
- Handles both **read** and **write** operations
- Supports **single** and **burst** transfers
- Modular **testbench** using compiler directives
- Verified using **Icarus Verilog** and **GTKWave**

---

## 📂 Files Included
 `ahb2apb.v`    - Verilog HDL code for the AHB to APB bridge       
 `tb.v`         - Testbench to simulate read/write transfers 
 `README.md`    -This file (project documentation) 


## State Machine Overview

The FSM includes the following states:

- `IDLE`: Wait for a valid transaction  
- `READ`: Read setup  
- `WWAIT`: Write wait to capture write data  
- `WRITE`: Write setup  
- `WRITEP`: Pipelined write  
- `WENABLE`: Write enable  
- `WENABLEP`: Pipelined write enable  
- `RENABLE`: Read enable  

---

