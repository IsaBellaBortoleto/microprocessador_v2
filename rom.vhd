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
        
        -- PASSO EXTRA: Inserir o limite do laço (30) no R1 para comparação
        0 => "0001000100011110", -- LD R1, 30     (Opcode:1, Dest:1, Cte:00011110=30)

        -- PASSO A e B: Carrega R3 e R4 com 0
        1 => "0001001100000000", -- LD R3, 0      (Opcode:1, Dest:3, Cte:0)
        2 => "0001010000000000", -- LD R4, 0      (Opcode:1, Dest:4, Cte:0)

        -- === INÍCIO DO LOOP (Endereço 3) ===
        -- PASSO C: Soma R3 com R4 e guarda em R4 (R4 = R4 + R3)
        3 => "0010000001000000", -- MOV_A R4     (Acumulador = R4)
        4 => "0100000000110000", -- ADD R3       (Acumulador = R4 + R3)
        5 => "0011010000000000", -- MOV_R R4     (R4 = Acumulador)

        -- PASSO D: Soma 1 em R3 (R3 = R3 + 1)
        6 => "0010000000110000", -- MOV_A R3     (Acumulador = R3)
        7 => "0101000000000001", -- ADDI 1       (Acumulador = R3 + 1)
        8 => "0011001100000000", -- MOV_R R3     (R3 = Acumulador)

        -- PASSO E: Se R3 < 30 salta para a instrução do passo C (Endereço 3)
        -- Para comparar R3 < 30, fazemos 30 - R3 (R1 - R3). Se BHI saltar, significa que 30 > R3.
        9 => "0010000000010000", -- MOV_A R1     (Acumulador = 30)
        10 => "0111000000110000", -- CMPR R3     (Compara: 30 - R3)
        11 => "1001000000000011", -- BHI 3       (Se 30 > R3 [C=1, Z=0], pula para o endereço 3)

        -- PASSO F: Copia valor de R4 para R5
        12 => "0010000001000000", -- MOV_A R4    (Acumulador = R4)
        13 => "0011010100000000", -- MOV_R R5    (R5 = Acumulador)

        -- === FIM DO PROGRAMA ===
        14 => "1000000000000000", -- JMP +0        (Loop infinito: PC = 14 + 0 = 14, relativo)

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