-- Stage 2 of the 4-stage pipelined design
-- Takes in the 25-bit instruction from the instruction buffer for decoding.
-- Also takes in data for updating the registers, passed by the write back
-- stage (stage 4) to determine if a register needs to be written to, and
-- which register needs to be updated with the new data.
-- Each cycle can support up to 3 reads and 1 write.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 	
use std.textio.all;	 
use ieee.std_logic_textio.all;

entity register_module is
	port (		
		-- 25-bit instruction passed through the instruction buffer
		full_instr : in std_logic_vector (24 downto 0);			   
		-- Data to update the register file from the write back stage
		reg_write : in std_logic;
		write_index : in std_logic_vector (4 downto 0);
		data : in std_logic_vector (127 downto 0);
		reset : in std_logic;		
		-- Output signals to be fed to the ALU
		rs1 : out std_logic_vector (127 downto 0);
		rs2 : out std_logic_vector (127 downto 0);
		rs3 : out std_logic_vector (127 downto 0);
		opcode : out std_logic_vector (7 downto 0);
		load_index : out std_logic_vector (2 downto 0);
		imm : out std_logic_vector (15 downto 0);
		instr : out std_logic_vector (1 downto 0);
		rs1_addr : out std_logic_vector (4 downto 0);
		rs2_addr : out std_logic_vector (4 downto 0);
		rs3_addr : out std_logic_vector (4 downto 0);
		rd_addr : out std_logic_vector (4 downto 0)
	);					  
end register_module;			   


architecture behavioral of register_module is						   

-- Stores the data of each of the 32 registers
type registerArray is array (0 to 31) of std_logic_vector(127 downto 0);
signal registers : registerArray := (others => (others => '0'));	   																										  

begin		

	process	(full_instr, reset, registers, reg_write, data, write_index)	 
	file file_pointer : text;
	variable line_content : std_logic_vector (127 downto 0);
	variable line_num : line; 
			  
	begin	
		--report "Write index : " & to_string(write_index);
		--report "Write value : " & to_string(data);
		--report "reg_write : " & to_string(reg_write);
		
		-- update the register from the write back only if the reg_write signal is '1' 
		if reg_write = '1' then
			registers(to_integer(unsigned(write_index))) <= data;
		end if;
		
		-- Reset all register values to 0 if reset is '1'
		if reset = '1' then	   
			for i in 0 to 31 loop
				registers(i) <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
			end loop;
			
		end if;
		
		
		-- Identify if the instruction is either load immediate, multiply-add and multiply-subtract r4-instruction format, 
		-- or r3-instruction format. Then, decode the 25-bit instruction into its necessary fields to be used by the ALU.
		if full_instr(24) = '0' then
			-- LOAD IMMEDIATE --   
			instr <= "00";
			load_index <= full_instr(23 downto 21);
			imm <= full_instr(20 downto 5);	  
			rs1_addr <= full_instr(4 downto 0);
			rs1 <= registers(to_integer(unsigned(full_instr(4 downto 0))));	
		else   
			instr <= full_instr(24 downto 23);
			if full_instr(23) = '0' then
				-- R4 INSTRUCTIONS 
				opcode <= "00000" & full_instr(22 downto 20);	  
				rs3_addr <= full_instr(19 downto 15);
				rs3 <= registers(to_integer(unsigned(full_instr(19 downto 15))));
				rs2_addr <= full_instr(14 downto 10);
				rs2 <= registers(to_integer(unsigned(full_instr(14 downto 10))));
				rs1_addr <= full_instr(9 downto 5);
				rs1 <= registers(to_integer(unsigned(full_instr(9 downto 5))));	
			else
				-- R3 INSTRUCTIONS
				opcode <= "0000" & full_instr(18 downto 15);	 	
				rs2_addr <= full_instr(14 downto 10);
				rs2 <= registers(to_integer(unsigned((full_instr(14 downto 10)))));
				rs1_addr <= full_instr(9 downto 5);
				rs1 <= registers(to_integer(unsigned((full_instr(9 downto 5)))));
			end if;
		end if;	
		
		-- The address for writing the result is the same part of every 25-bit instruction format
		rd_addr <= full_instr(4 downto 0);	 
		
		-- Update the registers text file with the current values of the registers
		file_open (file_pointer, "registers.txt", WRITE_MODE);
		for i in 0 to 31 loop 	 		  	 					   
			write (line_num, to_string(i) & ": " & to_string(registers(i)(127 downto 112)) & " " 
			& to_string(registers(i)(111 downto 96)) & " " & to_string(registers(i)(95 downto 80)) & " "
			& to_string(registers(i)(79 downto 64)) & " " & to_string(registers(i)(63 downto 48)) & " "
			& to_string(registers(i)(47 downto 32)) & " " & to_string(registers(i)(31 downto 16)) & " "
			& to_string(registers(i)(15 downto 0)));
			writeline (file_pointer, line_num);
		end loop;
		file_close (file_pointer);	   
		
   	end process;	
	   

   
	

end behavioral;