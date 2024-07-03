library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register8 is
	port(
		clk, we: in std_logic;
		din: in std_logic_vector(7 downto 0);
		dout: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of register8 is

	signal intern: std_logic_vector(7 downto 0) := (others => '0');

begin

	process(clk)

	begin

		if rising_edge(clk) then
			if we = '1' then
				intern <= din;
			end if;
		end if;

	end process;

	dout <= intern;

end architecture;