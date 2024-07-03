library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem8x8 is
	port(
		clk, we: in std_logic;
		din, addr: in std_logic_vector(7 downto 0);
		dout: out std_logic_vector(7 downto 0) 
	);
end entity;

architecture behavioral of mem8x8 is
	
	type MEM is array(0 to 255) of std_logic_vector(7 downto 0);

	signal intern: MEM := (others => (others => '0'));

begin

	process(clk, we)
	begin
		if rising_edge(clk) then
			if we = '1' then
				intern(to_integer(unsigned(addr))) <= din;
			end if;
		end if;
	end process;

	dout <= intern(to_integer(unsigned(addr)));

end architecture;