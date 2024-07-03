library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit is
    port(
        clk, enable, rst: in std_logic;
        nop, str, ldr, b, jsr, ret, hlt: in std_logic; -- instruction types
        mode: in std_logic_vector(1 downto 0); -- imd, dir, ind, rdx 
        
        pc_en: out std_logic; -- program counter write enable
        bre: out std_logic; -- program counter branch enable
        mar_en: out std_logic; -- memory address register write enable
        ir_en: out std_logic; -- instruction register write enable
        lr_en: out std_logic; -- link register write enable
        rf_en: out std_logic; -- register file write enable (usado também para o status register)
        mem_en: out std_logic; -- write memory enable

        sel_ra: out std_logic; -- select register file address
        sel_ba: out std_logic; -- select branch address
        sel_ma: out std_logic; -- select memory address
        sel_mar_d0, sel_mar_d1: out std_logic; -- select mar input
        op_en: out std_logic -- select register file data input
    );
end entity;

architecture behavioral of control_unit is

    type STATE_TYPE is (fetch_instruction, fetch_address, execute);
    
    signal state : STATE_TYPE := fetch_instruction;
    signal counter: std_logic := '0';
    signal intern_enable: std_logic := '1';

begin

    process(clk, enable)
    begin
        if rising_edge(clk) then
            if enable = '1' and intern_enable = '1' then
                if state = fetch_address and mode = "10" then
                    counter <= not counter;
                else
                    counter <= '0';
                end if;
            end if;
        end if;
    end process;
    
    process(rst, clk)
    begin
        if rst = '1' then
            intern_enable <= '0';
        elsif hlt = '1' and state = fetch_address and rising_edge(clk) then
            intern_enable <= '0';
        else
            intern_enable <= '1';
        end if;
    end process;

    process(clk, enable)--, rst)
    begin
        if rst = '1' then
             state <= fetch_instruction;
        --     intern_enable <= '0'
        elsif rising_edge(clk) then
            if enable = '1' and intern_enable = '1' then
                if hlt = '1' and state = fetch_address then
                    state <= fetch_instruction;
                    -- intern_enable <= '0';
                else
                    case state is
                        when fetch_instruction =>
                            if nop = '1' then
                                state <= fetch_instruction;
                            else 
                                state <= fetch_address;
                            end if;
                        when fetch_address => 
                            if ret = '1' then
                                state <= execute;
                            elsif mode = "10" and counter = '0' then
                                state <= fetch_address;
                            else 
                                state <= execute;
                            end if;
                        when execute =>
                            state <= fetch_instruction;
                        when others =>
                            state <= fetch_instruction;
                    end case;
                end if;
            end if;
        end if;
    end process;

    process(state, counter, enable, mode, str, ldr, b, jsr, ret)
    begin
        if enable = '1' and intern_enable = '1' then
            case state is
                when fetch_instruction =>
                    pc_en <= '1';
                    bre <= '0';
                    mar_en <= '0';
                    ir_en <= '1';
                    lr_en <= '0';
                    rf_en <= '0';
                    mem_en <= '0';

                    sel_ra <= '0';
                    sel_ba <= '0';
                    sel_ma <= '0';
                    sel_mar_d0 <= '0';
                    sel_mar_d1 <= '0';

                when fetch_address => 
                    pc_en <= '0';
                    bre <= '0';
                    mar_en <= '1';
                    ir_en <= '0';
                    lr_en <= '0';
                    rf_en <= '0';
                    mem_en <= '0';

                    sel_ra <= (mode(0) and mode(1));
                    sel_ba <= '0';
                    sel_ma <= counter;
                    sel_mar_d0 <= (mode(0) or mode(1));
                    sel_mar_d1 <= (mode(0) and mode(1));

                when execute =>
                    pc_en <= '1';
                    bre <= (b or jsr or ret);
                    mar_en <= '0';
                    ir_en <= '0';
                    lr_en <= jsr;
                    rf_en <= ldr;
                    mem_en <= str;

                    sel_ra <= '0';
                    sel_ba <= ret;
                    sel_ma <= '1';
                    sel_mar_d0 <= '0';
                    sel_mar_d1 <= '0';

                when others => 
                    pc_en <= '0';
                    bre <= '0';
                    mar_en <= '0';
                    ir_en <= '0';
                    lr_en <= '0';
                    rf_en <= '0';
                    mem_en <= '0';

                    sel_ra <= '0';
                    sel_ba <= '0';
                    sel_ma <= '0';
                    sel_mar_d0 <= '0';
                    sel_mar_d1 <= '0';
            end case;
        else  
            pc_en <= '0';
            bre <= '0';
            mar_en <= '0';
            ir_en <= '0';
            lr_en <= '0';
            rf_en <= '0';
            mem_en <= '0';

            sel_ra <= '0';
            sel_ba <= '0';
            sel_ma <= '0';
            sel_mar_d0 <= '0';
            sel_mar_d1 <= '0';
        end if;
    end process;

    op_en <= '1' when (enable = '1' and intern_enable = '1') else '0';

end architecture;
