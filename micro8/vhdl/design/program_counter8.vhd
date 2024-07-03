library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity program_counter8 is
	port(
		clk, we, bre: in std_logic;
		din: in std_logic_vector(7 downto 0);
		dout: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of program_counter8 is

	signal intern: std_logic_vector(7 downto 0) := (others => '0');

begin

	process(clk)
	begin

		if rising_edge(clk) then
			if we = '1' then
				if bre = '1' then
					intern <= din;
				else
					intern <= std_logic_vector(unsigned(intern)+1);
				end if;
			end if;
		end if;

	end process;

	dout <= intern;

end architecture;