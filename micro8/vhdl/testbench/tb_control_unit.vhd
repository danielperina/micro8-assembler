library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_control_unit is
end entity;

architecture behavioral of tb_control_unit is

	signal tb_clk: std_logic := '0';
	signal tb_enable: std_logic := '0';
	signal tb_rst: std_logic := '0';
	
	signal tb_nop: std_logic := '0';
	signal tb_str: std_logic := '0';
	signal tb_ldr: std_logic := '0';
	signal tb_b: std_logic := '0';
	signal tb_jsr: std_logic := '0';
	signal tb_ret: std_logic := '0';
	signal tb_hlt: std_logic := '0';
	signal tb_mode: std_logic_vector(1 downto 0) := (others => '0'); -- imd, dir, ind, rdx 
	
	signal tb_pc_en: std_logic := '0';
	signal tb_bre: std_logic := '0';
	signal tb_mar_en: std_logic := '0';
	signal tb_ir_en: std_logic := '0';
	signal tb_lr_en: std_logic := '0';
	signal tb_rf_en: std_logic := '0';
	signal tb_mem_en: std_logic := '0';

	signal tb_sel_ra: std_logic := '0';
	signal tb_sel_ba: std_logic := '0';
	signal tb_sel_ma: std_logic := '0';
	signal tb_sel_mar_d0: std_logic := '0';
	signal tb_sel_mar_d1: std_logic := '0';
	signal tb_op_en: std_logic := '0';

	signal tb_rf_out: std_logic_vector(7 downto 0) := (others => '0'); -- register_file out
	signal tb_maddr: std_logic_vector(7 downto 0) := (others => '0'); -- memory address (pc ou mar)

	signal tb_mem: std_logic_vector(7 downto 0) := (others => '0'); -- memory data
	signal tb_me: std_logic := '0';
	signal tb_mem_din: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_mem_addr: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_ext_mem_addr: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_ext_mem_en: std_logic := '0';
	signal tb_sel_ext_addr: std_logic := '0';
	signal tb_sel_ext_me: std_logic := '0';
	signal tb_ext_mem_din: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_sel_ext_din: std_logic := '0';

	--type PROG_DATA_FORMAT is record
	--	data, addr: std_logic_vector(7 downto 0);
	--end record;

	--type PROG_DATA is array(natural range<>) of PROG_DATA_FORMAT;
	--constant prog: PROG_DATA := ((data => x"20", addr => x"00"), (data => x"0a", addr => x"01"), (data => x"f0", addr => x"02"));

	--constant prog1: PROG_DATA := (
	--	(data => x"20", addr => x"00"), 
	--	(data => x"0a", addr => x"01"), 
	--	(data => x"21", addr => x"02"), 
	--	(data => x"1e", addr => x"03"), 
	--	(data => x"d0", addr => x"04"),
	--	(data => x"1e", addr => x"05"),
	--	(data => x"f0", addr => x"06"),
	--	(data => x"15", addr => x"1e"),
	--	(data => x"ff", addr => x"1f"),
	--	(data => x"34", addr => x"20"),
	--	(data => x"ff", addr => x"21"),
	--	(data => x"e0", addr => x"22")
	--);

	--constant prog2: PROG_DATA := (
	--	(data => x"20", addr => x"00"), 
	--	(data => x"0a", addr => x"01"), 
	--	(data => x"40", addr => x"02"), 
	--	(data => x"01", addr => x"03"), 
	--	(data => x"b0", addr => x"04"),
	--	(data => x"08", addr => x"05"),
	--	(data => x"90", addr => x"06"),
	--	(data => x"02", addr => x"07"),
	--	(data => x"f0", addr => x"08")
	--);

	--constant prog3: PROG_DATA := (
	--	(data => x"28", addr => x"00"), 
	--	(data => x"0a", addr => x"01"), 
	--	(data => x"2d", addr => x"02"), 
	--	(data => x"0a", addr => x"03"), 
	--	(data => x"15", addr => x"04"),
	--	(data => x"ff", addr => x"05"),
	--	(data => x"24", addr => x"06"),
	--	(data => x"ff", addr => x"07"),
	--	(data => x"f0", addr => x"08"),
	--	(data => x"ff", addr => x"0a"),
	--	(data => x"02", addr => x"0b"),
	--	(data => x"01", addr => x"ff")
	--);

	--constant prog4: PROG_DATA := (
	--	(data => x"20", addr => x"00"), 
	--	(data => x"0a", addr => x"01"), 
	--	(data => x"40", addr => x"02"), 
	--	(data => x"01", addr => x"03"), 
	--	(data => x"c0", addr => x"04"),
	--	(data => x"02", addr => x"05"),
	--	(data => x"f0", addr => x"06")
	--);

	--constant prog5: PROG_DATA := (
	--	(data => x"60", addr => x"00"), 
	--	(data => x"ff", addr => x"01"), 
	--	(data => x"50", addr => x"02"), 
	--	(data => x"aa", addr => x"03"), 
	--	(data => x"80", addr => x"04"),
	--	(data => x"01", addr => x"05"),
	--	(data => x"70", addr => x"06"),
	--	(data => x"ff", addr => x"07"),
	--	(data => x"f0", addr => x"08")
	--);

	--constant prog6: PROG_DATA := (
	--	(data => x"20", addr => x"00"), 
	--	(data => x"e1", addr => x"01"), -- raiz de 225
	--	(data => x"d0", addr => x"02"), 
	--	(data => x"05", addr => x"03"), 
	--	(data => x"f0", addr => x"04"), -- 21 1 22 2 23 4 14 fe 24 fe 31 1 32 2 16 ff 33 1 37 ff 17 ff 14 fe 44 ff c0 d 15 ff 24 ff e0
	--	(data => x"21", addr => x"05"),
	--	(data => x"01", addr => x"06"),
	--	(data => x"22", addr => x"07"),
	--	(data => x"02", addr => x"08"),
	--	(data => x"23", addr => x"09"),
	--	(data => x"04", addr => x"0a"),
	--	(data => x"14", addr => x"0b"),
	--	(data => x"fe", addr => x"0c"), -- 24 fe 31 1 32 2 16 ff 33 1 37 ff 17 ff 14 fe 44 ff c0 d 15 ff 24 ff e0
	--	(data => x"24", addr => x"0d"),
	--	(data => x"fe", addr => x"0e"),
	--	(data => x"31", addr => x"0f"),
	--	(data => x"01", addr => x"10"),
	--	(data => x"32", addr => x"11"),
	--	(data => x"02", addr => x"12"),
	--	(data => x"16", addr => x"13"),
	--	(data => x"ff", addr => x"14"), -- 33 1 37 ff 17 ff 14 fe 44 ff c0 d 15 ff 24 ff e0
	--	(data => x"33", addr => x"15"),
	--	(data => x"01", addr => x"16"),
	--	(data => x"37", addr => x"17"),
	--	(data => x"ff", addr => x"18"),
	--	(data => x"17", addr => x"19"),
	--	(data => x"ff", addr => x"1a"),
	--	(data => x"14", addr => x"1b"),
	--	(data => x"fe", addr => x"1c"), -- 44 ff c0 d 15 ff 24 ff e0
	--	(data => x"44", addr => x"1d"),
	--	(data => x"ff", addr => x"1e"),
	--	(data => x"c0", addr => x"1f"),
	--	(data => x"0d", addr => x"20"),
	--	(data => x"15", addr => x"21"),
	--	(data => x"ff", addr => x"22"),
	--	(data => x"24", addr => x"23"),
	--	(data => x"ff", addr => x"24"),
	--	(data => x"e0", addr => x"25")
	--);

	-- 20 4 d0 5 f0 21 1 22 2 23 4 14 fe 24 fe 31 1 32 2 16 ff 33 1 37 ff 17 ff 14 fe 44 ff c0 d 15 ff 24 ff e0
	
	type character_file is file of character;
    file bin_file : character_file;

begin
	
	uut: entity work.control_unit port map(
		clk => tb_clk, 
		enable => tb_enable, 
		rst => tb_rst,
		nop => tb_nop, 
		str => tb_str, 
		ldr => tb_ldr, 
		b => tb_b, 
		jsr => tb_jsr, 
		ret => tb_ret, 
		hlt => tb_hlt,
		mode => tb_mode,
		pc_en => tb_pc_en,
		bre => tb_bre,
		mar_en => tb_mar_en,
		ir_en => tb_ir_en,
		lr_en => tb_lr_en,
		rf_en => tb_rf_en,
		mem_en => tb_me,

		sel_ra => tb_sel_ra,
		sel_ba => tb_sel_ba,
		sel_ma => tb_sel_ma,
		sel_mar_d0 => tb_sel_mar_d0, 
		sel_mar_d1 => tb_sel_mar_d1,
		op_en => tb_op_en
	);

	op: entity work.op_unit port map(
		clk => tb_clk,
		en => tb_op_en,
		mem => tb_mem,
		pc_en => tb_pc_en,
		bre => tb_bre,
		mar_en => tb_mar_en,
		ir_en => tb_ir_en,
		lr_en => tb_lr_en,
		rf_en => tb_rf_en,
		sel_ra => tb_sel_ra,
		sel_ba => tb_sel_ba,
		sel_ma => tb_sel_ma,
		sel_mar_d0 => tb_sel_mar_d0,
		sel_mar_d1 => tb_sel_mar_d1,
		rf_out => tb_rf_out,
		maddr => tb_maddr,
		nop => tb_nop,
		str => tb_str,
		ldr => tb_ldr,
		b => tb_b,
		jsr => tb_jsr,
		ret => tb_ret,
		hlt => tb_hlt,
		mode => tb_mode
	);

	mem: entity work.mem8x8 port map(
		clk => tb_clk,
		we => tb_mem_en,
		din => tb_mem_din,
		addr => tb_mem_addr,
		dout => tb_mem
	);

	--tb_ext_mem_din
	process(tb_rf_out, tb_ext_mem_din, tb_sel_ext_din)
	begin
		if tb_sel_ext_din = '0' then
			tb_mem_din <= tb_rf_out;
		else
			tb_mem_din <= tb_ext_mem_din;
		end if;
	end process;

	--tb_ext_mem_addr
	process(tb_maddr, tb_ext_mem_addr, tb_sel_ext_addr)
	begin
		if tb_sel_ext_addr = '0' then
			tb_mem_addr <= tb_maddr;
		else
			tb_mem_addr <= tb_ext_mem_addr;
		end if;
	end process;

	--tb_ext_mem_en
	process(tb_me, tb_ext_mem_en, tb_sel_ext_me)
	begin
		if tb_sel_ext_me = '0' then
			tb_mem_en <= tb_me;
		else
			tb_mem_en <= tb_ext_mem_en;
		end if;
	end process;

	process
	--variable tmp_vec: std_logic_vector(7 downto 0);
	--variable line_buffer : line;
    variable byte_buffer : character;
	variable i : natural := 0;
	begin

		--- CARREGA O PROGRAMA

		tb_sel_ext_me <= '1';
		tb_sel_ext_addr <= '1';
		tb_sel_ext_din <= '1';
		tb_ext_mem_en <= '1';
		--for i in prog6'range loop
		
		file_open(bin_file, "bin_file.mem", READ_MODE);
		while not endfile(bin_file) and i < 256 loop
			--tb_ext_mem_din <= prog6(i).data;
			--tmp_vec := std_logic_vector(to_unsigned(i, 8));
			--tb_ext_mem_addr <= prog6(i).addr;

			--readline(bin_file, line_buffer);
			read(bin_file, byte_buffer);
			tb_ext_mem_din <= std_logic_vector(to_unsigned(character'pos(byte_buffer),8));
			tb_ext_mem_addr <= std_logic_vector(to_signed(i, 8));
			i := i + 1;

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';

		end loop;
		file_close(bin_file);

		tb_ext_mem_en <= '0';
		tb_sel_ext_din <= '0';
		tb_sel_ext_me <= '0';
		tb_sel_ext_addr <= '0';

		--- RODA O PROGRAMA

		tb_enable <= '1';
		wait for 5 ns;
		while tb_op_en = '1' loop
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