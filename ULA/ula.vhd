--------------------------------------------------------------------------------
-- Projeto: [Microprocessador]
-- Descrição: Modelo de um Microprocessador (ULA)
-- Autores: 
-- Isabela Bella Bortoleto
-- Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ula IS
    PORT (
        -- Duas entradas de dados de 16 bits
        in_a : IN unsigned(15 DOWNTO 0);
        in_b : IN unsigned(15 DOWNTO 0);

        -- Entradas para seleção da operação 
        in_seletor : IN unsigned(1 DOWNTO 0);

        -- Uma saída de resultado de 16 bits
        out_result : OUT unsigned(15 DOWNTO 0);

        -- flags do sorteio (BHI e BVS)

        -- BHI (Branch if Higher, unsigned): só salta caso C=1 e Z=0,
        -- ou seja, não houve borrow e o resultado não é zero (a > b)

        flag_z : OUT STD_LOGIC; -- Flag Zero
        flag_c : OUT STD_LOGIC; -- Flag Carry
        flag_v : OUT STD_LOGIC -- Flag Overflow

    );
END ENTITY;

ARCHITECTURE a_ula OF ula IS
    -- Sinais internos para calcular TODAS as operações simultaneamente
    SIGNAL res_soma : unsigned(16 DOWNTO 0);
    SIGNAL res_subt : unsigned(16 DOWNTO 0);
    SIGNAL res_and : unsigned(15 DOWNTO 0);
    SIGNAL res_shiftleft : unsigned(15 DOWNTO 0);

    SIGNAL not_b : unsigned(15 DOWNTO 0);

    -- Sinal para guardar qual foi a operação escolhida pelo seletor
    SIGNAL resultado_final : unsigned(15 DOWNTO 0);

BEGIN
    not_b <= NOT in_b;
    -- 1. Operacoes de soma, subtracao, AND e shift left
    res_soma <= ('0' & in_a) + ('0' & in_b);
    res_subt <= ('0' & in_a) + ('0' & not_b) + 1;
    res_and <= in_a AND in_b;
    res_shiftleft <= in_a(14 DOWNTO 0) & '0';
    -- 4 operacao

    -- 2. O MUX escolhe qual resultado vai para a saída final
    resultado_final <=
        res_soma(15 DOWNTO 0) WHEN in_seletor = "00" ELSE
        res_subt(15 DOWNTO 0) WHEN in_seletor = "01" ELSE
        res_and WHEN in_seletor = "10" ELSE
        res_shiftleft WHEN in_seletor = "11" ELSE
        "0000000000000000"; -- Valor padrão se der pau

    -- 3. Joga o resultado escolhido no pino de saída
    out_result <= resultado_final;

    -- 4. Cálculo das Flags combinacionais (Sem IF!)
    --Flag zero (BHI)
    flag_z <= '1' WHEN resultado_final = "0000000000000000" ELSE
        '0';

    --Flag carry
    flag_c <= res_soma(16) WHEN in_seletor = "00" ELSE
        res_subt(16) WHEN in_seletor = "01" ELSE
        in_a(15) WHEN in_seletor = "11" ELSE
        '0'; -- Para outras operações, o Carry não é relevante
        
    --Flag de overflow (BVS) -> Falta de espaço (-32.768 até +32.767)
    -- vai ocorrer quando somar dois valores que passe de 32.767 ou -32.768
    -- Soma de dois positivos que deu negativo

    flag_v <=
        -- Soma
        ((NOT in_a(15) AND NOT in_b(15) AND resultado_final(15)) OR
        (in_a(15) AND in_b(15) AND NOT resultado_final(15))) WHEN in_seletor = "00" ELSE
        -- Subtração
        ((NOT in_a(15) AND in_b(15) AND resultado_final(15)) OR
        (in_a(15) AND NOT in_b(15) AND NOT resultado_final(15))) WHEN in_seletor = "01" ELSE
        '0';
END ARCHITECTURE;