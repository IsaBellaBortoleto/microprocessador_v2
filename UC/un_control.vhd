LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY un_control IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ir_in : IN unsigned(15 DOWNTO 0);

        -- Entradas de Status (Flags vindas dos Flip-Flops, não direto da ULA)
        flag_z : IN STD_LOGIC;
        flag_c : IN STD_LOGIC;
        flag_v : IN STD_LOGIC;

        wr_en_pc : OUT STD_LOGIC;
        wr_en_ir : OUT STD_LOGIC;
        wr_en_banco : OUT STD_LOGIC;
        wr_en_acc : OUT STD_LOGIC;
        sel_imm : OUT STD_LOGIC;
        sel_ld : OUT STD_LOGIC;
        sel_mov_a : OUT STD_LOGIC;
        in_seletor : OUT unsigned(1 DOWNTO 0);
        jump_rel_en : OUT STD_LOGIC; -- JMP incondicional relativo (PC + delta)
        branch_abs_en : OUT STD_LOGIC; -- BHI/BVS condicional absoluto (PC = endereço)
        wr_en_flags : OUT STD_LOGIC;

        estado_out : OUT unsigned(1 DOWNTO 0);
        -- Lab 7: novos sinais de controle da RAM
        wr_en_ram : OUT STD_LOGIC; -- habilita escrita na RAM (SW)
        sel_ram : OUT STD_LOGIC -- seleciona dado da RAM para o banco (LW)
    );
END ENTITY;

ARCHITECTURE a_un_control OF un_control IS
    SIGNAL estado_s : unsigned(1 DOWNTO 0);
    SIGNAL opcode : unsigned(3 DOWNTO 0);
BEGIN
    -- =======================================================
    -- MÁQUINA DE ESTADOS: 00 (FETCH) → 01 (DECODE) → 10 (EXECUTE)
    -- =======================================================
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            estado_s <= "00";
        ELSIF rising_edge(clk) THEN
            IF estado_s = "10" THEN
                estado_s <= "00";
            ELSE
                estado_s <= estado_s + 1;
            END IF;
        END IF;
    END PROCESS;
    estado_out <= estado_s;
    opcode <= ir_in(15 DOWNTO 12);
    -- =======================================================
    -- SINAIS DE ESCRITA — ativos apenas no estado EXECUTE (10)
    -- =======================================================
    wr_en_ir <= '1' WHEN estado_s = "01" ELSE
        '0';
    wr_en_pc <= '1' WHEN estado_s = "10" ELSE
        '0';

    -- Banco: LD (0001), MOV_R (0011), LW (1011)
    wr_en_banco <= '1' WHEN (estado_s = "10") AND
        (opcode = "0001" OR -- LD
        opcode = "0011" OR -- MOV_R
        opcode = "1011") -- LW(LAB 7)
        ELSE
        '0';
    -- Acumulador: ADD (0100), ADDI (0101), SUB (0110), CMPR (0111), MOV_A (0010)
    wr_en_acc <= '1' WHEN (estado_s = "10") AND
        (opcode = "0010" OR --MOV_A
        opcode = "0100" OR --ADD
        opcode = "0101" OR --ADDI
        opcode = "0110") --SUB
        ELSE
        '0';

    -- =======================================================
    -- SELETORES DOS MUXes
    -- =======================================================
    sel_ld <= '1' WHEN opcode = "0001" ELSE
        '0';
    sel_imm <= '1' WHEN opcode = "0101" ELSE
        '0';
    sel_mov_a <= '1' WHEN opcode = "0010" ELSE
        '0';
    -- Lab 7: seleciona dado da RAM para entrar no banco (LW)
    sel_ram <= '1' WHEN opcode = "1011" ELSE
        '0';
    -- =======================================================
    -- SELETOR DA ULA
    -- =======================================================
    in_seletor <= "00" WHEN (opcode = "0100" OR opcode = "0101") ELSE
        "01" WHEN (opcode = "0110" OR opcode = "0111") ELSE
        "00";

    -- =======================================================
    -- SALTOS
    -- =======================================================
    -- Salto Incondicional RELATIVO (JMP, Opcode 1000): PC = PC + delta
    jump_rel_en <= '1' WHEN opcode = "1000" ELSE
        '0';

    -- Saltos Condicionais ABSOLUTOS (BHI/BVS): PC = endereço direto
    -- BHI (Opcode 1001): salta se C=1 e Z=0 (unsigned higher)
    -- BVS (Opcode 1010): salta se V=1 (overflow)
    branch_abs_en <= '1' WHEN (opcode = "1001" AND flag_c = '1' AND flag_z = '0') OR
        (opcode = "1010" AND flag_v = '1')
        ELSE
        '0';
    -- =======================================================
    -- FLAGS — só atualizam em ADD, ADDI, SUB, CMPR
    -- LW, SW, LD, MOV, JMP, BHI, BVS, NOP NÃO atualizam flags
    -- =======================================================
    wr_en_flags <= '1' WHEN (estado_s = "10") AND
        (opcode = "0100" OR --ADD
        opcode = "0101" OR --ADDI
        opcode = "0110" OR --SUB
        opcode = "0111") --CMPR
        ELSE
        '0';
    -- =======================================================
    -- Lab 7: RAM — escrita ativa no EXECUTE de SW (1100)
    -- A leitura da RAM é assíncrona, não precisa de sinal
    -- =======================================================
    wr_en_ram <= '1' WHEN (estado_s = "10") AND
        (opcode = "1100") -- SW
        ELSE
        '0';
END ARCHITECTURE;