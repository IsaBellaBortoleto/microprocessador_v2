--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: ROM de 128 palavras de 16 bits, 'Leitura da ROM': ['síncrona']
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rom IS
    PORT (
        clk : IN STD_LOGIC;
        endereco : IN unsigned(6 DOWNTO 0);
        dado : OUT unsigned(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_rom OF rom IS
    TYPE mem IS ARRAY (0 TO 127) OF unsigned(15 DOWNTO 0);
    CONSTANT conteudo_rom : mem := (
        -- FORMATO BITS: [15:12] Opcode | [11:8] Destino | [7:4] Fonte | [7:0] Constante/Endereço
        -- Novos opcodes configurados: BHI = "1001"

        0 => "0001010100000000", -- LD R5, 0      (Inicializa acumulador da soma R5 = 0)
        1 => "0001000100011101", -- LD R1, 29     (Inicializa contador do laço R1 = 29)
        2 => "0001001000000001", -- LD R2, 1      (Constante de decremento R2 = 1)
        3 => "0001001100000000", -- LD R3, 0      (Constante para comparação R3 = 0)

        -- === INÍCIO DO LOOP (Endereço 4) ===
        4 => "0010000001010000", -- MOV_A R5     (Acumulador = R5)
        5 => "0100000000010000", -- ADD R1       (Acumulador = Acumulador + R1)
        6 => "0011010100000000", -- MOV_R R5     (R5 = Acumulador)

        7 => "0010000000010000", -- MOV_A R1     (Acumulador = R1)
        8 => "0110000000100000", -- SUB R2       (Acumulador = Acumulador - R2)
        9 => "0011000100000000", -- MOV_R R1     (R1 = Acumulador)

        10 => "0111000000110000", -- CMPR R3     (Compara R1 com R3, alterando as flags da ULA)
        11 => "1001000000000100", -- BHI 4        (Se R1 > 0 [C=1 e Z=0], salta para o endereço absoluto 4)
        
        -- === FIM DO PROGRAMA (Endereço 12) ===
        12 => "1000000000001100", -- JMP 12       (Trava a execução em um loop infinito no endereço 12)

        OTHERS => (OTHERS => '0')
    );
BEGIN
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            dado <= conteudo_rom(to_integer(endereco));
        END IF;
    END PROCESS;
END ARCHITECTURE;