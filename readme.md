# Image Sharpening Extension for a Simplified DLX Processor

## Overview
This project extends a simplified DLX RISC processor by introducing a custom SHARPEN instruction that enables efficient execution of a two-dimensional image-sharpening filter in hardware. The design was implemented on a Xilinx Spartan-6 FPGA and evaluated in terms of performance, power, and area. Results show a substantial improvement in execution time, with negligible impact on power consumption and a modest increase in area. 

## Repository Structure
- **/Area Reports** — FPGA synthesis, mapping, and utilization reports  
- **/Assembly Files** — DLX assembly programs including the `sharpen` instruction  
- **/C Files** — C reference generator and test harness (PGM/CSV output)  
- **/RESA** — RESA environment files (FPGA bitstream `.bit` + label `.lbl`)  
- **/RTL** — Verilog sources for DLX + SHARPEN extension  
- **/readme.md** — Project README documentation  

### Prerequisites
- **Xilinx ISE** — for synthesis, simulation, and bitstream generation  
- **ModelSim** — for functional simulation of the DLX + SHARPEN design using `.DATA` files  
- **Spartan-6 FPGA board** — target hardware  
- **RESA environment** — for loading `.bit` and `.lbl` files and running the assembly code  
- **C compiler (e.g., gcc/clang)** — to build the assembler, reference generator, and test harness  

### Assembling and Running Code

1. **Write your program**  
   - Create a DLX assembly program that uses the custom `sharpen` instruction.  
   - Save it under `/Assembly Files`.  

2. **Build the assembler**  
   - Compile the C-based assembler (`asm.c`) from `/C Files`:  
     ```bash
     gcc asm.c -o asm
     ```

3. **Assemble the program**  
   - Convert a `.txt` source file into `.DATA` and `.cod` formats:  
     ```bash
     ./asm program.txt
     ```

4. **Run simulations (optional)**  
   - Load the generated `.DATA` file into **ModelSim** to check functional correctness.  

5. **Run on FPGA via RESA**  
   - Load the `.cod` file together with the `.bit` and `.lbl` files from `/RESA` into the **RESA** environment.  
   - Execute the program on the Spartan-6 FPGA to validate real-time performance.  


## Instruction Set Extension

A new instruction, **`sharpen`**, was added to the DLX ISA to directly invoke the hardware SHARPEN unit.  
It processes 4 pixels in parallel, taking the current row (`rs1`), the row above (`R10`), and the row below (`rs2`), and writes the sharpened result to the destination register (`rd`).  

## Microarchitecture

The DLX datapath was extended with a dedicated SHARPEN unit, a selector (`ALU_OR_SHARPEN`), an additional register (`R10`) for the up row, and a small memory block (`RAM_E`).  
The control unit gained a new `SHARPEN` state and minimal extra signals to manage the new datapath.   

## Results (FPGA)

- **Performance:** large speed-ups vs. baseline DLX.
- **Power:** essentially unchanged (≈ **0.085 W → 0.086 W**) measured with **Xilinx XPower Analyzer** on Spartan-6.  
- **Area:** ~**16.4%** overall resource increase from Xilinx ISE `.mrp` mapping report.  

 
## Acknowledgments
- **Authors:** Yossi Abarbanel, Omri Nidam  
- **Mentor:** Oren Ganon  
- **Institution:** Tel Aviv University  