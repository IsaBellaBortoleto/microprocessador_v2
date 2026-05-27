--------------------------------------------------------------------------------
-- Arquivo de Teste (testbench da unidade de controle): un_control_tb.vhd
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY un_control_tb IS
END;

ARCHITECTURE a_un_control_tb OF un_control_tb IS
    COMPONENT un_control
        PORT (
            clk           : IN STD_LOGIC;
            rst           : IN STD_LOGIC;
            ir_in         : IN unsigned(15 DOWNTO 0);
            flag_z        : IN STD_LOGIC;
            flag_c        : IN STD_LOGIC;
            flag_v        : IN STD_LOGIC;
            wr_en_pc      : OUT STD_LOGIC;
            wr_en_ir      : OUT STD_LOGIC;
            wr_en_banco   : OUT STD_LOGIC;
            wr_en_acc     : OUT STD_LOGIC;
            sel_imm       : OUT STD_LOGIC;
            sel_ld        : OUT STD_LOGIC;
            sel_mov_a     : OUT STD_LOGIC;
            in_seletor    : OUT unsigned(1 DOWNTO 0);
            jump_rel_en   : OUT STD_LOGIC;
            branch_abs_en : OUT STD_LOGIC;
            wr_en_flags   : OUT STD_LOGIC;
            estado_out    : OUT unsigned(1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk, rst         : STD_LOGIC;
    SIGNAL ir_in            : unsigned(15 DOWNTO 0) := "0000000000000000";
    SIGNAL flag_z, flag_c, flag_v : STD_LOGIC := '0';
    SIGNAL wr_en_pc         : STD_LOGIC;
    SIGNAL wr_en_ir         : STD_LOGIC;
    SIGNAL wr_en_banco      : STD_LOGIC;
    SIGNAL wr_en_acc        : STD_LOGIC;
    SIGNAL sel_imm          : STD_LOGIC;
    SIGNAL sel_ld           : STD_LOGIC;
    SIGNAL sel_mov_a        : STD_LOGIC;
    SIGNAL in_seletor       : unsigned(1 DOWNTO 0);
    SIGNAL jump_rel_en      : STD_LOGIC;
    SIGNAL branch_abs_en    : STD_LOGIC;
    SIGNAL wr_en_flags      : STD_LOGIC;
    SIGNAL estado_out       : unsigned(1 DOWNTO 0);

    CONSTANT period_time : TIME := 100 ns;
    SIGNAL finished : STD_LOGIC := '0';

BEGIN
    uut : un_control PORT MAP(
        clk           => clk,
        rst           => rst,
        ir_in         => ir_in,
        flag_z        => flag_z,
        flag_c        => flag_c,
        flag_v        => flag_v,
        wr_en_pc      => wr_en_pc,
        wr_en_ir      => wr_en_ir,
        wr_en_banco   => wr_en_banco,
        wr_en_acc     => wr_en_acc,
        sel_imm       => sel_imm,
        sel_ld        => sel_ld,
        sel_mov_a     => sel_mov_a,
        in_seletor    => in_seletor,
        jump_rel_en   => jump_rel_en,
        branch_abs_en => branch_abs_en,
        wr_en_flags   => wr_en_flags,
        estado_out    => estado_out
    );

    reset_global : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR period_time * 2;
        rst <= '0';
        WAIT;
    END PROCESS;

    sim_time_proc : PROCESS
    BEGIN
        WAIT FOR 10 us;
        finished <= '1';
        WAIT;
    END PROCESS;

    clk_proc : PROCESS
    BEGIN
        WHILE finished /= '1' LOOP
            clk <= '0';
            WAIT FOR period_time / 2;
            clk <= '1';
            WAIT FOR period_time / 2;
        END LOOP;
        WAIT;
    END PROCESS;

    -- Processo de testes: simula instruções sendo lidas do IR
    PROCESS
    BEGIN
        WAIT FOR 200 ns;

        ------------------------------------------------------------------
        -- TESTE 1: NOP (opcode 0000)
        -- Esperado: nenhum wr_en ativo, jump_rel=0, branch_abs=0
        ------------------------------------------------------------------
        ir_in <= "0000000000000000";
        WAIT FOR period_time * 3;

        ------------------------------------------------------------------
        -- TESTE 2: LD R3, 5 (opcode 0001)
        -- Esperado: wr_en_banco=1 no estado 2, sel_ld=1
        ------------------------------------------------------------------
        ir_in <= "0001001100000101";
        WAIT FOR period_time * 3;

        ------------------------------------------------------------------
        -- TESTE 3: ADD R4 (opcode 0100)
        -- Esperado: wr_en_acc=1 no estado 2, wr_en_flags=1
        ------------------------------------------------------------------
        ir_in <= "0100000001000000";
        WAIT FOR period_time * 3;

        ------------------------------------------------------------------
        -- TESTE 4: JMP +5 (opcode 1000, relativo)
        -- Esperado: jump_rel_en=1, branch_abs_en=0
        ------------------------------------------------------------------
        ir_in <= "1000000000000101";
        WAIT FOR period_time * 3;

        ------------------------------------------------------------------
        -- TESTE 5: BHI 3 (opcode 1001, absoluto) com C=1, Z=0
        -- Esperado: branch_abs_en=1, jump_rel_en=0
        ------------------------------------------------------------------
        flag_c <= '1';
        flag_z <= '0';
        ir_in <= "1001000000000011";
        WAIT FOR period_time * 3;

        ------------------------------------------------------------------
        -- TESTE 6: BHI 3 com C=0 (condição NÃO atendida)
        -- Esperado: branch_abs_en=0 (não salta)
        ------------------------------------------------------------------
        flag_c <= '0';
        flag_z <= '0';
        ir_in <= "1001000000000011";
        WAIT FOR period_time * 3;

        ------------------------------------------------------------------
        -- TESTE 7: BVS 10 (opcode 1010, absoluto) com V=1
        -- Esperado: branch_abs_en=1
        ------------------------------------------------------------------
        flag_v <= '1';
        ir_in <= "1010000000001010";
        WAIT FOR period_time * 3;

        WAIT;
    END PROCESS;

END ARCHITECTURE;