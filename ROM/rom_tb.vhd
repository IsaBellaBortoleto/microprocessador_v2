LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rom_tb IS
END;

ARCHITECTURE a_rom_tb OF rom_tb IS
    -- O componente deve ser o decoder originals
    COMPONENT rom
        PORT (
            clk : IN STD_LOGIC;
            endereco : IN unsigned(6 DOWNTO 0);
            dado : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;
    -- Sinais para ligação 

    SIGNAL endereco : unsigned(6 DOWNTO 0);
    SIGNAL dado : unsigned(15 DOWNTO 0);
    SIGNAL clk : STD_LOGIC;

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : rom PORT MAP(
        clk => clk,
        dado => dado,
        endereco => endereco
    );

    sim_time_proc : PROCESS
    BEGIN
        WAIT FOR 10 us; 
        finished <= '1';
        WAIT;
    END PROCESS sim_time_proc;
    clk_proc : PROCESS
    BEGIN -- gera clock até que sim_time_proc termine
        WHILE finished /= '1' LOOP
            clk <= '0';
            WAIT FOR period_time/2;
            clk <= '1';
            WAIT FOR period_time/2;
        END LOOP;
        WAIT;
    END PROCESS clk_proc;

    PROCESS
    BEGIN
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 1: Leitura do endereço 0
        -- Instrução: LD R1, 30  →  0001 0001 0001 1110
        -- Esperado: dado = x"111E"
        ------------------------------------------------------------------
        endereco <= "0000000";
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 2: Leitura do endereço 1
        -- Instrução: LD R3, 0  →  0001 0011 0000 0000
        -- Esperado: dado = x"1300"
        ------------------------------------------------------------------
        endereco <= "0000001";
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 3: Leitura do endereço 5
        -- Instrução: MOV_R R4  →  0011 0100 0000 0000
        -- Esperado: dado = x"3400"
        ------------------------------------------------------------------
        endereco <= "0000101";
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 4: Leitura do endereço 6
        -- Instrução: MOV_A R3  →  0010 0000 0011 0000
        -- Esperado: dado = x"2030"
        ------------------------------------------------------------------
        endereco <= "0000110";
        WAIT FOR period_time;

        ------------------------------------------------------------------
        -- TESTE 5: Leitura de endereço vazio (endereço 50)
        -- Esperado: dado = x"0000" (others => '0')
        ------------------------------------------------------------------
        endereco <= "0110010";
        WAIT FOR period_time;

        WAIT;
    END PROCESS;
END ARCHITECTURE;