LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reg16bits_tb IS
END;

ARCHITECTURE a_reg16bits_tb OF reg16bits_tb IS
    -- O componente deve ser o decoder originals
    COMPONENT reg16bits
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(15 DOWNTO 0);
            data_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;
    -- Sinais para ligação 
    
    SIGNAL data_in, data_out : unsigned(15 DOWNTO 0);
    SIGNAL clk, rst, wr_en : STD_LOGIC;
    
    -- Controle de tempo da simulação
    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    -- uut (Unit Under Test) instancia o componente 
    uut : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => wr_en,
        data_in => data_in,
        data_out => data_out);

    reset_global : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR period_time * 2; -- espera 2 clocks, pra garantir
        rst <= '0';
        WAIT;
    END PROCESS;
    sim_time_proc : PROCESS
    BEGIN
        WAIT FOR 10 us; -- <== TEMPO TOTAL DA SIMULAÇÃO!!!
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
    PROCESS -- sinais dos casos de teste (p.ex.)
    BEGIN
-- Condições iniciais
        wr_en <= '0';
        data_in <= "0000000000000000";
        WAIT FOR 250 ns; -- Espera o reset passar
        
        -- Teste 1: Tenta escrever com wr_en desativado (não deve gravar)
        data_in <= "0000000011111111"; 
        WAIT FOR 150 ns;
        
        -- Teste 2: Habilita escrita (deve gravar na borda do clock)
        wr_en <= '1';
        WAIT FOR 100 ns;
        
        -- Teste 3: Grava outro valor
        data_in <= "1000110110001101";
        WAIT FOR 100 ns;
        
        -- Teste 4: Desabilita escrita e muda o dado (deve manter o valor antigo)
        wr_en <= '0';
        data_in <= "1111111111111111";
        WAIT FOR 100 ns;

        WAIT;

    END PROCESS;
END ARCHITECTURE;