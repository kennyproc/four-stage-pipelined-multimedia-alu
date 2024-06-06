# Four Stage Pipelined Multimedia ALU
ESE 345 Computer Architecture - Final Project

Steps to run the simulation:
1. Download all source code files including the .vhd files, .txt files, and the assembly.py file.
2. Create your own list of MIPS assembly instructions from the list in the mips_instructions.txt file if you wish.
3. Run the assembler.py file to generate the 25-bit machine code instructions in the output.txt file.
4. In Aldec Active-HDL, create a new workspace with a new design, and select Add existing resource files.
5. Select all .vhd and .txt files you downloaded. Make sure results.txt and registers.txt are in the directory for the workspace rather than the src folder.
6. Make sure to change design settings to use at least VHDL-2008.
7. Set the four_stage_pipeline_tb as the top level.
8. Initialize simulation and open a new waveform, adding all signals to it.
9. Run the simulation for (60 + 20n) nanoseconds for n instructions.
10. You will see waveforms, showing the instruction in the first 3 stages, the values of rs1, rs2, rs3 read during stage 2, and the computed rd value during stage 3. You will also see the reg_write signal, write address, and data to be written during stage 4.
11. You can view the state of the registers after the simulation in the registers.txt file, and information about each of the stages during each clock cycle in the results.txt file.

View the Project Report for more information on the pipeline and analysis of results
