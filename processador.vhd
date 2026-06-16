LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processador IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        -- Pinos observáveis exigidos pelo laboratório
        estado_out : OUT unsigned(1 DOWNTO 0);
        pc_out : OUT unsigned(6 DOWNTO 0);
        ir_out : OUT unsigned(15 DOWNTO 0);
        ula_out : OUT unsigned(15 DOWNTO 0);
        acc_out : OUT unsigned(15 DOWNTO 0);
        banco_out : OUT unsigned(15 DOWNTO 0);

        -- Flags registradas (Lab 6) — sorteio BHI (C=1,Z=0) e BVS (V=1)
        flag_c_out : OUT STD_LOGIC;
        flag_z_out : OUT STD_LOGIC;
        flag_v_out : OUT STD_LOGIC;
        -- Pinos observáveis da RAM (Lab 7)
        ram_dado_out_obs : OUT unsigned(15 DOWNTO 0);
        ram_endereco_obs : OUT unsigned(6 DOWNTO 0);

        -- Lab 8
        bus_debug : OUT unsigned(15 DOWNTO 0); -- resultado: divisor de 899 (esperado: 29)
        bit_debug : OUT STD_LOGIC -- resultado: 899 é primo? (esperado: 0)
    );
END ENTITY;

ARCHITECTURE a_processador OF processador IS

    -- =======================================================
    -- 1. DECLARAÇÃO DOS COMPONENTES
    -- =======================================================
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

    COMPONENT banco_regs
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            write_sel : IN unsigned(3 DOWNTO 0);
            read_sel : IN unsigned(3 DOWNTO 0);
            data_in : IN unsigned(15 DOWNTO 0);
            data_out : OUT unsigned(15 DOWNTO 0);
                    r3_out : OUT unsigned(15 DOWNTO 0);
        r4_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT reg16bits
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(15 DOWNTO 0);
            data_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT pc
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(6 DOWNTO 0);
            data_out : OUT unsigned(6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT rom
        PORT (
            clk : IN STD_LOGIC;
            endereco : IN unsigned(6 DOWNTO 0);
            dado : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT un_control
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            ir_in : IN unsigned(15 DOWNTO 0);
            -- Flags registradas alimentam a UC para decisão dos branches
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
            jump_rel_en : OUT STD_LOGIC; -- JMP incondicional relativo
            branch_abs_en : OUT STD_LOGIC; -- BHI/BVS condicional absoluto
            wr_en_flags : OUT STD_LOGIC;
            estado_out : OUT unsigned(1 DOWNTO 0);
            wr_en_ram : OUT STD_LOGIC;
            sel_ram : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT reg1bit
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN STD_LOGIC;
            data_out : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ram
        PORT (
            clk : IN STD_LOGIC;
            endereco : IN unsigned(6 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            dado_in : IN unsigned(15 DOWNTO 0);
            dado_out : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;

    -- =======================================================
    -- 2. DECLARAÇÃO DOS FIOS (SIGNALS) INTERNOS
    -- =======================================================
    -- Datapath
    SIGNAL fio_pc_in : unsigned(6 DOWNTO 0);
    SIGNAL fio_pc_out : unsigned(6 DOWNTO 0);
    SIGNAL fio_rom_out : unsigned(15 DOWNTO 0);
    SIGNAL fio_ir_out : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_acc : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_ula : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_banco : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_b_ula : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_data_banco : unsigned(15 DOWNTO 0);

    -- Sinais extraídos do IR
    SIGNAL cte_ext : unsigned(15 DOWNTO 0);
    SIGNAL write_sel : unsigned(3 DOWNTO 0);
    SIGNAL read_sel : unsigned(3 DOWNTO 0);

    -- Sinais de Controle gerados pela UC
    SIGNAL fio_wr_en_pc : STD_LOGIC;
    SIGNAL fio_wr_en_ir : STD_LOGIC;
    SIGNAL fio_wr_en_banco : STD_LOGIC;
    SIGNAL fio_wr_en_acc : STD_LOGIC;
    SIGNAL fio_sel_imm : STD_LOGIC;
    SIGNAL fio_sel_ld : STD_LOGIC;
    SIGNAL fio_in_seletor : unsigned(1 DOWNTO 0);
    SIGNAL fio_jump_rel_en : STD_LOGIC; -- JMP incondicional relativo
    SIGNAL fio_branch_abs_en : STD_LOGIC; -- BHI/BVS condicional absoluto
    SIGNAL fio_sel_mov_a : STD_LOGIC;
    SIGNAL fio_in_data_acc : unsigned(15 DOWNTO 0);

    -- Flags
    SIGNAL fio_flag_z, fio_flag_c, fio_flag_v : STD_LOGIC;

    -- Sinais de controle e saída dos flip-flops das flags (Lab 6)
    SIGNAL fio_wr_en_flags : STD_LOGIC;
    SIGNAL fio_flag_c_reg : STD_LOGIC;
    SIGNAL fio_flag_z_reg : STD_LOGIC;
    SIGNAL fio_flag_v_reg : STD_LOGIC;
    -- RAM (Lab 7)
    SIGNAL fio_ram_endereco : unsigned(6 DOWNTO 0);
    SIGNAL fio_wr_en_ram : STD_LOGIC;
    SIGNAL fio_ram_dado_in : unsigned(15 DOWNTO 0);
    SIGNAL fio_ram_dado_out : unsigned(15 DOWNTO 0);
    SIGNAL fio_sel_ram : STD_LOGIC;

    -- crivo de Eratóstenes (Lab 8)
    SIGNAL fio_bus_debug : unsigned(15 DOWNTO 0);
    SIGNAL fio_bit_debug : STD_LOGIC;

BEGIN
    -- =======================================================
    -- 3. DECODIFICAÇÃO DE FIOS E MULTIPLEXADORES
    -- =======================================================

    -- Fatiando a instrução do IR
    write_sel <= fio_ir_out(11 DOWNTO 8); -- Destino
    read_sel <= fio_ir_out(7 DOWNTO 4); -- Fonte
    cte_ext <= "00000000" & fio_ir_out(7 DOWNTO 0); -- Constante com zero-extend

    -- MUX do PC — sorteio: incondicional RELATIVO, condicional ABSOLUTO
    -- JMP (1000): PC = PC + delta (complemento de 2 em ir[6:0])
    -- BHI (1001) / BVS (1010): PC = ir[6:0] direto (endereço absoluto)
    fio_pc_in <= (fio_pc_out + fio_ir_out(6 DOWNTO 0)) WHEN fio_jump_rel_en = '1' ELSE
        fio_ir_out(6 DOWNTO 0) WHEN fio_branch_abs_en = '1' ELSE
        fio_pc_out + 1;

    -- MUX da entrada B da ULA (ADDI x ADD)
    fio_in_b_ula <= cte_ext WHEN fio_sel_imm = '1' ELSE
        fio_out_banco;

    -- MUX de entrada do Banco:
    -- LD  (sel_ld=1)  → constante imediata da instrução
    -- LW  (sel_ram=1) → dado lido da RAM (Lab 7)
    -- demais          → acumulador (resultado de ADD/SUB/etc)
    fio_in_data_banco <= cte_ext WHEN fio_sel_ld = '1' ELSE
        fio_ram_dado_out WHEN fio_sel_ram = '1' ELSE
        fio_out_acc;

    -- MUX de entrada do Acumulador (MOV_A x ULA)
    fio_in_data_acc <= fio_out_banco WHEN fio_sel_mov_a = '1' ELSE
        fio_out_ula;

    -- Ligação para os pinos de teste do GTKWave
    pc_out <= fio_pc_out;
    ir_out <= fio_ir_out;
    ula_out <= fio_out_ula;
    acc_out <= fio_out_acc;
    banco_out <= fio_out_banco;
    -- Pinos observáveis da RAM para o GTKWave
    ram_dado_out_obs <= fio_ram_dado_out;
    ram_endereco_obs <= fio_ram_endereco;

    -- Lab 8: sinais de debug para o GTKWave
    bus_debug <= fio_bus_debug;
    bit_debug <= fio_bit_debug;


    -- =======================================================
    -- 4. INSTANCIAÇÕES (PLUGANDO OS COMPONENTES)
    -- =======================================================

    inst_pc : pc PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_pc,
        data_in => fio_pc_in,
        data_out => fio_pc_out
    );

    inst_rom : rom PORT MAP(
        clk => clk,
        endereco => fio_pc_out,
        dado => fio_rom_out

    );

    inst_ir : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_ir,
        data_in => fio_rom_out,
        data_out => fio_ir_out
    );

    inst_uc : un_control PORT MAP(
        clk => clk,
        rst => rst,
        ir_in => fio_ir_out,
        -- Flags registradas: a UC consulta o valor TRAVADO do ciclo anterior
        flag_z => fio_flag_z_reg,
        flag_c => fio_flag_c_reg,
        flag_v => fio_flag_v_reg,
        wr_en_pc => fio_wr_en_pc,
        wr_en_ir => fio_wr_en_ir,
        wr_en_banco => fio_wr_en_banco,
        wr_en_acc => fio_wr_en_acc,
        sel_imm => fio_sel_imm,
        sel_ld => fio_sel_ld,
        sel_mov_a => fio_sel_mov_a,
        in_seletor => fio_in_seletor,
        jump_rel_en => fio_jump_rel_en,
        branch_abs_en => fio_branch_abs_en,
        wr_en_flags => fio_wr_en_flags,
        estado_out => estado_out,
        wr_en_ram => fio_wr_en_ram,
        sel_ram => fio_sel_ram
    );

    inst_ula : ula PORT MAP(
        in_a => fio_out_acc,
        in_b => fio_in_b_ula,
        in_seletor => fio_in_seletor,
        out_result => fio_out_ula,
        flag_z => fio_flag_z,
        flag_c => fio_flag_c,
        flag_v => fio_flag_v
    );

    inst_banco : banco_regs PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_banco,
        write_sel => write_sel,
        read_sel => read_sel,
        data_in => fio_in_data_banco,
        data_out => fio_out_banco,
        r3_out => fio_bus_debug, 
        r4_out => fio_bit_debug
    );

    inst_acc : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_acc,
        data_in => fio_in_data_acc,
        data_out => fio_out_acc
    );
    -- Lab 7: memória de dados RAM (escrita síncrona, leitura assíncrona)
    inst_ram : ram PORT MAP(
        clk => clk,
        endereco => fio_ram_endereco,
        wr_en => fio_wr_en_ram,
        dado_in => fio_ram_dado_in,
        dado_out => fio_ram_dado_out
    );

    -- =======================================================
    -- 5. FLIP-FLOPS DAS FLAGS (Lab 6)
    -- Instâncias de reg1bit — fora da ULA, no top-level.
    -- wr_en_flags ativo apenas em ADD, ADDI, SUB, CMPR (estado Execute).
    -- LD, MOV, JMP, BHI, BVS e NOP NÃO atualizam as flags.
    -- =======================================================

    inst_flag_c : reg1bit PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_flags,
        data_in => fio_flag_c,
        data_out => fio_flag_c_reg
    );

    inst_flag_z : reg1bit PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_flags,
        data_in => fio_flag_z,
        data_out => fio_flag_z_reg
    );

    inst_flag_v : reg1bit PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_flags,
        data_in => fio_flag_v,
        data_out => fio_flag_v_reg
    );

    -- Conexão das flags registradas nos pinos observáveis
    flag_c_out <= fio_flag_c_reg;
    flag_z_out <= fio_flag_z_reg;
    flag_v_out <= fio_flag_v_reg;

    -- O registrador fonte (Rs = ir[7:4]) atua como ponteiro de endereço da RAM
    fio_ram_endereco <= fio_out_banco(6 DOWNTO 0);

    -- O acumulador é a fonte do dado a ser escrito na RAM (instrução SW)
    fio_ram_dado_in <= fio_out_acc;
END ARCHITECTURE;