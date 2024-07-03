library IEEE;

use IEEE.std_logic_1164.all;

entity tb_ror8 is
	--port(
	--	shamt: in std_logic_vector(2 downto 0);
	--	din: in std_logic_vector(7 downto 0);
	--	dout: out std_logic_vector(7 downto 0);
	--	cout: out std_logic
	--);
end entity;

architecture behavioral of tb_ror8 is
	
	signal tb_shamt	: std_logic_vector(2 downto 0) := (others => '0');
	signal tb_din 	: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_dout	: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_cout	: std_logic := '0';

	type test_format is record
		cout: std_logic;
		shamt: std_logic_vector(2 downto 0);
		din, dout: std_logic_vector(7 downto 0);
	end record;

	type test_array is array(natural range<>) of test_format;

	constant tests: test_array := (
		(din => x"55", shamt => "000", dout => x"55", cout => '0'),
		(din => x"55", shamt => "001", dout => x"aa", cout => '1'),
		(din => x"55", shamt => "010", dout => x"55", cout => '0'),
		(din => x"55", shamt => "011", dout => x"aa", cout => '1'),
		(din => x"55", shamt => "100", dout => x"55", cout => '0'),
		(din => x"55", shamt => "101", dout => x"aa", cout => '1'),
		(din => x"55", shamt => "110", dout => x"55", cout => '0'),
		(din => x"55", shamt => "111", dout => x"aa", cout => '1'),
		(din => x"80", shamt => "000", dout => x"80", cout => '0'),
		(din => x"80", shamt => "001", dout => x"40", cout => '0'),
		(din => x"80", shamt => "010", dout => x"20", cout => '0'),
		(din => x"80", shamt => "011", dout => x"10", cout => '0'),
		(din => x"80", shamt => "100", dout => x"08", cout => '0'),
		(din => x"80", shamt => "101", dout => x"04", cout => '0'),
		(din => x"80", shamt => "110", dout => x"02", cout => '0'),
		(din => x"80", shamt => "111", dout => x"01", cout => '0')
	);
begin
	uut: entity work.ror8 port map(
		din => tb_din,
		shamt => tb_shamt,
		dout => tb_dout,
		cout => tb_cout
	);

	stimulus: process
	begin

		for i in tests'range loop

			tb_din <= tests(i).din;
			tb_shamt <= tests(i).shamt;

			wait for 5 ns;

			assert tb_dout = tests(i).dout report "Unexpected value for dout at test no." & integer'image(i) severity error;
			assert tb_cout = tests(i).cout report "Unexpected value for cout at test no." & integer'image(i) severity error;

		end loop;

		report "Tests finished." severity note;

		wait;
	end process;
end architecture;