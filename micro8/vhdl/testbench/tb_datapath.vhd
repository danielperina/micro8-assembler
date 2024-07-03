library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_datapath is
end entity;

architecture behavioral of tb_datapath is

	signal tb_clk: std_logic := '0';
	signal tb_enable: std_logic := '0';
	signal tb_rst: std_logic := '0';
	signal tb_running: std_logic := '0';

	signal tb_ext_mem_addr: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_ext_mem_en: std_logic := '0';
	signal tb_sel_ext_addr: std_logic := '0';
	signal tb_sel_ext_me: std_logic := '0';
	signal tb_ext_mem_din: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_sel_ext_din: std_logic := '0';

	type character_file is file of character;
    file bin_file : character_file;

begin

	uut: entity work.datapath port map(
		clk => tb_clk, 
		enable => tb_enable, 
		rst => tb_rst, 
		sel_ext_din => tb_sel_ext_din,
		sel_ext_addr => tb_sel_ext_addr, 
		sel_ext_me => tb_sel_ext_me, 
		ext_mem_en => tb_ext_mem_en,
		ext_mem_din => tb_ext_mem_din, 
		ext_mem_addr => tb_ext_mem_addr,
		running => tb_running
	);

	process
		variable byte_buffer : character;
		variable i : natural := 0;
	begin

		-- Inicializa os sinais para carregar o programa
		tb_sel_ext_me <= '1';
		tb_sel_ext_addr <= '1';
		tb_sel_ext_din <= '1';
		tb_ext_mem_en <= '1';
		
		file_open(bin_file, "test.mem", READ_MODE);
		while not endfile(bin_file) and i < 256 loop
			read(bin_file, byte_buffer);
			tb_ext_mem_din <= std_logic_vector(to_unsigned(character'pos(byte_buffer), 8));
			tb_ext_mem_addr <= std_logic_vector(to_signed(i, 8));
			i := i + 1;

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';
		end loop;
		file_close(bin_file);

		-- Finaliza os sinais de carregamento
		tb_ext_mem_en <= '0';
		tb_sel_ext_din <= '0';
		tb_sel_ext_me <= '0';
		tb_sel_ext_addr <= '0';

		-- Inicia a execução do programa
		tb_enable <= '1';
		wait for 5 ns;
		while tb_running = '1' loop
			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';
		end loop; 

		tb_enable <= '0';
		tb_rst <= '1';
		wait for 5 ns;
		tb_rst <= '0';
		wait for 5 ns;
		report "Tests finished." severity note;
		wait;
	end process;

end architecture;
