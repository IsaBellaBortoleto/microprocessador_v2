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

        -- =====================================================
        -- BLOCO 1: Preenche RAM[2..32] com RAM[n] = n
        -- CORRIGIDO: Agora os binários usam R2 (0010) em vez de R4 (0100)
        -- =====================================================
        0 => "0001001000000010", -- LD  R2, 2      contador
        1 => "0001010100100001", -- LD  R5, 33     limite
        -- loop (endereço 2)
        2 => "0010000000100000", -- MOV_A R2       A = contador
        3 => "1100000000100000", -- SW (R2)        RAM[R2] = A
        4 => "0010000000100000", -- MOV_A R2       A = R2
        5 => "0101000000000001", -- ADDI 1         A = A + 1
        6 => "0011001000000000", -- MOV_R R2       R2 = A
        7 => "0010000001010000", -- MOV_A R5       A = 33
        8 => "0111000000100000", -- CMPR R2        33 - R2
        9 => "1001000000000010", -- BHI 2          se 33 > R2: volta

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


        -- =====================================================
        -- BLOCO 6: Verificação de 899
        -- Testa divisibilidade de 899 por cada primo da tabela
        -- usando subtração repetida (não há instrução de divisão)
        -- bus_debug = 29 (0x001D) | bit_debug = 0
        --
        -- IMPORTANTE: banco tem apenas 10 registradores (R0-R9),
        -- por isso este bloco reaproveita R1, R4, R5, R6, que já
        -- terminaram sua função nos Blocos 1-5 quando este começa.
        --
        -- Mapeamento de registradores deste bloco:
        --   R0 → zero fixo (para os testes CMPR R0)
        --   R1 → ponteiro de leitura da tabela de primos
        --   R2 → primo candidato lido da RAM
        --   R3 → bus_debug (resultado: divisor encontrado)
        --   R4 → bit_debug (resultado: fixo em 0)
        --   R5 → constante 899 (construída em 4 etapas)
        --   R6 → constante 33 (limite do loop)
        -- =====================================================
 
        -- inicialização
        48 => "0001000000000000", -- LD  R0, 0     zero fixo (p/ CMPR R0)
        49 => "0001000100000010", -- LD  R1, 2     ponteiro tabela primos
        50 => "0001010000000000", -- LD  R4, 0     bit_debug = 0
        51 => "0001011000100001", -- LD  R6, 33    limite
 
        -- construção da constante 899 = 225+225+225+224
        52 => "0001010111100001", -- LD  R5, 225
        53 => "0010000001010000", -- MOV_A R5      A = 225
        54 => "0101000011100001", -- ADDI 225      A = 450
        55 => "0101000011100001", -- ADDI 225      A = 675
        56 => "0101000011100000", -- ADDI 224      A = 899
        57 => "0011010100000000", -- MOV_R R5      R5 = 899
 
        -- loop_primos (endereço 58): percorre RAM[2..32]
        58 => "1011001000010000", -- LW R2, (R1)   R2 = RAM[R1]
        59 => "0010000000100000", -- MOV_A R2      A = R2
        60 => "0111000000000000", -- CMPR R0       testa R2 == 0
        61 => "1001000000111111", -- BHI 63        se R2>0: testa_divisor
        62 => "1000000000001001", -- JMP +9 (62 + 9 = 71)        se R2==0: proximo_primo
 
        -- testa_divisor (endereço 63)
        63 => "0010000001010000", -- MOV_A R5      A = 899
 
        -- loop_sub (endereço 64)
        64 => "0110000000100000", -- SUB R2        A = A - R2
        65 => "1001000001000000", -- BHI 64        se A>0: continua subtraindo
 
        -- saiu do loop_sub: A é 0 (achou) ou negativo-grande (não é divisor)
        66 => "0111000000000000", -- CMPR R0       recalcula flags: A - 0
        67 => "1001000001000111", -- BHI 71        se A>0: NÃO é divisor
 
        -- achou o divisor!
        68 => "0010000000100000", -- MOV_A R2      A = R2 (divisor)
        69 => "0011001100000000", -- MOV_R R3      R3 = R2 (bus_debug)
        70 => "1000000000000111", -- JMP +7 (70 + 7 = 77)        pula pro fim
 
        -- proximo_primo (endereço 71)
        71 => "0010000000010000", -- MOV_A R1      A = R1
        72 => "0101000000000001", -- ADDI 1        A = R1 + 1
        73 => "0011000100000000", -- MOV_R R1      R1 = A
        74 => "0010000001100000", -- MOV_A R6      A = 33
        75 => "0111000000010000", -- CMPR R1       flags = 33 - R1
        76 => "1001000000111010", -- BHI 58        se 33 > R1: loop_primos
 
        -- fim (endereço 77): loop infinito, trava aqui
        77 => "1000000000000000", -- JMP +0 (77 + 0 = 77)
 
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