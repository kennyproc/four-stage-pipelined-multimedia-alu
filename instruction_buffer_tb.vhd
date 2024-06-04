library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.all;

entity instruction_buffer_tb is
end instruction_buffer_tb;

architecture tb_architecture of instruction_buffer_tb is

-- stimulus signals
signal clock : std_logic := '0';
signal instruction : std_logic_vector (24 downto 0);

constant period : time := 10ns;

begin


    -- Unit Under Test port map
    UUT : entity instruction_buffer
        port map (
			clock => clock,
			instruction => instruction
        );														 

        clk : process                -- system clock
        begin
            for i in 0 to 1032 loop
                wait for period;
                clock <= not clock;
            end loop;
            wait;
        end process;

    end tb_architecture;