-- The multiplexers process the values that have been read for rs1, rs2, and rs3
-- to be used for stage 3 (the ALU), along with the current write back value. If
-- a control signal is set by the forwarding unit, the write back value is used 
-- in place of rs1, rs2, or rs3. Otherwise, the values that had been read in
-- during stage 2 are still used. The values are outputted and used in the ALU.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 	

entity mux is
	port (			
		ctrl1 : in std_logic;
		ctrl2 : in std_logic;
		ctrl3 : in std_logic;
		val1 : in std_logic_vector (127 downto 0);
		val2 : in std_logic_vector (127 downto 0);
		val3 : in std_logic_vector (127 downto 0);
		wbval : in std_logic_vector (127 downto 0);
		val1_out : out std_logic_vector (127 downto 0);	 
		val2_out : out std_logic_vector (127 downto 0);
		val3_out : out std_logic_vector (127 downto 0)
	);					  
end mux;   


architecture behavioral of mux is

begin
	process (ctrl1, ctrl2, ctrl3, val1, val2, val3, wbval)
	begin
		if ctrl1 = '1' then
			val1_out <= wbval;
		else 
			val1_out <= val1;
		end if;
		if ctrl2 = '1' then	   				 
			val2_out <= wbval;
		else 
			val2_out <= val2;
		end if;
		if ctrl3 = '1' then
			val3_out <= wbval;
		else 
			val3_out <= val3;
		end if;	 
	end process;
end behavioral;	