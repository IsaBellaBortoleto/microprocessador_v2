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

        -- =====================================================
        -- PROGRAMA DE TESTE — Lab 7 (RAM: LW e SW)
        -- Opcodes novos: LW=1011, SW=1100
        -- Formato SW: 1100 0000 ssss 0000 (A → RAM[Rs])
        -- Formato LW: 1011 dddd ssss 0000 (RAM[Rs] → Rd)
        -- =====================================================

        -- FASE 1: carrega dados variados em registradores diferentes
        0 => "0001000110101011", -- LD R1, 0xAB  (171) — dado 1
        1 => "0001001000110111", -- LD R2, 0x37  (55)  — dado 2
        2 => "0001001111000100", -- LD R3, 0xC4  (196) — dado 3
        3 => "0001010001011110", -- LD R4, 0x5E  (94)  — dado 4

        -- FASE 2: carrega ponteiros de endereço espaçados
        4 => "0001010100000101", -- LD R5, 5    — ponteiro endereço 5
        5 => "0001011000001111", -- LD R6, 15   — ponteiro endereço 15
        6 => "0001011100011110", -- LD R7, 30   — ponteiro endereço 30
        7 => "0001100000111100", -- LD R8, 60   — ponteiro endereço 60

        -- FASE 3: escritas SW — acumulador → RAM[ponteiro]
        -- Nenhuma leitura entre as escritas (regra do professor)
        8 => "0010000000010000", -- MOV_A R1    — A = 0xAB
        9 => "1100000001010000", -- SW (R5)     — RAM[5]  = 0xAB
        10 => "0010000000100000", -- MOV_A R2    — A = 0x37
        11 => "1100000001100000", -- SW (R6)     — RAM[15] = 0x37
        12 => "0010000000110000", -- MOV_A R3    — A = 0xC4
        13 => "1100000001110000", -- SW (R7)     — RAM[30] = 0xC4
        14 => "0010000001000000", -- MOV_A R4    — A = 0x5E
        15 => "1100000010000000", -- SW (R8)     — RAM[60] = 0x5E

        -- FASE 4: NOPs para limpar barramentos antes das leituras
        16 => "0000000000000000", -- NOP
        17 => "0000000000000000", -- NOP
        18 => "0000000000000000", -- NOP

        -- FASE 5: leituras LW — RAM[ponteiro] → registrador destino
        -- Registradores destino diferentes dos ponteiros e dos dados originais
        19 => "1011100101010000", -- LW R9,  (R5) — R9  = RAM[5]  → esperado: 0xAB
        20 => "1011101001100000", -- LW R10, (R6) — R10 = RAM[15] → esperado: 0x37
        21 => "1011101101110000", -- LW R11, (R7) — R11 = RAM[30] → esperado: 0xC4
        22 => "1011110010000000", -- LW R12, (R8) — R12 = RAM[60] → esperado: 0x5E

        -- FIM: loop infinito em 23
        -- JMP -1: PC=24 + (-1) = 23, delta=-1 → 11111111 em complemento de 2
        23 => "1000000011111111", -- JMP -1

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