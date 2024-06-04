-- The forwarding unit is used to determine if any of the 3 registers being
-- read and used for stage 3 of the pipeline are the same address as the one
-- being written to in stage 4. If this is the case, a control signal is sent
-- to a multiplexer so the value to be written is used in place of the current
-- value of rs1, rs2, or rs3 in the ALU. This is because the values of rs1, rs2,
-- and rs3 are read during stage 2, so the registers will not yet have been 
-- written to from a previous instruction at that time.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
	port (										   
		rs1_addr : in std_logic_vector (4 downto 0);
		rs2_addr : in std_logic_vector (4 downto 0);
		rs3_addr : in std_logic_vector (4 downto 0);
		rd_addr : in std_logic_vector (4 downto 0);	
		reg_write : in std_logic;
		ctrl1 : out std_logic;
		ctrl2 : out std_logic;
		ctrl3 : out std_logic
	);					  
end forwarding_unit; 

architecture behavioral of forwarding_unit is
begin		
	process(rs1_addr, rs2_addr, rs3_addr, rd_addr)
	begin		
	
	if (rs1_addr = rd_addr and reg_write = '1') then
		ctrl1 <= '1'; 
	else
		ctrl1 <= '0';
	end if;	
	
	if (rs2_addr = rd_addr and reg_write = '1') then 							  
		ctrl2 <= '1';  
	else
		ctrl2 <= '0';
	end if;	
	
	if (rs3_addr = rd_addr and reg_write = '1') then
		ctrl3 <= '1'; 
	else
		ctrl3 <= '0';
	end if;	
	end process;
	
	
end architecture;

	
