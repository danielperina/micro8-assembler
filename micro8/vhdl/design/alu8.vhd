library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu8 is 
	port(
		a, b: in std_logic_vector(7 downto 0);
		aluop: in std_logic_vector(2 downto 0);
		dout: out std_logic_vector(7 downto 0);
		flags: out std_logic_vector(2 downto 0) -- n z c
	);
end entity;

architecture behavioral of alu8 is
	signal ror_din :  std_logic_vector(7 downto 0) := (others => '0');
	signal ror_shamt :  std_logic_vector(2 downto 0) := (others => '0');
	signal ror_result : std_logic_vector(7 downto 0) := (others => '0');
	signal ror_carry : std_logic := '0';

begin

	ror8: entity work.ror8 port map(
		din => ror_din,
		shamt => ror_shamt,
		dout => ror_result,
		cout => ror_carry
	);

	process(a, b)
	begin
		ror_din <= a;
		ror_shamt <= b(2 downto 0);
	end process;

	process(a, b, aluop, ror_result, ror_carry)

		variable tmpa: std_logic_vector(8 downto 0);
		variable tmpb: std_logic_vector(8 downto 0);
		variable tmpc: std_logic_vector(8 downto 0);
		variable result: std_logic_vector(7 downto 0);
		variable carry:  std_logic;

	begin

		case aluop is
			when "000" => -- add

				tmpa := "0" & a;
				tmpb := "0" & b;
				tmpc := std_logic_vector(unsigned(tmpa)+unsigned(tmpb));
				result := tmpc(7 downto 0);
				carry := tmpc(8);

			when "001" => -- sub

				tmpa := "0" & a;
				tmpb(8) := '0';
				tmpb(7 downto 0) := std_logic_vector(unsigned(not b)+1);
				tmpc := std_logic_vector(unsigned(tmpa)+unsigned(tmpb));
				result := tmpc(7 downto 0);
				carry := tmpc(8);

			when "010" => -- and

				tmpa := "0" & a;
				tmpb := "0" & b;
				tmpc := tmpa and tmpb;
				result := tmpc(7 downto 0);
				carry := tmpc(8);

			when "011" => -- or

				tmpa := "0" & a;
				tmpb := "0" & b;
				tmpc := tmpa or tmpb;
				result := tmpc(7 downto 0);
				carry := tmpc(8);

			when "100" => -- eor

				tmpa := "0" & a;
				tmpb := "0" & b;
				tmpc := tmpa xor tmpb;
				result := tmpc(7 downto 0);
				carry := tmpc(8);

			when "101" => -- ror

				result := ror_result;
				carry := ror_carry;

			when others =>
				result := b;
				carry := '0';
		end case;

		-- flag c
		flags(2) <= carry;
		dout <= result;

		-- flags n
		if result(7) = '1' then
			flags(0) <= '1';
		else
			flags(0) <= '0';
		end if;

		-- flag z
		if result = x"00" then
			flags(1) <= '1';
		else
			flags(1) <= '0';
		end if;

	end process;

end architecture;