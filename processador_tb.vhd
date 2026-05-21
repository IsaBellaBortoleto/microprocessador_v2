LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processador_tb IS
END ENTITY;

ARCHITECTURE sim OF processador_tb IS

    -- Componente do Top Level
    COMPONENT processador
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            estado_out : OUT unsigned(1 DOWNTO 0);
            pc_out     : OUT unsigned(6 DOWNTO 0);
            ir_out     : OUT unsigned(15 DOWNTO 0);
            ula_out    : OUT unsigned(15 DOWNTO 0);
            acc_out    : OUT unsigned(15 DOWNTO 0);
            banco_out  : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Sinais para conectar no Top Level
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '1';
    SIGNAL estado_out : unsigned(1 DOWNTO 0);
    SIGNAL pc_out     : unsigned(6 DOWNTO 0);
    SIGNAL ir_out     : unsigned(15 DOWNTO 0);
    SIGNAL ula_out    : unsigned(15 DOWNTO 0);
    SIGNAL acc_out    : unsigned(15 DOWNTO 0);
    SIGNAL banco_out  : unsigned(15 DOWNTO 0);

    -- Período do clock
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instanciação do Processador
    uut: processador PORT MAP (
        clk => clk,
        rst => rst,
        estado_out => estado_out,
        pc_out => pc_out,
        ir_out => ir_out,
        ula_out => ula_out,
        acc_out => acc_out,
        banco_out => banco_out
    );

    -- Geração do Clock
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Estímulos iniciais (Reset)
    stim_proc: PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR 20 ns;
        
        rst <= '0'; -- Libera o processador para rodar
        
        -- Deixa simular por bastante tempo para vermos o loop do R5 várias vezes
        WAIT FOR 3000 ns;
        
        -- Encerra a simulação automaticamente
        WAIT;
    END PROCESS;

END ARCHITECTURE;