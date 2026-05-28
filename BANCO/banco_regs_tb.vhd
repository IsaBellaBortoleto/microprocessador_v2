LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY banco_regs_tb IS
-- Testbenches não possuem portas
END ENTITY;

ARCHITECTURE a_banco_regs_tb OF banco_regs_tb IS

    COMPONENT banco_regs
        PORT (
            clk       : IN STD_LOGIC;
            rst       : IN STD_LOGIC;
            wr_en     : IN STD_LOGIC;
            write_sel : IN unsigned(3 DOWNTO 0);
            read_sel  : IN unsigned(3 DOWNTO 0);
            data_in   : IN unsigned(15 DOWNTO 0);
            data_out  : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Sinais internos
    SIGNAL clk_tb       : STD_LOGIC := '0';
    SIGNAL rst_tb       : STD_LOGIC := '0';
    SIGNAL wr_en_tb     : STD_LOGIC := '0';
    SIGNAL write_sel_tb : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_sel_tb  : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_in_tb   : unsigned(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_out_tb  : unsigned(15 DOWNTO 0);

    -- Controle de tempo e fim de simulação, pq tava rodando infinitamente
    CONSTANT period     : TIME := 20 ns;
    SIGNAL sim_done     : BOOLEAN := FALSE; -- Substitui o limite numérico do clock

BEGIN

    -- Instanciação
    uut: banco_regs PORT MAP (
        clk       => clk_tb,
        rst       => rst_tb,
        wr_en     => wr_en_tb,
        write_sel => write_sel_tb,
        read_sel  => read_sel_tb,
        data_in   => data_in_tb,
        data_out  => data_out_tb
    );

    -- Processo de Clock (Usando flag booleana em vez de FOR)
    clk_process : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk_tb <= '0';
            WAIT FOR period/2;
            clk_tb <= '1';
            WAIT FOR period/2;
        END LOOP;
        WAIT; 
    END PROCESS;

    -- Processo de Estímulos (Passo a passo, sem FOR)
    stim_proc: PROCESS
    BEGIN
        -- Reset inicial
        rst_tb <= '1';
        WAIT FOR period * 2;
        rst_tb <= '0';
        WAIT FOR period;

        ------------------------------------------------
        -- BLOCO DE ESCRITA (Registradores de 0 a 9)
        ------------------------------------------------
        wr_en_tb <= '1';
        
        write_sel_tb <= "0000"; data_in_tb <= X"1000"; WAIT FOR period; -- Reg 0
        write_sel_tb <= "0001"; data_in_tb <= X"1001"; WAIT FOR period; -- Reg 1
        write_sel_tb <= "0010"; data_in_tb <= X"1002"; WAIT FOR period; -- Reg 2
        write_sel_tb <= "0011"; data_in_tb <= X"1003"; WAIT FOR period; -- Reg 3
        write_sel_tb <= "0100"; data_in_tb <= X"1004"; WAIT FOR period; -- Reg 4
        write_sel_tb <= "0101"; data_in_tb <= X"1005"; WAIT FOR period; -- Reg 5
        write_sel_tb <= "0110"; data_in_tb <= X"1006"; WAIT FOR period; -- Reg 6
        write_sel_tb <= "0111"; data_in_tb <= X"1007"; WAIT FOR period; -- Reg 7
        write_sel_tb <= "1000"; data_in_tb <= X"1008"; WAIT FOR period; -- Reg 8
        write_sel_tb <= "1001"; data_in_tb <= X"1009"; WAIT FOR period; -- Reg 9

        ------------------------------------------------
        -- BLOCO DE LEITURA (Registradores de 0 a 9)
        ------------------------------------------------
        wr_en_tb <= '0'; -- Desliga a escrita
        
        read_sel_tb <= "0000"; WAIT FOR period; -- Ler Reg 0
        read_sel_tb <= "0001"; WAIT FOR period; -- Ler Reg 1
        read_sel_tb <= "0010"; WAIT FOR period; -- Ler Reg 2
        read_sel_tb <= "0011"; WAIT FOR period; -- Ler Reg 3
        read_sel_tb <= "0100"; WAIT FOR period; -- Ler Reg 4
        read_sel_tb <= "0101"; WAIT FOR period; -- Ler Reg 5
        read_sel_tb <= "0110"; WAIT FOR period; -- Ler Reg 6
        read_sel_tb <= "0111"; WAIT FOR period; -- Ler Reg 7
        read_sel_tb <= "1000"; WAIT FOR period; -- Ler Reg 8
        read_sel_tb <= "1001"; WAIT FOR period; -- Ler Reg 9

        ------------------------------------------------
        -- TESTE DE RESET COM DADOS GRAVADOS
        ------------------------------------------------
        rst_tb <= '1';
        WAIT FOR period;
        rst_tb <= '0';
        
        -- Verificar se o Reg 9 zerou corretamente após o reset
        read_sel_tb <= "1001";
        WAIT FOR period;

        -- Desliga o clock e finaliza a simulação
        sim_done <= TRUE;
        WAIT;
    END PROCESS;

END ARCHITECTURE;