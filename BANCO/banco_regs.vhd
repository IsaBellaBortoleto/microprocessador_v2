LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY banco_regs IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        wr_en : IN STD_LOGIC; -- Habilitação global de escrita no banco

        -- aqui é importante, é 2^4 para poder selecionar os 10 registradores
        write_sel : IN unsigned(3 DOWNTO 0); -- Seletor de qual registrador vai ser ESCRITO
        read_sel : IN unsigned(3 DOWNTO 0); -- Seletor de qual registrador vai ser LIDO

        data_in : IN unsigned(15 DOWNTO 0); -- Dado que vem de fora para ser gravado
        data_out : OUT unsigned(15 DOWNTO 0) -- Dado lido que vai para a ULA
    );
END ENTITY;

ARCHITECTURE a_banco_regs OF banco_regs IS

    -- 1. Declaração do componente 
    COMPONENT reg16bits
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(15 DOWNTO 0);
            data_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    -- 2. Sinais Internos
    -- Precisamos de 10 fios para os Enable individuais e 10 barramentos para as saídas
    SIGNAL we0, we1, we2, we3, we4, we5, we6, we7, we8, we9 : STD_LOGIC;
    SIGNAL q0, q1, q2, q3, q4, q5, q6, q7, q8, q9 : unsigned(15 DOWNTO 0);

BEGIN

    -- 3. Descodificador de Escrita (Demultiplexador)
    -- ele basicamente serve para o seguinte, ao receber o wr_en para ativar escrita,
    -- o banco é bobo e gravaria em todos os regs. Agora, com o decoder, vc precisa 
    -- do wr_en E do write_sel[3:0] (endereço) e esse endereço precisa de tamanho 2^4 para cobrir os 
    -- 10 registradores dentro do banco
    -- O 'wr_en' do registrador 0 só liga se o 'wr_en' global estiver ligado E o seletor apontar para ele.
    we0 <= '1' WHEN (wr_en = '1' AND write_sel = "0000") ELSE
        '0';
    we1 <= '1' WHEN (wr_en = '1' AND write_sel = "0001") ELSE
        '0';
    we2 <= '1' WHEN (wr_en = '1' AND write_sel = "0010") ELSE
        '0';
    we3 <= '1' WHEN (wr_en = '1' AND write_sel = "0011") ELSE
        '0';
    we4 <= '1' WHEN (wr_en = '1' AND write_sel = "0100") ELSE
        '0';
    we5 <= '1' WHEN (wr_en = '1' AND write_sel = "0101") ELSE
        '0';
    we6 <= '1' WHEN (wr_en = '1' AND write_sel = "0110") ELSE
        '0';
    we7 <= '1' WHEN (wr_en = '1' AND write_sel = "0111") ELSE
        '0';
    we8 <= '1' WHEN (wr_en = '1' AND write_sel = "1000") ELSE
        '0';
    we9 <= '1' WHEN (wr_en = '1' AND write_sel = "1001") ELSE
        '0';

    -- 4. Instanciação dos 10 Registradores
    reg0 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we0, data_in => data_in, data_out => q0);
    reg1 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we1, data_in => data_in, data_out => q1);
    reg2 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we2, data_in => data_in, data_out => q2);
    reg3 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we3, data_in => data_in, data_out => q3);
    reg4 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we4, data_in => data_in, data_out => q4);
    reg5 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we5, data_in => data_in, data_out => q5);
    reg6 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we6, data_in => data_in, data_out => q6);
    reg7 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we7, data_in => data_in, data_out => q7);
    reg8 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we8, data_in => data_in, data_out => q8);
    reg9 : reg16bits PORT MAP(clk => clk, rst => rst, wr_en => we9, data_in => data_in, data_out => q9);
    
    -- 5. MUX de Leitura
    -- Liga apenas um dos sinais 'q' à saída oficial do banco, baseado no read_sel
    data_out <=
        q0 WHEN read_sel = "0000" ELSE
        q1 WHEN read_sel = "0001" ELSE
        q2 WHEN read_sel = "0010" ELSE
        q3 WHEN read_sel = "0011" ELSE
        q4 WHEN read_sel = "0100" ELSE
        q5 WHEN read_sel = "0101" ELSE
        q6 WHEN read_sel = "0110" ELSE
        q7 WHEN read_sel = "0111" ELSE
        q8 WHEN read_sel = "1000" ELSE
        q9 WHEN read_sel = "1001" ELSE
        "0000000000000000"; -- Segurança: se pedirem um endereço inválido (ex: 10 a 15), sai zero.

END ARCHITECTURE;