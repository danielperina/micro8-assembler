library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_alu8 is 
	--port(
	--	a, b: in std_logic_vector(7 downto 0);
	--	sel: in std_logic_vector(2 downto 0);
	--	dout: out std_logic_vector(7 downto 0);
	--	flags: out std_logic_vector(2 downto 0) -- n z c
	--);
end entity;

architecture behavioral of tb_alu8 is

	type test_format is record
		a, b, dout: std_logic_vector(7 downto 0);
		aluop, flags: std_logic_vector(2 downto 0);
	end record;

	type test_array is array(natural range<>) of test_format;

	signal tb_a: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_b: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_aluop: std_logic_vector(2 downto 0) := (others => '0');
	signal tb_dout: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_flags: std_logic_vector(2 downto 0) := (others => '0');

	constant tests : test_array := (
		(a => x"80", b => x"80", aluop => o"0", dout => x"00", flags => o"6"), -- add
		(a => x"7f", b => x"7f", aluop => o"0", dout => x"fe", flags => o"1"), -- add
		(a => x"00", b => x"04", aluop => o"1", dout => x"fc", flags => o"1"), -- sub
		(a => x"01", b => x"ff", aluop => o"1", dout => x"02", flags => o"0"), -- sub
		(a => x"55", b => x"ff", aluop => o"2", dout => x"55", flags => o"0"), -- and
		(a => x"80", b => x"7f", aluop => o"2", dout => x"00", flags => o"2"), -- and
		(a => x"80", b => x"7f", aluop => o"3", dout => x"ff", flags => o"1"), -- or
		(a => x"55", b => x"aa", aluop => o"3", dout => x"ff", flags => o"1"), -- or
		(a => x"ff", b => x"7f", aluop => o"4", dout => x"80", flags => o"1"), -- eor
		(a => x"55", b => x"fa", aluop => o"4", dout => x"af", flags => o"1"), -- eor
		(a => x"c0", b => x"07", aluop => o"5", dout => x"81", flags => o"5"), -- ror
		(a => x"aa", b => x"01", aluop => o"5", dout => x"55", flags => o"0") -- ror
	);

begin

	uut: entity work.alu8 port map(
		a => tb_a,
		b => tb_b,
		aluop => tb_aluop,
		dout => tb_dout,
		flags => tb_flags
	);

	stimulus: process
	begin

		for i in tests'range loop
			tb_aluop <= tests(i).aluop;
			tb_a <= tests(i).a;
			tb_b <= tests(i).b;
			
			wait for 5 ns;

			assert tb_dout = tests(i).dout report "Unexpected value for dout at test no." & integer'image(i) & ", expect " & integer'image(to_integer(unsigned(tests(i).dout))) & " receive " & integer'image(to_integer(unsigned(tb_dout))) severity error;
			assert tb_flags = tests(i).flags report "Unexpected value for flags at test no." & integer'image(i) & ", expect " & integer'image(to_integer(unsigned(tests(i).flags))) & " receive " & integer'image(to_integer(unsigned(tb_flags))) severity error;

		end loop;

		report "Tests finished." severity note;

		wait;
	end process;

end architecture;