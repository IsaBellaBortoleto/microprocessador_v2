LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY incr_pc_tb IS
END;

ARCHITECTURE a_incr_pc_tb OF incr_pc_tb IS
    COMPONENT incr_pc
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;

            pc_out : OUT unsigned(6 DOWNTO 0)
        );
    END COMPONENT;
    -- Sinais para ligação 

    SIGNAL clk, rst : STD_LOGIC;
    SIGNAL pc_out : unsigned(6 DOWNTO 0);

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : incr_pc PORT MAP(
        clk => clk,
        rst => rst,
        pc_out => pc_out
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

    -- No gtkwave, verificar:
    -- Após reset: pc_out = x"00" (bin: 0000000)
    -- Clock 1:   pc_out = x"01" (bin: 0000001)
    -- Clock 2:   pc_out = x"02" (bin: 0000010)
    -- Clock 3:   pc_out = x"03" (bin: 0000011)
    -- Clock 4:   pc_out = x"04" (bin: 0000100)
    -- ... e assim por diante
END ARCHITECTURE;