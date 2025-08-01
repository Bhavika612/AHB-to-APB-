# AHB to APB Bridge Design 

This repository implements a parameterized AHB to APB Bridge System in Verilog, including:

AHB Master
AHB-to-APB Bridge
APB Slave

These modules together demonstrate how to build a simple, customizable AHB-to-APB transaction system — useful for on-chip communication between high-speed AHB components and low-speed APB peripherals.

📁 Repository Structure

├── AHB_MASTER.v     # Parameterized AHB Master module
├── BRIDGE.v         # AHB-to-APB Bridge module
├── APB_SLAVE.v      # APB-compliant Slave 
└── README.md        # This file


DATA_WIDTH	Data bus width	32
BASE_ADDR	Valid address prefix (APB Slave)	24'h400000
HSIZE_VALUE	AHB data transfer size	3'b010
HPROT_VALUE	AHB protection control flags	4'b0011
---

