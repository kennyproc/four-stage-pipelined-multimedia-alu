-- Testbench to verify the complete four_stage_pipeline is working.
-- On each clock cycle, information on each of the stages is written
-- to a results.txt file. The register file can also be viewed at the
-- end of simulation to check the state of each register.

-- Run the simulation for (20n + 60) nanoseconds for n instructions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use std.textio.all;
use work.all;

entity four_stage_pipeline_tb is
end four_stage_pipeline_tb;

architecture tb_architecture of four_stage_pipeline_tb is

-- stimulus signals
signal clk : std_logic := '0';
signal reset : std_logic := '1';
signal instruction, instruction2, instruction3 : std_logic_vector (24 downto 0);
signal rs1_val, rs2_val, rs3_val, rd_val : std_logic_vector (127 downto 0);	 
signal control1, control2, control3 : std_logic;
signal write_address : std_logic_vector (4 downto 0);
signal write_value : std_logic_vector (127 downto 0);
signal reg_write : std_logic;

constant period : time := 10ns;

begin


    -- Unit Under Test port map
    UUT : entity four_stage_pipeline
        port map (
			clk => clk,
			reset => reset,
			instruction => instruction,
			instruction2 => instruction2,
			instruction3 => instruction3,
			control1 => control1,
			control2 => control2,
			control3 => control3,
			rs1_val => rs1_val,
			rs2_val => rs2_val,
			rs3_val => rs3_val,
			rd_val => rd_val,
			write_address => write_address,
			write_value => write_value,
			reg_write => reg_write
        );														 
		
        clock : process                -- system clock	 
		file file_pointer : text;  
		variable file_is_open : boolean := false;
		variable line_content : std_logic_vector (127 downto 0);
		variable line_num : line;
		variable j : integer := 1;
        begin										
			reset <= '1', '0' after 10ns;
            for i in 0 to 1032 loop
                wait for period;
                clk <= not clk;
				if clk = '1' then
					if not file_is_open then
						file_open (file_pointer, "results.txt", WRITE_MODE); 
						file_is_open := true;
					end if;	  	   
					
					write (line_num, "Cycle: " & to_string(j) & ":");
					writeline (file_pointer, line_num);	  
												    					   
					write (line_num, "    Stage 1:  instr = " & to_string(instruction));
					writeline (file_pointer, line_num);
					
					write (line_num, "    Stage 2:  instr = " & to_string(instruction2)); 
					writeline (file_pointer, line_num);	
					write (line_num, "                rs1 = " & to_string(rs1_val));
					writeline (file_pointer, line_num);	
					write (line_num, "                rs2 = " & to_string(rs2_val)); 
					writeline (file_pointer, line_num);	
					write (line_num, "                rs3 = " & to_string(rs3_val));
					writeline (file_pointer, line_num);	
					
					write (line_num, "    Stage 3:  instr = " & to_string(instruction3));
					writeline (file_pointer, line_num);
					write (line_num, "                 rd = " & to_string(rd_val));
					writeline (file_pointer, line_num);	   
					if (control1 = '1' or control2 = '1' or control3 = '1') then
						write (line_num, "               Data forwarding occurs");
						writeline (file_pointer, line_num);
					end if;
					
					write (line_num, "    Stage 4:  reg_write = " & to_string(reg_write));
					writeline (file_pointer, line_num);
					write (line_num, "                val = " & to_string(write_value));
					writeline (file_pointer, line_num);
					write (line_num, "               addr = " & to_string(write_address));
					writeline (file_pointer, line_num);	
					
					write (line_num, " ");
					writeline (file_pointer, line_num);
					
					j := j + 1;
				end if;
            end loop;
            wait;
        end process;

    end tb_architecture;