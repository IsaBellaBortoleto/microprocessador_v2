--------------------------------------------------------------------------------
-- Arquivo de Teste (testbench): ula_tb.vhd
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- A entidade do testbench é sempre vazia
ENTITY ula_tb IS
END ENTITY;

ARCHITECTURE a_ula_tb OF ula_tb IS

    -- 1. Declaração do Componente exato que vamos testar
    COMPONENT ula
        PORT (
            in_a : IN unsigned(15 DOWNTO 0);
            in_b : IN unsigned(15 DOWNTO 0);
            in_seletor : IN unsigned(1 DOWNTO 0);

            out_result : OUT unsigned(15 DOWNTO 0);
            flag_z : OUT STD_LOGIC;
            flag_c : OUT STD_LOGIC;
            flag_v : OUT STD_LOGIC
        );
    END COMPONENT;

    -- 2. Criação dos sinais para ligar nos pinos do componente
    -- Inicializamos com zeros para não dar aquele aviso de "Metavalue" (sinal 'U') no instante zero
    SIGNAL in_a : unsigned(15 DOWNTO 0) := "0000000000000000";
    SIGNAL in_b : unsigned(15 DOWNTO 0) := "0000000000000000";
    SIGNAL in_seletor : unsigned(1 DOWNTO 0) := "00";

    SIGNAL out_result : unsigned(15 DOWNTO 0);
    SIGNAL flag_z : STD_LOGIC;
    SIGNAL flag_c : STD_LOGIC;
    SIGNAL flag_v : STD_LOGIC;

BEGIN

    -- 3. Instanciação da Unidade Sob Teste (UUT)
    uut : ula PORT MAP(
        in_a => in_a,
        in_b => in_b,
        in_seletor => in_seletor,
        out_result => out_result,
        flag_z => flag_z,
        flag_c => flag_c,
        flag_v => flag_v
    );

    -- 4. Simulação
    PROCESS
    BEGIN
        ------------------------------------------------------------------
        -- TESTE 1: Soma Normal ("000")
        -- 5 + 3 = 8
        -- Esperado: out_result = 8, Z=0, C=0, V=0
        ------------------------------------------------------------------
        in_seletor <= "00";
        in_a <= x"0005"; -- 5 em Hexadecimal
        in_b <= x"0003"; -- 3 em Hexadecimal
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 2: Testando o BHI (Subtração onde A > B)
        -- 5 - 3 = 2
        -- Esperado: out_result = 2, Z=0, C=1 (Sem empréstimo, logo BHI pularia)
        ------------------------------------------------------------------
        in_seletor <= "01"; -- Operação de Subtração
        in_a <= x"0005";
        in_b <= x"0003";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 3: Testando a Flag Carry/Borrow (Subtração onde A < B)
        -- 3 - 5 = -2 
        -- Esperado: out_result = x"FFFE", Z=0, C=0, V=0 (Houve empréstimo, BHI NÃO pularia)
        ------------------------------------------------------------------
        in_seletor <= "01";
        in_a <= x"0003";
        in_b <= x"0005";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 4: Testando a Flag Zero (Z)
        -- 10 - 10 = 0
        -- Esperado: out_result = x"0000", Z=1, C=1, V=0
        ------------------------------------------------------------------
        in_seletor <= "01";
        in_a <= x"000A"; -- 10
        in_b <= x"000A"; -- 10
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 5: Testando AND ("010")
        -- x"FF00" AND x"0FF0" = x"0F00"
        -- Esperado: out_result = x"0F00", Z=0, C=0, V=0
        ------------------------------------------------------------------
        in_seletor <= "10"; -- AND
        in_a <= x"FF00";
        in_b <= x"0FF0";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 6: Soma com carry (unsigned overflow)
        -- x"FFFF" + x"0001" = x"10000", nao cabe em 16 bits
        -- Esperado: out_result = x"0000", Z=1, C=1, V=0
        ------------------------------------------------------------------
        in_seletor <= "00"; -- Soma
        in_a <= x"FFFF";
        in_b <= x"0001";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 7: Soma com numeros negativos (signed: -3 + -5 = -8)
        -- unsigned: 65533 + 65531, estoura => C=1
        -- signed: -3 + -5 = -8, sem estouro => V=0
        -- Esperado: out_result = x"FFF8" (-8), Z=0, C=1, V=0
        ------------------------------------------------------------------
        in_seletor <= "00"; -- Soma
        in_a <= x"FFFD";
        in_b <= x"FFFB";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 8: Testando a Flag Overflow (BVS)
        -- Somando dois números positivos grandes que estouram o limite (x7FFF)
        -- x7FFF é o maior número positivo de 16 bits (0111_1111_1111_1111).
        -- Esperado: out_result = x"8000", Z=0, C=0, V=1
        ------------------------------------------------------------------
        in_seletor <= "00"; -- Soma
        in_a <= x"7FFF";
        in_b <= x"0001";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 9: Testando o Shift Left ("11") com a Flag Carry
        -- Deslocando 1 bit à esquerda.
        -- in_a = x"8005" (1000 0000 0000 0101)
        -- Esperado: out_result = x"000A", Z=0, C=1 (o bit 15 caiu no carry), V=0
        ------------------------------------------------------------------
        in_seletor <= "11"; -- Shift Left
        in_a <= x"8005";
        in_b <= x"0000"; -- B não importa para o shift, mas deixamos zerado por boa prática
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 10: Overflow na Subtração (Pos - Neg = Estouro)
        -- x7FFF (32767) - xFFFF (-1) = 32768 (Não cabe no limite de +32767)
        -- Esperado: out_result = x"8000" (-32768), Z=0, C=0, V=1
        ------------------------------------------------------------------
        in_seletor <= "01"; -- Subtração
        in_a <= x"7FFF";
        in_b <= x"FFFF";
        WAIT FOR 50 ns;

        ------------------------------------------------------------------
        -- TESTE 11: Overflow Negativo na Soma (Neg + Neg = Pos)
        -- x8000 (-32768) + xFFFF (-1) = -32769 (Não cabe!)
        -- Esperado: out_result = x"7FFF" (+32767), Z=0, C=1, V=1
        ------------------------------------------------------------------
        in_seletor <= "00"; -- Soma
        in_a <= x"8000";
        in_b <= x"FFFF";
        WAIT FOR 50 ns;

        -- Fim da simulação
        WAIT;
    END PROCESS;

END ARCHITECTURE;