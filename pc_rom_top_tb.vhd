LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_rom_top_tb IS
END;

ARCHITECTURE a_pc_rom_top_tb OF pc_rom_top_tb IS
    COMPONENT pc_rom_top
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            pc_out : OUT unsigned(6 DOWNTO 0);
            rom_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;
    -- Sinais para ligação 

    SIGNAL clk, rst : STD_LOGIC;
    SIGNAL pc_out : unsigned(6 DOWNTO 0);
    SIGNAL rom_out : unsigned(15 DOWNTO 0);

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : pc_rom_top PORT MAP(
        clk => clk,
        rst => rst,
        pc_out => pc_out,
        rom_out => rom_out
    );
    reset_global : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR period_time * 2;
        rst <= '0';
        WAIT;
    END PROCESS;

    sim_time_proc : PROCESS
    BEGIN
        WAIT FOR 10 us;
        finished <= '1';
        WAIT;
    END PROCESS sim_time_proc;
    clk_proc : PROCESS
    BEGIN
        WHILE finished /= '1' LOOP
            clk <= '0';
            WAIT FOR period_time/2;
            clk <= '1';
            WAIT FOR period_time/2;
        END LOOP;
        WAIT;
    END PROCESS clk_proc;

    -- No gtkwave, verificar (ROM do Lab 6):
    -- Após reset: pc_out = x"00", rom_out = x"111E" (LD R1, 30)
    -- Clock 1:   pc_out = x"01", rom_out = x"1300" (LD R3, 0)
    -- Clock 2:   pc_out = x"02", rom_out = x"1400" (LD R4, 0)
    -- Clock 3:   pc_out = x"03", rom_out = x"2040" (MOV_A R4)
    -- Clock 4:   pc_out = x"04", rom_out = x"4030" (ADD R3)
    -- Clock 5:   pc_out = x"05", rom_out = x"3400" (MOV_R R4)
    -- A partir do endereço 15: rom_out = x"0000" (endereços vazios)
END ARCHITECTURE;