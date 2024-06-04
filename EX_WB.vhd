-- A buffer between the execution and write back stages (stages 3 & 4)
-- The resulting output register value from the ALU is passed through
-- on every clock cycle. This buffer outputs that value, along with a 
-- reg_write signal	and register address to write to.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 	

entity ex_wb is
	port (									   
		rd_add : in std_logic_vector (4 downto 0);
		instr : in std_logic_vector(24 downto 0);
		val : in std_logic_vector (127 downto 0);	
		clk : in std_logic;							   
		val_out : out std_logic_vector (127 downto 0); 
		reg_write : out std_logic;
		rd_addr : out std_logic_vector (4 downto 0)
	);					  
end ex_wb;   			   


architecture structural of ex_wb is
begin
	process (clk, instr, val, rd_add)
	begin
		if rising_edge(clk) then 
			--report "rd_addr : " & to_string(rd_add);
			--report "val : " & to_string(val);
			--report "instr : " & to_string(instr);
			val_out <= val;  
			rd_addr <= rd_add;	   
			-- will only not write new value if the instruction is nop
			reg_write <= '0' when instr = "1100000000000000000000000" else '1';
		end if;	
	end process;
		

end structural;