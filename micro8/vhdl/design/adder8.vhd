library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder8 is
	port(
		cin: in std_logic;
		a, b: in std_logic_vector(7 downto 0);
		sum: out std_logic_vector(7 downto 0);
		cout: out std_logic
	);
end entity;

architecture behavioral of adder8 is

begin
	
	process(cin, a, b)
		variable tmpa: std_logic_vector(8 downto 0);
		variable tmpb: std_logic_vector(8 downto 0);
		variable tmpc: std_logic_vector(8 downto 0);
		variable temp: std_logic_vector(8 downto 0);
	begin

		tmpa := '0' & a;
		tmpb := '0' & b;
		tmpc := "00000000" & cin;
		temp := std_logic_vector(unsigned(tmpa)+unsigned(tmpb)+unsigned(tmpc));

		sum <= temp(7 downto 0);
		cout <= temp(8);

	end process;

end architecture;