LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram_tb IS
END ENTITY;

ARCHITECTURE a_ram_tb OF ram_tb IS

    COMPONENT ram
        PORT (
            clk      : IN STD_LOGIC;
            endereco : IN unsigned(6 DOWNTO 0);
            wr_en    : IN STD_LOGIC;
            dado_in  : IN unsigned(15 DOWNTO 0);
            dado_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk      : STD_LOGIC := '0';
    SIGNAL endereco : unsigned(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_en    : STD_LOGIC := '0';
    SIGNAL dado_in  : unsigned(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dado_out : unsigned(15 DOWNTO 0);

    CONSTANT T : TIME := 50 ns;

BEGIN

    clk <= NOT clk AFTER T;

    uut : ram PORT MAP(
        clk      => clk,
        endereco => endereco,
        wr_en    => wr_en,
        dado_in  => dado_in,
        dado_out => dado_out
    );

    PROCESS
    BEGIN
        -- -----------------------------------------------
        -- TESTE 1: Escrita no endereço 0x05, dado 0xABCD
        -- dado_out deve mostrar x"ABCD" (leitura assíncrona)
        -- Esperado: dado_out = x"ABCD" (bin: 1010101111001101)
        -- -----------------------------------------------
        endereco <= "0000101";   -- 5
        dado_in  <= x"ABCD";
        wr_en    <= '1';
        WAIT UNTIL rising_edge(clk);  -- grava na borda
        wr_en    <= '0';
        WAIT FOR T;
       
        -- -----------------------------------------------
        -- TESTE 2: Escrita no endereço 0x0A, dado 0x1234
        -- Esperado: dado_out = x"1234" (bin: 0001001000110100)
        -- -----------------------------------------------
        endereco <= "0001010";   -- 10
        dado_in  <= x"1234";
        wr_en    <= '1';
        WAIT UNTIL rising_edge(clk);
        wr_en    <= '0';
        WAIT FOR T;

        -- -----------------------------------------------
        -- TESTE 3: Escrita no endereço 0x1F, dado 0x0002
        -- Esperado: dado_out = x"0002" (bin: 0000000000000010)
        -- -----------------------------------------------
        endereco <= "0011111";   -- 31
        dado_in  <= x"0002";
        wr_en    <= '1';
        WAIT UNTIL rising_edge(clk);
        wr_en    <= '0';
        WAIT FOR T;

        -- -----------------------------------------------
        -- TESTE 4: Leitura do endereço 0x05 (sem escrever)
        -- Verifica que o valor antigo persiste
        -- Esperado: dado_out = x"ABCD" (bin: 1010101111001101)
        -- -----------------------------------------------
        endereco <= "0000101";   -- volta pro 5
        wr_en    <= '0';
        WAIT FOR T;

        -- -----------------------------------------------
        -- TESTE 5: Leitura do endereço 0x0A
        -- Esperado: dado_out = x"1234" (bin: 0001001000110100)
        -- -----------------------------------------------
        endereco <= "0001010";   -- 10
        WAIT FOR T;

        -- -----------------------------------------------
        -- TESTE 6: Endereço nunca escrito (lixo inicial = 0)
        -- Esperado: dado_out = x"0000" (bin: 0000000000000000)
        -- -----------------------------------------------
        endereco <= "1000000";   -- 64
        WAIT FOR T;
 
        -- -----------------------------------------------
        -- TESTE 7: Sobrescreve endereço 0x05 com novo valor
        -- Esperado: dado_out = x"BEEF" (bin: 1011111011101111)
        -- -----------------------------------------------
        endereco <= "0000101";   -- 5
        dado_in  <= x"BEEF";
        wr_en    <= '1';
        WAIT UNTIL rising_edge(clk);
        wr_en    <= '0';
        WAIT FOR T;

        -- -----------------------------------------------
        -- TESTE 8: Leitura do 0x0A ainda deve ser x"1234"
        -- (sobrescrita do 5 não afeta o 10)
        -- Esperado: dado_out = x"1234" (bin: 0001001000110100)
        -- -----------------------------------------------
        endereco <= "0001010";
        WAIT FOR T;

        WAIT;
    END PROCESS;

END ARCHITECTURE;