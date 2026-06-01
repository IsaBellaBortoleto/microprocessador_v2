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
            pc_out : OUT unsigned(6 DOWNTO 0);
            ir_out : OUT unsigned(15 DOWNTO 0);
            ula_out : OUT unsigned(15 DOWNTO 0);
            acc_out : OUT unsigned(15 DOWNTO 0);
            banco_out : OUT unsigned(15 DOWNTO 0);

            -- Pinos das flags adicionados para o Lab 6
            flag_c_out : OUT STD_LOGIC;
            flag_z_out : OUT STD_LOGIC;
            flag_v_out : OUT STD_LOGIC;

            -- Lab 7: pinos observáveis da RAM
            ram_dado_out_obs : OUT unsigned(15 DOWNTO 0);
            ram_endereco_obs : OUT unsigned(6 DOWNTO 0)
        );
    END COMPONENT;

    -- Sinais para conectar no Top Level
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '1';
    SIGNAL estado_out : unsigned(1 DOWNTO 0);
    SIGNAL pc_out : unsigned(6 DOWNTO 0);
    SIGNAL ir_out : unsigned(15 DOWNTO 0);
    SIGNAL ula_out : unsigned(15 DOWNTO 0);
    SIGNAL acc_out : unsigned(15 DOWNTO 0);
    SIGNAL banco_out : unsigned(15 DOWNTO 0);

    -- Sinais das flags
    SIGNAL flag_c_out : STD_LOGIC;
    SIGNAL flag_z_out : STD_LOGIC;
    SIGNAL flag_v_out : STD_LOGIC;

    -- Lab 7: sinais novos para observar a RAM no GTKWave
    SIGNAL ram_dado_out_obs : unsigned(15 DOWNTO 0);
    SIGNAL ram_endereco_obs : unsigned(6 DOWNTO 0);

    -- Período do clock
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instanciação do Processador
    uut : processador PORT MAP(
        clk => clk,
        rst => rst,
        estado_out => estado_out,
        pc_out => pc_out,
        ir_out => ir_out,
        ula_out => ula_out,
        acc_out => acc_out,
        banco_out => banco_out,

        -- Mapeamento das flags
        flag_c_out => flag_c_out,
        flag_z_out => flag_z_out,
        flag_v_out => flag_v_out,
        -- Lab 7: mapeamento dos novos pinos
        ram_dado_out_obs => ram_dado_out_obs,
        ram_endereco_obs => ram_endereco_obs
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
    stim_proc : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR 20 ns;

        rst <= '0'; -- Libera o processador para rodar

        -- Aumentado para dar tempo de rodar todas as repetições do loop
        WAIT FOR 25000 ns;

        -- Encerra a simulação automaticamente
        WAIT;
    END PROCESS;

END ARCHITECTURE;