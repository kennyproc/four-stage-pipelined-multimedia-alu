library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.all;

entity register_module_tb is
end register_module_tb;

architecture tb_architecture of register_module_tb is

-- stimulus signals
signal full_instr : std_logic_vector (24 downto 0);
signal reg_write : std_logic;
signal write_index : std_logic_vector (4 downto 0);
signal data : std_logic_vector (127 downto 0);
signal reset : std_logic;
signal rs1 : std_logic_vector (127 downto 0);
signal rs2 : std_logic_vector (127 downto 0);
signal rs3 : std_logic_vector (127 downto 0);
signal opcode : std_logic_vector (7 downto 0);
signal load_index : std_logic_vector (2 downto 0);
signal imm : std_logic_vector (15 downto 0);
signal instr : std_logic_vector (1 downto 0);
signal rs1_addr : std_logic_vector (4 downto 0);
signal rs2_addr : std_logic_vector (4 downto 0);
signal rs3_addr : std_logic_vector (4 downto 0);

constant period : time := 10ns;

begin


    -- Unit Under Test port map
    UUT : entity register_module
        port map (
			full_instr => full_instr,
			reg_write => reg_write,
			write_index => write_index,
			data => data,  
			reset => reset,
			rs1 => rs1,
			rs2 => rs2,
			rs3 => rs3,
			opcode => opcode,
			load_index => load_index,
			imm => imm,
			instr => instr,
			rs1_addr => rs1_addr,
			rs2_addr => rs2_addr,
			rs3_addr => rs3_addr
        );														 

        
	stimulus: process
    begin	  
		
		reset <= '1', '0' after 10ns;
		
		full_instr <= "0000000000000110010000000";
		reg_write <= '1';
		write_index <= "00000";
		data <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        wait for 20 ns;		
		
		
		full_instr <= "0101111010100110000000000";
		reg_write <= '1';
		write_index <= "00001";
		data <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		wait for 20ns;
		
		
		full_instr <= "0011000000011010011100000";
		reg_write <= '1';
		write_index <= "00001";
		data <= "00000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000010000000000000000";
        wait for 20 ns;	
		
		full_instr <= "0001000000000000001000000";
		reg_write <= '1';
		write_index <= "00000";
		data <= "00000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000010000000000000000";
        wait for 20 ns;	
		
		
		full_instr <= "0010000000000100101100000";
		reg_write <= '1';
		write_index <= "00000";
		data <= "00000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000000100000000000000000000";
        wait for 20 ns;	
		
		
		full_instr <= "0111000001011101110000001";
		reg_write <= '1';
		write_index <= "00011";
		data <= "00000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000001000000000000000000000000";
        wait for 20 ns;	
	
	end process;

end tb_architecture;