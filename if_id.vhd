-- A buffer between the instruction fetch and instruction decode stages (stages 1 & 2)
-- On each clock cycle, the instruction read from the instruction buffer is simply
-- passed through to stage 2 (the register module)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_id is
	port (										   
		clock : in std_logic;
		instruction_in : in std_logic_vector(24 downto 0);
		instruction_out : out std_logic_vector(24 downto 0)
	);					  
end if_id;		   

architecture structural of if_id is 
begin
	process(clock, instruction_in)
	begin
	if rising_edge(clock) then
		instruction_out <= instruction_in;
	end if;	  
	end process; 
end structural;
