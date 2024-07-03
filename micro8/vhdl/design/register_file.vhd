library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 8 bits register file
entity register_file is 
	port(
		clk, we: in std_logic;
		din: in std_logic_vector(7 downto 0);
		ra: in std_logic_vector(1 downto 0);
		dout: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of register_file is

	type INTERN_MEMORY is array(0 to 3) of std_logic_vector(7 downto 0);

	signal intern: INTERN_MEMORY := (others => (others => '0'));

begin
	
	process(clk)

	begin

		if rising_edge(clk) then
			if we = '1' then
				intern(to_integer(unsigned(ra))) <= din;
			end if;
		end if;

	end process;

	dout <= intern(to_integer(unsigned(ra)));

end architecture;