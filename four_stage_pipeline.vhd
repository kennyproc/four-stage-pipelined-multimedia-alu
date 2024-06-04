-- The four-stage pipelined design in completion. Each component of the processor defined 
-- in separate entities is mapped together here.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_stage_pipeline is
	port (										   
		clk : in std_logic;
		reset : in std_logic;
		instruction, instruction2, instruction3 : out std_logic_vector (24 downto 0); 
		control1, control2, control3 : out std_logic;
		rs1_val, rs2_val, rs3_val, rd_val : out std_logic_vector (127 downto 0);	  
		write_address : out std_logic_vector (4 downto 0);
		write_value : out std_logic_vector (127 downto 0);
		reg_write : out std_logic
	);					  
end four_stage_pipeline; 						


architecture structural of four_stage_pipeline is 

component instruction_buffer is
	port (
		clock : in std_logic;
		instruction : out std_logic_vector (24 downto 0)
	);
end component;

component if_id is
	port (clock : in std_logic;
		instruction_in : in std_logic_vector (24 downto 0);
		instruction_out : out std_logic_vector (24 downto 0)
	);
end component;

component register_module is
	port (
		full_instr : in std_logic_vector (24 downto 0);
		reg_write : in std_logic;
		write_index : in std_logic_vector (4 downto 0);
		data : in std_logic_vector (127 downto 0);
		reset : in std_logic;
		rs1, rs2, rs3 : out std_logic_vector (127 downto 0);  
		opcode : out std_logic_vector (7 downto 0);
		load_index : out std_logic_vector (2 downto 0);
		imm : out std_logic_vector (15 downto 0);
		instr : out std_logic_vector (1 downto 0);
		rs1_addr, rs2_addr, rs3_addr : out std_logic_vector (4 downto 0);
		rd_addr : out std_logic_vector (4 downto 0)
	); 
end component;

component id_ex is
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
end component;

component mux is
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
end component;

component forwarding_unit is
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
end component;	 

component multimedia_alu is
	port (
		rs1 : in std_logic_vector (127 downto 0);
		rs2 : in std_logic_vector (127 downto 0);
		rs3 : in std_logic_vector (127 downto 0); 
		opcode : in std_logic_vector (7 downto 0); 
		load_index : in std_logic_vector (2 downto 0);
		imm : in std_logic_vector (15 downto 0);
		instr : in std_logic_vector (1 downto 0);	 
		rd : out std_logic_vector (127 downto 0)
	);
end component;

component ex_wb is
	port (
		instr : in std_logic_vector(24 downto 0);
		rd_add : in std_logic_vector (4 downto 0);
		val : in std_logic_vector (127 downto 0);  	
		clk : in std_logic;							  
		val_out : out std_logic_vector (127 downto 0); 
		rd_addr : out std_logic_vector (4 downto 0);
		reg_write : out std_logic
	);
end component;

	
signal instr_buff, instr_reg, instr_wb : std_logic_vector (24 downto 0);
signal rw : std_logic;	 
signal rst : std_logic;
signal write_addr : std_logic_vector (4 downto 0);
signal write_val : std_logic_vector (127 downto 0);
signal r1, r2, r3, rd : std_logic_vector (127 downto 0);
signal opc : std_logic_vector (7 downto 0);	
signal opc_1 : std_logic_vector (7 downto 0);	
signal imm : std_logic_vector (15 downto 0);
signal imm_1 : std_logic_vector (15 downto 0);
signal load_in : std_logic_vector (2 downto 0);
signal load_in_1 : std_logic_vector (2 downto 0);
signal instr_id : std_logic_vector (1 downto 0); 
signal instr_id_1 : std_logic_vector (1 downto 0);
signal r1_addr, r2_addr, r3_addr, rd_add, rd_addr : std_logic_vector (4 downto 0); 
signal r1_addr_1, r2_addr_1, r3_addr_1 : std_logic_vector (4 downto 0); 
signal val1, val2, val3 : std_logic_vector (127 downto 0);
signal ctrl1, ctrl2, ctrl3 : std_logic;
signal val1_1, val2_1, val3_1 : std_logic_vector (127 downto 0);

begin 
	
	-- input clk signal, output instruction goes to if_id
	u1 : instruction_buffer port map (clock => clk, instruction => instr_buff);				   
	
	-- input clk signal, input instruction from instruction_buffer, output instruction goes to register_module
	u2 : if_id port map (clock => clk, instruction_in => instr_buff, instruction_out => instr_reg);	  
	
	-- input instruction from if_id, input data	for writing comes from ex_wb, outputs decoded instruction
	u3 : register_module port map (full_instr => instr_reg, reg_write => rw, write_index => write_addr,
		data => write_val, reset => rst, rs1 => r1, rs2 => r2, rs3 => r3, opcode => opc, 
		imm => imm, load_index => load_in, instr => instr_id, rs1_addr => r1_addr,
		rs2_addr => r2_addr, rs3_addr => r3_addr, rd_addr => rd_add);				   
	
	-- inputs decoded instruction from register_module, outputs decoded instruction to multimedia_alu.
	-- outputs rs1, rs2, rs3 addresses to forwarding unit and values to multiplexer
	u4 : id_ex port map (clk => clk, instruction => instr_reg, val1 => r1, val2 => r2, val3 => r3,
		rd_add => rd_add, opcode => opc, load_index => load_in, imm => imm, instr => instr_id, 
		rs1_addr => r1_addr, rs2_addr => r2_addr, rs3_addr => r3_addr, instruction_out => instr_wb, 
		val1_out => val1, val2_out => val2, val3_out => val3, rd_addr => rd_addr, rs1_add => r1_addr_1,
		rs2_add => r2_addr_1, rs3_add => r3_addr_1, opcode_out => opc_1, load_index_out => load_in_1,
		imm_out => imm_1, instr_out => instr_id_1);		
	
	-- inputs ctrl signals from forwarding_unit, values 1-3 from id_ex, wb value from ex_wb
	-- outputs rs1, rs2, rs3 values to be used in multimedia_alu
	u5 : mux port map (ctrl1 => ctrl1, ctrl2 => ctrl2, ctrl3 => ctrl3, val1 => val1, val2 => val2,
	val3 => val3, wbval => write_val, val1_out => val1_1, val2_out => val2_1, val3_out => val3_1); 
	
	-- inputs rs1, rs2, rs3 addresses from id_ex, wb address and reg_write from ex_wb  
	-- outputs multiplexer control signals
	u6 : forwarding_unit port map (rs1_addr => r1_addr_1, rs2_addr => r2_addr_1, rs3_addr => r3_addr_1,
	rd_addr => write_addr, reg_write => rw, ctrl1 => ctrl1, ctrl2 => ctrl2, ctrl3 => ctrl3);	
	
	-- inputs rs1, rs2, rs3 values from multiplexer, other decoded parts of instruction from id_ex
	-- outputs the computed register value to be used in ex_wb
	u7 : multimedia_alu port map (rs1 => val1_1, rs2 => val2_1, rs3 => val3_1, opcode => opc_1, 
	load_index => load_in_1, imm => imm_1, instr => instr_id_1, rd => rd);		
	
	-- inputs register value from multimedia_alu, the address to be written to from id_ex
	-- outputs the value to be written, the address to write to, and the reg_write signal, all
	-- to be used in the register_module
	u8 : ex_wb port map (clk => clk, val => rd, instr => instr_wb, rd_add => rd_addr, val_out => write_val,
		rd_addr => write_addr, reg_write => rw);
	
	-- Stage 1
	instruction <= instr_buff; 
	
	-- Stage 2
	instruction2 <= instr_reg;
	rs1_val <= r1;
	rs2_val <= r2;
	rs3_val <= r3; 
	
	-- Stage 3	   
	control1 <= ctrl1;
	control2 <= ctrl2;
	control3 <= ctrl3;
	instruction3 <= instr_wb;
	rd_val <= rd;
	
	-- Stage 4	 
	reg_write <= rw;
	write_address <= write_addr;
	write_value <= write_val; 
	
	rst <= reset;
	
	

end structural;