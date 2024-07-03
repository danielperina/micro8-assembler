library IEEE;

use IEEE.std_logic_1164.all;

entity ror8 is
	port(
		shamt: in std_logic_vector(2 downto 0);
		din: in std_logic_vector(7 downto 0);
		dout: out std_logic_vector(7 downto 0);
		cout: out std_logic
	);
end entity;

architecture behavioral of ror8 is

begin

	process(din, shamt)
		variable temp: std_logic_vector(7 downto 0);
		variable c: std_logic;
	begin

		case shamt is
			when "000" =>
				temp := din;
				c := '0';
			when "001" =>
				temp(7) := din(0);
				temp(6 downto 0) := din(7 downto 1);
				c := din(0); 
			when "010" =>
				temp(7 downto 6) := din(1 downto 0);
				temp(5 downto 0) := din(7 downto 2);
				c := din(1);
			when "011" =>
				temp(7 downto 5) := din(2 downto 0);
				temp(4 downto 0) := din(7 downto 3);
				c := din(2);
			when "100" =>
				temp(7 downto 4) := din(3 downto 0);
				temp(3 downto 0) := din(7 downto 4);
				c := din(3);
			when "101" =>
				temp(7 downto 3) := din(4 downto 0);
				temp(2 downto 0) := din(7 downto 5);
				c := din(4);
			when "110" =>
				temp(7 downto 2) := din(5 downto 0);
				temp(1 downto 0) := din(7 downto 6);
				c := din(5);
			when "111" =>
				temp(7 downto 1) := din(6 downto 0);
				temp(0) := din(7);
				c := din(6);
			when others =>
				temp := din;
				c := '0';
		end case;

		dout <= temp;
		cout <= c;

	end process;

end architecture;