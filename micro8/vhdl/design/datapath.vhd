library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use std.textio.all;

entity datapath is
	port(
		clk, enable, rst, sel_ext_din, sel_ext_addr, sel_ext_me, ext_mem_en: in std_logic;
		ext_mem_din, ext_mem_addr: in std_logic_vector(7 downto 0);
		running: out std_logic	
	);
end entity;

architecture behavioral of datapath is

	signal intern_nop: std_logic := '0';
	signal intern_str: std_logic := '0';
	signal intern_ldr: std_logic := '0';
	signal intern_b: std_logic := '0';
	signal intern_jsr: std_logic := '0';
	signal intern_ret: std_logic := '0';
	signal intern_hlt: std_logic := '0';
	signal intern_mode: std_logic_vector(1 downto 0) := (others => '0'); -- imd, dir, ind, rdx 
	
	signal intern_pc_en: std_logic := '0';
	signal intern_bre: std_logic := '0';
	signal intern_mar_en: std_logic := '0';
	signal intern_ir_en: std_logic := '0';
	signal intern_lr_en: std_logic := '0';
	signal intern_rf_en: std_logic := '0';
	signal intern_mem_en: std_logic := '0';

	signal intern_sel_ra: std_logic := '0';
	signal intern_sel_ba: std_logic := '0';
	signal intern_sel_ma: std_logic := '0';
	signal intern_sel_mar_d0: std_logic := '0';
	signal intern_sel_mar_d1: std_logic := '0';
	signal intern_op_en: std_logic := '0';

	signal intern_rf_out: std_logic_vector(7 downto 0) := (others => '0'); -- register_file out
	signal intern_maddr: std_logic_vector(7 downto 0) := (others => '0'); -- memory address (pc ou mar)

	signal intern_mem: std_logic_vector(7 downto 0) := (others => '0'); -- memory data
	signal intern_me: std_logic := '0';
	signal intern_mem_din: std_logic_vector(7 downto 0) := (others => '0');
	signal intern_mem_addr: std_logic_vector(7 downto 0) := (others => '0');

begin
	
	c_unit: entity work.control_unit port map(
		clk => clk, 
		enable => enable, 
		rst => rst,
		nop => intern_nop, 
		str => intern_str, 
		ldr => intern_ldr, 
		b => intern_b, 
		jsr => intern_jsr, 
		ret => intern_ret, 
		hlt => intern_hlt,
		mode => intern_mode,
		pc_en => intern_pc_en,
		bre => intern_bre,
		mar_en => intern_mar_en,
		ir_en => intern_ir_en,
		lr_en => intern_lr_en,
		rf_en => intern_rf_en,
		mem_en => intern_me,

		sel_ra => intern_sel_ra,
		sel_ba => intern_sel_ba,
		sel_ma => intern_sel_ma,
		sel_mar_d0 => intern_sel_mar_d0, 
		sel_mar_d1 => intern_sel_mar_d1,
		op_en => intern_op_en
	);

	op: entity work.op_unit port map(
		clk => clk,
		en => intern_op_en,
		mem => intern_mem,
		pc_en => intern_pc_en,
		bre => intern_bre,
		mar_en => intern_mar_en,
		ir_en => intern_ir_en,
		lr_en => intern_lr_en,
		rf_en => intern_rf_en,
		sel_ra => intern_sel_ra,
		sel_ba => intern_sel_ba,
		sel_ma => intern_sel_ma,
		sel_mar_d0 => intern_sel_mar_d0,
		sel_mar_d1 => intern_sel_mar_d1,
		rf_out => intern_rf_out,
		maddr => intern_maddr,
		nop => intern_nop,
		str => intern_str,
		ldr => intern_ldr,
		b => intern_b,
		jsr => intern_jsr,
		ret => intern_ret,
		hlt => intern_hlt,
		mode => intern_mode
	);

	mem: entity work.mem8x8 port map(
		clk => clk,
		we => intern_mem_en,
		din => intern_mem_din,
		addr => intern_mem_addr,
		dout => intern_mem
	);

	-- ext_mem_din
	process(intern_rf_out, ext_mem_din, sel_ext_din)
	begin
		if sel_ext_din = '0' then
			intern_mem_din <= intern_rf_out;
		else
			intern_mem_din <= ext_mem_din;
		end if;
	end process;

	-- ext_mem_addr
	process(intern_maddr, ext_mem_addr, sel_ext_addr)
	begin
		if sel_ext_addr = '0' then
			intern_mem_addr <= intern_maddr;
		else
			intern_mem_addr <= ext_mem_addr;
		end if;
	end process;

	-- ext_mem_en
	process(intern_me, ext_mem_en, sel_ext_me)
	begin
		if sel_ext_me = '0' then
			intern_mem_en <= intern_me;
		else
			intern_mem_en <= ext_mem_en;
		end if;
	end process;

	running <= intern_op_en;

end architecture;