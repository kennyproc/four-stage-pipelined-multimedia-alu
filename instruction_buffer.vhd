-- Stage 1 of the 4-stage pipelined design
-- Reads up to 64 25-bit machine code instructions from a text file. On each clock cycle,
-- the instruction specified by the program counter PC is fetched, and PC is incremented by 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instruction_buffer is
	port (										   
		clock : in std_logic;
		instruction : out std_logic_vector(24 downto 0)
	);					  
end instruction_buffer;	

architecture behavioral of instruction_buffer is
type instructionArray is array (0 to 63) of std_logic_vector(24 downto 0);
signal instructions : instructionArray;	-- used to store the 64 instructions read from the file	

begin 	 
	process	(clock)
		file file_pointer : text;
		variable line_content : std_logic_vector (24 downto 0);
		variable line_num : line;
		variable j : integer := 0;			   
	begin
		file_open (file_pointer, "output.txt", READ_MODE);
		while ((not endfile(file_pointer)) and j < 64) loop 
			readline (file_pointer, line_num);
			READ (line_num,line_content);  
			instructions(j) <= line_content;
			j := j + 1;
		end loop;
		file_close (file_pointer);		
	
	end process;	
	
		
	process(clock)
	variable PC : integer := 0;
	begin
	if rising_edge(clock) then	
		-- For each clock cycle, fetch the instruction specified by PC
		if (PC < 64) then
			instruction <= instructions(PC);
		end if;
		PC := PC + 1;
	end if;	  
	end process;
end behavioral;

	
	
	
