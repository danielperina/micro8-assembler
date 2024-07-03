library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_program_counter8 is
	port(
		clk, we, bre: in std_logic;
		din: in std_logic_vector(7 downto 0);
		dout: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of tb_program_counter8 is

	type test_format is record
		we, bre: std_logic;
		din, dout: std_logic_vector(7 downto 0); 
	end record;

	type test_array is array(natural range<>) of test_format;

	signal tb_clk: std_logic := '0';
	signal tb_we: std_logic := '0'; 
	signal tb_bre: std_logic := '0';
	signal tb_din: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_dout: std_logic_vector(7 downto 0) := (others => '0');

	constant tests : test_array := (
		(we => '0', bre => '0', din => x"00", dout => x"00"),
		(we => '0', bre => '1', din => x"ff", dout => x"00"),
		(we => '1', bre => '1', din => x"ff", dout => x"ff"),
		(we => '1', bre => '0', din => x"01", dout => x"00"),
		(we => '1', bre => '0', din => x"00", dout => x"01"),
		(we => '1', bre => '1', din => x"80", dout => x"80"),
		(we => '1', bre => '0', din => x"00", dout => x"81")
	);

begin

	uut: entity work.program_counter8 port map(
		clk => tb_clk,
		we => tb_we,
		bre => tb_bre,
		din => tb_din,
		dout => tb_dout
	);

	process
	begin

		for i in tests'range loop

			tb_din <= tests(i).din;
			tb_we <= tests(i).we;
			tb_bre <= tests(i).bre;

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';
			
			assert tb_dout = tests(i).dout report "Unexpected value for dout at test no." & integer'image(i) & ", expect " & integer'image(to_integer(unsigned(tests(i).dout))) & " found " & integer'image(to_integer(unsigned(tb_dout))) severity error;			
			
		end loop;

		report "Tests finished." severity note;
		wait;
	end process;

end architecture;