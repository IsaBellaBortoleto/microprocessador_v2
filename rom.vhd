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
        -- Opcodes: 0000=NOP, 0001=LD, 0010=MOV_A, 0011=MOV_R, 0100=ADD, 0110=SUB, 1000=JMP (Relativo)

        -- [A] Carrega R3 com 5
        0 => "0001001100000101", -- LD R3, 5

        -- [B] Carrega R4 com 8
        1 => "0001010000001000", -- LD R4, 8

        -- [C] Soma R3 com R4 e guarda em R5
        2 => "0010000000110000", -- MOV_A R3 (Puxa R3 pro Acumulador)
        3 => "0100000001000000", -- ADD R4 (Acumulador = Acumulador + R4)
        4 => "0011010100000000", -- MOV_R R5 (Salva resultado em R5)

        -- [D] Subtrai 1 de R5 (usando registrador auxiliar R1 por causa da restrição)
        5 => "0001000100000001", -- LD R1, 1 
        6 => "0010000001010000", -- MOV_A R5
        7 => "0110000000010000", -- SUB R1 (Acumulador = Acumulador - R1)
        8 => "0011010100000000", -- MOV_R R5

        -- [E] Salta para o endereço 20
        -- (JMP é relativo. Estamos no endereço 9, para ir pro 20: 20 - 9 = 11. 11 em binário é 00001011)
        9 => "1000000000010100", -- JMP +11 

        -- [F] Zera R5 (Nunca será executada)
        10 => "0001010100000000", -- LD R5, 0

        -- NOPs de preenchimento (Garante a regra do Opcode 0x00 ser NOP)
        11 TO 19 => "0000000000000000", 

        -- [G] No endereço 20, copia R5 para R3
        20 => "0010000001010000", -- MOV_A R5
        21 => "0011001100000000", -- MOV_R R3

        -- [H] Salta para o passo C (que está no endereço 2)
        -- (Estamos no endereço 22, para ir pro 2: 2 - 22 = -20. -20 em complemento de 2 é 11101100)
        22 => "1000000000000010", -- JMP -20

        -- [I] Zera R3 (Nunca será executada)
        23 => "0001001100000000", -- LD R3, 0

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