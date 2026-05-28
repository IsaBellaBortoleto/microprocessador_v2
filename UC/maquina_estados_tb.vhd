LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY maquina_estados_tb IS
END;

ARCHITECTURE a_maquina_estados_tb OF maquina_estados_tb IS
    COMPONENT maquina_estados
        PORT (
            clk_i : IN STD_LOGIC;
            rst_i : IN STD_LOGIC;
            estado_o : OUT STD_LOGIC
        );
    END COMPONENT;
    -- Sinais para ligação 

    SIGNAL clk_i, rst_i : STD_LOGIC;
    SIGNAL estado_o : STD_LOGIC;

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : maquina_estados PORT MAP(
        clk_i => clk_i,
        rst_i => rst_i,
        estado_o => estado_o
    );
    reset_global : PROCESS
    BEGIN
        rst_i <= '1';
        WAIT FOR period_time * 2;
        rst_i <= '0';
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
            clk_i <= '0';
            WAIT FOR period_time/2;
            clk_i <= '1';
            WAIT FOR period_time/2;
        END LOOP;
        WAIT;
    END PROCESS clk_proc;

 -- No gtkwave, verificar:
    -- Após reset: estado_o = '0' (Fetch)
    -- Clock 1:   estado_o = '1' (Execute)
    -- Clock 2:   estado_o = '0' (Fetch)
    -- Clock 3:   estado_o = '1' (Execute)
    -- Clock 4:   estado_o = '0' (Fetch)
    -- ... alterna a cada clock
END ARCHITECTURE;