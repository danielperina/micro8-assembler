library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_op_unit is 
	--port(
	--	clk: in std_logic; -- clock
	--	en: in std_logic; -- op_unit enable

	--	-- dados entrada
	--	mem: in std_logic_vector(7 downto 0); -- memory data
		
	--	-- sinais entrada
	--	pc_en: in std_logic; -- program counter write enable
	--	bre: in std_logic; -- program counter branch enable
	--	mar_en: in std_logic; -- memory address register write enable
	--	ir_en: in std_logic; -- instruction register write enable
	--	lr_en: in std_logic; -- link register write enable
	--	rf_en: in std_logic; -- register file write enable (usado também para o status register)

	--	sel_ra: in std_logic; -- select register file address
	--	sel_ba: in std_logic; -- select branch address
	--	sel_ma: in std_logic; -- select memory address
	--	sel_mar_d0, sel_mar_d1: in std_logic; -- select mar input
	--	sel_rf_din: in std_logic; -- select register file data input

	--	-- dados saída
	--	rf_out: out std_logic_vector(7 downto 0); -- register_file out
	--	maddr: out std_logic_vector(7 downto 0); -- memory address (pc ou mar)

	--	-- sinais saída
	--	nop, str, ldr, b, jsr, ret, hlt: out std_logic; -- instruction types
	--	mode: out std_logic_vector(1 downto 0) -- imd, dir, ind, rdx
	--);
end entity;

architecture behavioral of tb_op_unit is

	signal tb_clk: std_logic := '0'; -- clock
	signal tb_en: std_logic := '0'; -- op_unit enable

	-- dados entrada
	signal tb_mem: std_logic_vector(7 downto 0) := (others => '0'); -- memory data
	
	-- sinais entrada
	signal tb_pc_en: std_logic := '0'; -- program counter write enable
	signal tb_bre: std_logic := '0'; -- program counter branch enable
	signal tb_mar_en: std_logic := '0'; -- memory address register write enable
	signal tb_ir_en: std_logic := '0'; -- instruction register write enable
	signal tb_lr_en: std_logic := '0'; -- link register write enable
	signal tb_rf_en: std_logic := '0'; -- register file write enable (usado também para o status register)

	signal tb_sel_ra: std_logic := '0'; -- select register file address
	signal tb_sel_ba: std_logic := '0'; -- select branch address
	signal tb_sel_ma: std_logic := '0'; -- select memory address
	
	signal tb_sel_mar_d0: std_logic := '0'; 
	signal tb_sel_mar_d1: std_logic := '0'; -- select mar input
	
	--signal tb_sel_rf_din: std_logic := '0'; -- select register file data input

	-- dados saída
	signal tb_rf_out: std_logic_vector(7 downto 0) := (others => '0'); -- register_file out
	signal tb_maddr: std_logic_vector(7 downto 0) := (others => '0'); -- memory address (pc ou mar)

	-- sinais saída
	signal tb_nop: std_logic := '0';
	signal tb_str: std_logic := '0';
	signal tb_ldr: std_logic := '0';
	signal tb_b: std_logic := '0';
	signal tb_jsr: std_logic := '0';
	signal tb_ret: std_logic := '0';
	signal tb_hlt: std_logic := '0'; -- instruction types
	
	signal tb_mode: std_logic_vector(1 downto 0) := (others => '0'); -- imd, dir, ind, rdx

	signal tb_me: std_logic := '0';
	signal tb_mem_en: std_logic := '0';
	signal tb_mem_din: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_mem_addr: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_ext_mem_addr: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_ext_mem_en: std_logic := '0';
	signal tb_sel_ext_addr: std_logic := '0';
	signal tb_sel_ext_me: std_logic := '0';
	signal tb_ext_mem_din: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_sel_ext_din: std_logic := '0';

	type test_format is record
		en: std_logic;
		-- dados entrada
		mem:  std_logic_vector(7 downto 0);
		-- sinais entrada
		pc_en, bre, mar_en, ir_en, lr_en, rf_en, sel_ra, sel_ba, sel_ma, sel_mar_d0, sel_mar_d1: std_logic;
		-- dados saída
		rf_out, maddr: std_logic_vector(7 downto 0);
		-- sinais saída
		nop, str, ldr, b, jsr, ret, hlt: std_logic;
		mode: std_logic_vector(1 downto 0);
	end record;

	type test_array is array(natural range<>) of test_format;

	constant tests: test_array := (
		(en => '0', mem => x"20", pc_en => '0', bre => '0', mar_en => '0', ir_en => '0', lr_en => '0', rf_en => '0', sel_ra => '0', sel_ba => '0', sel_ma => '0', sel_mar_d0 => '0', sel_mar_d1 => '0', rf_out => x"00", maddr => x"00", nop => '0', str => '0', ldr => '0', b => '0', jsr => '0', ret => '0', hlt => '0', mode => "00"),
		(en => '1', mem => x"20", pc_en => '1', bre => '0', mar_en => '0', ir_en => '1', lr_en => '0', rf_en => '0', sel_ra => '0', sel_ba => '0', sel_ma => '0', sel_mar_d0 => '0', sel_mar_d1 => '0', rf_out => x"00", maddr => x"01", nop => '0', str => '0', ldr => '1', b => '0', jsr => '0', ret => '0', hlt => '0', mode => "00"),
		(en => '1', mem => x"0a", pc_en => '0', bre => '0', mar_en => '1', ir_en => '0', lr_en => '0', rf_en => '0', sel_ra => '0', sel_ba => '0', sel_ma => '0', sel_mar_d0 => '0', sel_mar_d1 => '0', rf_out => x"00", maddr => x"01", nop => '0', str => '0', ldr => '1', b => '0', jsr => '0', ret => '0', hlt => '0', mode => "00"),
		(en => '1', mem => x"0a", pc_en => '1', bre => '0', mar_en => '0', ir_en => '0', lr_en => '0', rf_en => '1', sel_ra => '0', sel_ba => '0', sel_ma => '1', sel_mar_d0 => '0', sel_mar_d1 => '0', rf_out => x"0a", maddr => x"01", nop => '0', str => '0', ldr => '1', b => '0', jsr => '0', ret => '0', hlt => '0', mode => "00"),
		(en => '1', mem => x"f0", pc_en => '1', bre => '0', mar_en => '0', ir_en => '1', lr_en => '0', rf_en => '0', sel_ra => '0', sel_ba => '0', sel_ma => '0', sel_mar_d0 => '0', sel_mar_d1 => '0', rf_out => x"0a", maddr => x"03", nop => '1', str => '0', ldr => '0', b => '0', jsr => '0', ret => '0', hlt => '1', mode => "00")
	);

	type PROG_DATA is array(natural range<>) of std_logic_vector(7 downto 0);
	constant prog: PROG_DATA := (x"20", x"0a", x"f0");

begin

	uut: entity work.op_unit port map(
		clk => tb_clk,
		en => tb_en,
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
	variable tmp_vec: std_logic_vector(7 downto 0);
	begin

		tb_sel_ext_me <= '1';
		tb_sel_ext_addr <= '1';
		tb_sel_ext_din <= '1';
		tb_ext_mem_en <= '1';
		for i in prog'range loop
			tb_ext_mem_din <= prog(i);
			tmp_vec := std_logic_vector(to_unsigned(i, 8));
			tb_ext_mem_addr <= tmp_vec;

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';

		end loop;
		tb_ext_mem_en <= '0';
		tb_sel_ext_din <= '0';
		tb_sel_ext_me <= '0';
		tb_sel_ext_addr <= '0';

		for i in tests'range loop

			tb_en <= tests(i).en;
			--tb_mem <= tests(i).mem;
			
			tb_pc_en <= tests(i).pc_en;
			tb_bre <= tests(i).bre;
			tb_mar_en <= tests(i).mar_en;
			tb_ir_en <= tests(i).ir_en;
			tb_lr_en <= tests(i).lr_en;
			tb_rf_en <= tests(i).rf_en;

			tb_sel_ra <= tests(i).sel_ra;
			tb_sel_ba <= tests(i).sel_ba;
			tb_sel_ma <= tests(i).sel_ma;

			tb_sel_mar_d0 <= tests(i).sel_mar_d0;
			tb_sel_mar_d1 <= tests(i).sel_mar_d1;

			--tb_sel_rf_din <= tests(i).sel_rf_din;

			wait for 5 ns;
			tb_clk <= '1';
			wait for 5 ns;
			tb_clk <= '0';

			assert tb_rf_out = tests(i).rf_out report "Unexpected value for rf_out at test no." & integer'image(i) severity error;
			assert tb_maddr = tests(i).maddr report "Unexpected value for maddr at test no." & integer'image(i) severity error;
			assert tb_nop = tests(i).nop report "Unexpected value for nop at test no." & integer'image(i) severity error;
			assert tb_str = tests(i).str report "Unexpected value for str at test no." & integer'image(i) severity error;
			assert tb_ldr = tests(i).ldr report "Unexpected value for ldr at test no." & integer'image(i) severity error;
			assert tb_b = tests(i).b report "Unexpected value for b at test no." & integer'image(i) severity error;
			assert tb_jsr = tests(i).jsr report "Unexpected value for jsr at test no." & integer'image(i) severity error;
			assert tb_ret = tests(i).ret report "Unexpected value for ret at test no." & integer'image(i) severity error;
			assert tb_hlt = tests(i).hlt report "Unexpected value for hlt at test no." & integer'image(i) severity error;
			assert tb_mode = tests(i).mode report "Unexpected value for mode at test no." & integer'image(i) severity error;
			
		end loop;

		report "Tests finished." severity note;
		wait;
	end process;	

end architecture;