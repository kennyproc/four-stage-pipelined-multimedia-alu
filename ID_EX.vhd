-- A buffer between the instruction decode and execution stages (stages 2 & 3)
-- On each clock cycle, each of the output values from the decoding stage is simply
-- passed through to the ALU for execution.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 	

entity id_ex is
	port (			
		instruction : in std_logic_vector(24 downto 0);
		val1 : in std_logic_vector (127 downto 0);
		val2 : in std_logic_vector (127 downto 0);
		val3 : in std_logic_vector (127 downto 0); 
		rd_add : in std_logic_vector (4 downto 0);
		opcode : in std_logic_vector (7 downto 0);
		load_index : in std_logic_vector (2 downto 0);
		imm : in std_logic_vector (15 downto 0);
		instr : in std_logic_vector (1 downto 0);
		rs1_addr, rs2_addr, rs3_addr : in std_logic_vector (4 downto 0);  
		clk : in std_logic;							   
		rs1_add, rs2_add, rs3_add : out std_logic_vector (4 downto 0);
		instruction_out : out std_logic_vector(24 downto 0); 
		opcode_out : out std_logic_vector (7 downto 0);
		load_index_out : out std_logic_vector (2 downto 0);
		imm_out : out std_logic_vector (15 downto 0);
		instr_out : out std_logic_vector (1 downto 0);
		val1_out : out std_logic_vector (127 downto 0);
		val2_out : out std_logic_vector (127 downto 0);
		val3_out : out std_logic_vector (127 downto 0);
		rd_addr : out std_logic_vector (4 downto 0)
	);					  
end id_ex;   			   


architecture structural of id_ex is
begin
	process (clk, instruction, val1, val2, val3, instr, imm, load_index, rd_add, rs1_addr, rs2_addr, rs3_addr, opcode)
	begin
		if rising_edge(clk) then 
			instruction_out <= instruction;
			val1_out <= val1;  
			val2_out <= val2;
			val3_out <= val3; 
			instr_out <= instr;
			imm_out <= imm;
			load_index_out <= load_index;
			rd_addr <= rd_add;
			rs1_add <= rs1_addr;
			rs2_add <= rs2_addr;
			rs3_add <= rs3_addr;
			opcode_out <= opcode;
		end if;
	end process;
		

end structural;