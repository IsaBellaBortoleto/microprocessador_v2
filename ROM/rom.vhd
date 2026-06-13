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
        -- PROGRAMA — Lab 8 Validação **(Crivo de Eratóstenes)**
        -- Elimina não-primos até 32 na RAM
        -- RAM[n] = n → primo | RAM[n] = 0 → não primo
        -- =====================================================

        -- BLOCO 1: Preenche RAM[2..32] com RAM[n] = n
        0 => "0001010000000010", -- LD  R4, 2     contador
        1 => "0001010100100001", -- LD  R5, 33    limite
        -- loop (endereço 2)
        2 => "0010000001000000", -- MOV_A R4      A = contador
        3 => "1100000001000000", -- SW (R4)       RAM[R4] = A
        4 => "0010000001000000", -- MOV_A R4      A = R4
        5 => "0101000000000001", -- ADDI 1        A = A + 1
        6 => "0011010000000000", -- MOV_R R4      R4 = A
        7 => "0010000001010000", -- MOV_A R5      A = 33
        8 => "0111000001000000", -- CMPR R4       33 - R4
        9 => "1001000000000010", -- BHI 2         se 33 > R4: volta
        -----------------------------------------------------------------
        -- BLOCO 2: Elimina múltiplos de 2 (RAM[4,6,8...32] = 0)
        10 => "0001000100000100", -- LD  R1, 4     contador
        11 => "0001011000000000", -- LD  R6, 0     zero
        12 => "0001010100100001", -- LD  R5, 33    limite
        -- loop (endereço 13)
        13 => "0010000001100000", -- MOV_A R6      A = 0
        14 => "1100000000010000", -- SW (R1)       RAM[R1] = 0
        15 => "0010000000010000", -- MOV_A R1      A = contador
        16 => "0101000000000010", -- ADDI 2        A = A + 2
        17 => "0011000100000000", -- MOV_R R1      R1 = A
        18 => "0010000001010000", -- MOV_A R5      A = 33
        19 => "0111000000010000", -- CMPR R1       33 - R1
        20 => "1001000000001101", -- BHI 13        se 33 > R1: volta
        -----------------------------------------------------------------
        -- BLOCO 3: Elimina múltiplos de 3 (RAM[6,9,12...30] = 0)
        21 => "0001000100000110", -- LD  R1, 6     contador
        -- (R5=33 e R6=0 já carregados)
        -- loop (endereço 22)
        22 => "0010000001100000", -- MOV_A R6      A = 0
        23 => "1100000000010000", -- SW (R1)       RAM[R1] = 0
        24 => "0010000000010000", -- MOV_A R1      A = contador
        25 => "0101000000000011", -- ADDI 3        A = A + 3
        26 => "0011000100000000", -- MOV_R R1      R1 = A
        27 => "0010000001010000", -- MOV_A R5      A = 33
        28 => "0111000000010000", -- CMPR R1       33 - R1
        29 => "1001000000010110", -- BHI 22        se 33 > R1: volta
        -----------------------------------------------------------------
        -- BLOCO 4: Elimina múltiplos de 5 (RAM[10,15,20,25,30] = 0)
        30 => "0001000100001010", -- LD  R1, 10    contador
        -- loop (endereço 31)
        31 => "0010000001100000", -- MOV_A R6      A = 0
        32 => "1100000000010000", -- SW (R1)       RAM[R1] = 0
        33 => "0010000000010000", -- MOV_A R1      A = contador
        34 => "0101000000000101", -- ADDI 5        A = A + 5
        35 => "0011000100000000", -- MOV_R R1      R1 = A
        36 => "0010000001010000", -- MOV_A R5      A = 33
        37 => "0111000000010000", -- CMPR R1       33 - R1
        38 => "1001000000011111", -- BHI 31        se 33 > R1: volta
        -----------------------------------------------------------------
        -- BLOCO 5: Elimina múltiplos de 7 (RAM[14,21,28] = 0)
        39 => "0001000100001110", -- LD  R1, 14    contador
        -- loop (endereço 40)
        40 => "0010000001100000", -- MOV_A R6      A = 0
        41 => "1100000000010000", -- SW (R1)       RAM[R1] = 0
        42 => "0010000000010000", -- MOV_A R1      A = contador
        43 => "0101000000000111", -- ADDI 7        A = A + 7
        44 => "0011000100000000", -- MOV_R R1      R1 = A
        45 => "0010000001010000", -- MOV_A R5      A = 33
        46 => "0111000000010000", -- CMPR R1       33 - R1
        47 => "1001000000101000", -- BHI 40        se 33 > R1: volta
        -----------------------------------------------------------------
        
        -- TODO: endereço 48 - PESSOA 2
        -- (verificação de 899 + bus_debug + bit_debug)

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