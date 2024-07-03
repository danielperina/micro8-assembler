library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 8 bits register file
entity tb_register_file is 
	--port(
	--	clk, we: in std_logic;
	--	din: in std_logic_vector(7 downto 0);
	--	ra: in std_logic_vector(1 downto 0);
	--	dout: out std_logic_vector(7 downto 0)
	--);
end entity;

architecture behavioral of tb_register_file is

	--type INTERN_MEMORY is array(0 to 3) of std_logic_vector(7 downto 0);

	--signal intern: INTERN_MEMORY := (others => (others => '0'));

	signal tb_clk	: std_logic := '0';
	signal tb_we	: std_logic := '0';

	signal tb_din	: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_dout	: std_logic_vector(7 downto 0) := (others => '0');

	signal tb_ra	: std_logic_vector(1 downto 0) := (others => '0');

begin
	
	uut: entity work.register_file port map(
		clk => tb_clk,
		we => tb_we,
		din => tb_din,
		ra => tb_ra,
		dout => tb_dout
	);

	process
	begin

		tb_we <= '0';
		for i in 0 to 3 loop
			tb_din <= x"ff"; 
			tb_ra <= std_logic_vector(to_unsigned(i, 2));

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';
		end loop;

		for i in 0 to 3 loop
			tb_ra <= std_logic_vector(to_unsigned(i, 2));

			wait for 5 ns;

			assert tb_dout = x"00" report "Unexpected value for ra at test1 no." & integer'image(i) & ", expect 0 found " & integer'image(to_integer(unsigned(tb_dout))) severity error;
		end loop;

		tb_we <= '1';
		for i in 0 to 3 loop
			tb_din <= x"ff"; 
			tb_ra <= std_logic_vector(to_unsigned(i, 2));

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';
		end loop;

		for i in 0 to 3 loop
			tb_ra <= std_logic_vector(to_unsigned(i, 2));

			wait for 5 ns;

			assert tb_dout = x"ff" report "Unexpected value for ra at test2 no." & integer'image(i) & ", expect 255 found " & integer'image(to_integer(unsigned(tb_dout))) severity error;
		end loop;

		report "Tests finished." severity note;

		wait;
	end process;

end architecture;