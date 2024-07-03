library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity op_unit is 
	port(
		clk: in std_logic; -- clock
		en: in std_logic; -- op_unit enable

		-- dados entrada
		mem: in std_logic_vector(7 downto 0); -- memory data
		
		-- sinais entrada
		pc_en: in std_logic; -- program counter write enable
		bre: in std_logic; -- program counter branch enable
		mar_en: in std_logic; -- memory address register write enable
		ir_en: in std_logic; -- instruction register write enable
		lr_en: in std_logic; -- link register write enable
		rf_en: in std_logic; -- register file write enable (usado também para o status register)

		sel_ra: in std_logic; -- select register file address
		sel_ba: in std_logic; -- select branch address
		sel_ma: in std_logic; -- select memory address
		sel_mar_d0, sel_mar_d1: in std_logic; -- select mar input
		--sel_rf_din: in std_logic; -- select register file data input

		-- dados saída
		rf_out: out std_logic_vector(7 downto 0); -- register_file out
		maddr: out std_logic_vector(7 downto 0); -- memory address (pc ou mar)

		-- sinais saída
		nop, str, ldr, b, jsr, ret, hlt: out std_logic; -- instruction types
		mode: out std_logic_vector(1 downto 0) -- imd, dir, ind, rdx
	);
end entity;

architecture behavioral of op_unit is

	signal intern_clk: std_logic := '0';

	signal rf_din: std_logic_vector(7 downto 0) := (others => '0');
	signal rf_ra: std_logic_vector(1 downto 0) := (others => '0');
	signal rf_dout: std_logic_vector(7 downto 0) := (others => '0');

	signal pc_din: std_logic_vector(7 downto 0) := (others => '0');
	signal pc_dout: std_logic_vector(7 downto 0) := (others => '0');

	signal ir_dout: std_logic_vector(7 downto 0) := (others => '0');

	signal lr_din: std_logic_vector(7 downto 0) := (others => '0');
	signal lr_dout: std_logic_vector(7 downto 0) := (others => '0');

	signal mar_din: std_logic_vector(7 downto 0) := (others => '0');
	signal mar_dout: std_logic_vector(7 downto 0) := (others => '0');

	signal sr_din: std_logic_vector(2 downto 0) := (others => '0');
	signal sr_dout: std_logic_vector(2 downto 0) := (others => '0');

	signal intern_aluop: std_logic_vector(2 downto 0) := (others => '0');
	signal alu_dout: std_logic_vector(7 downto 0) := (others => '0');

begin

	reg_file: entity work.register_file port map(
		clk => intern_clk,
		we => rf_en,
		din => rf_din,
		ra => rf_ra,
		dout => rf_dout
	);

	pc: entity work.program_counter8 port map(
		clk => intern_clk, 
		we => pc_en, 
		bre => bre,
		din => pc_din,
		dout => pc_dout
	);

	ir: entity work.register8 port map(
		clk => intern_clk,
		we => ir_en,
		din => mem,
		dout => ir_dout
	);

	lr: entity work.register8 port map(
		clk => intern_clk,
		we => lr_en,
		din => lr_din,
		dout => lr_dout
	);

	mar: entity work.register8 port map(
		clk => intern_clk,
		we => mar_en,
		din => mar_din,
		dout => mar_dout
	);

	sr: entity work.generic_register generic map(
		nBits => 3
	)
	port map(
		clk => intern_clk,
		we => rf_en,
		din => sr_din,
		dout => sr_dout
	);

	alu: entity work.alu8 port map(
		a => rf_dout,
		b => mem,
		aluop => intern_aluop,
		dout => alu_dout,
		flags => sr_din
	);

	-- intern_clk
	process(clk, en)
	begin
		intern_clk <= en and clk;
	end process;

	-- intern_aluop
	process(ir_dout)
	variable tmp0: std_logic_vector(2 downto 0);
	variable tmp1: std_logic_vector(2 downto 0);
	variable tmp2: unsigned(2 downto 0);
	begin
		--tmp := std_logic_vector(unsigned(ir_dout)+to_unsigned(5,3));
		tmp0 := ir_dout(6 downto 4);
		tmp1 := "101";
		tmp2 := unsigned(tmp0)+unsigned(tmp1);
		intern_aluop <= std_logic_vector(tmp2(2 downto 0));
	end process;	

	-- lr_din
	process(pc_dout)
	begin
		lr_din <= std_logic_vector(unsigned(pc_dout)+1);
	end process;

	-- pc_din
	process(sel_ba, mem, lr_dout)
	begin
		if sel_ba = '0' then
			pc_din <= mem;
		else
			pc_din <= lr_dout;
		end if;
	end process;

	-- rf_din
	process(mem, alu_dout, ir_dout)
	begin
		if ir_dout(7 downto 4) = "0010" then -- if opcode ldr
			rf_din <= mem;
		else
			rf_din <= alu_dout;
		end if;
	end process;

	-- rf_ra
	process(sel_ra, mem, ir_dout)
	begin
		if sel_ra = '0' then
			rf_ra <= ir_dout(1 downto 0);
		else
			rf_ra <= mem(7 downto 6);
		end if;
	end process;

	-- mar_din
	process(mem, rf_dout, pc_dout, sel_mar_d0, sel_mar_d1)
	begin
		if sel_mar_d0 = '0' then
			mar_din <= pc_dout;
		else
			if sel_mar_d1 = '0' then
				mar_din <= mem;
			else
				mar_din <= std_logic_vector(unsigned("00" & mem(5 downto 0)) + unsigned(rf_dout));
			end if;
		end if;
	end process;

	-- instruction types
	process(ir_dout, mem)
	begin
		
		if mem = x"00" then
			nop <= '1';
		else
			nop <= '0';
		end if;
		
		--refazer com case when
		case ir_dout(7 downto 4) is 
			when "0001" =>
				str <= '1';
				ldr <= '0';
				b <= '0';
				jsr <= '0';
				ret <= '0';
				hlt <= '0';
			when "0010" | "0011" | "0100" | "0101" | "0110" | "0111" | "1000" =>
				ldr <= '1';
				str <= '0';
				b <= '0';
				jsr <= '0';
				ret <= '0';
				hlt <= '0';
			when "1001" | "1010" | "1011" | "1100" => 
				if ir_dout(7 downto 4) = "1001" then
					b <= '1';
				elsif ir_dout(7 downto 4) = "1010" and sr_dout(0) = '1' then
					b <= '1';
				elsif ir_dout(7 downto 4) = "1011" and sr_dout(1) = '1' then
					b <= '1';
				elsif ir_dout(7 downto 4) = "1100" and sr_dout(2) = '1' then
					b <= '1';
				else
					b <= '0';
				end if;

				str <= '0';
				ldr <= '0';
				jsr <= '0';
				ret <= '0';
				hlt <= '0';
			when "1101" => 
				jsr <= '1';
				str <= '0';
				ldr <= '0';
				b <= '0';
				ret <= '0';
				hlt <= '0';
			when "1110" =>
				ret <= '1';
				str <= '0';
				ldr <= '0';
				b <= '0';
				jsr <= '0';
				hlt <= '0';
			when "1111" =>
				hlt <= '1';
				str <= '0';
				ldr <= '0';
				b <= '0';
				jsr <= '0';
				ret <= '0';
			when others =>
				str <= '0';
				ldr <= '0';
				b <= '0';
				jsr <= '0';
				ret <= '0';
				hlt <= '0';
		end case;
	end process;

	mode <= ir_dout(3 downto 2);
	rf_out <= rf_dout;
	maddr <= pc_dout when sel_ma = '0' else mar_dout;

end architecture;