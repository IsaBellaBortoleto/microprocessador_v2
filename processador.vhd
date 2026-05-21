LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processador IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        
        -- Pinos observáveis exigidos pelo laboratório
        estado_out : OUT unsigned(1 DOWNTO 0);
        pc_out     : OUT unsigned(6 DOWNTO 0);
        ir_out     : OUT unsigned(15 DOWNTO 0);
        ula_out    : OUT unsigned(15 DOWNTO 0);
        acc_out    : OUT unsigned(15 DOWNTO 0);
        banco_out  : OUT unsigned(15 DOWNTO 0)
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
            data_out : OUT unsigned(15 DOWNTO 0)
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
            wr_en_pc : OUT STD_LOGIC;
            wr_en_ir : OUT STD_LOGIC;
            wr_en_banco : OUT STD_LOGIC;
            wr_en_acc : OUT STD_LOGIC;
            sel_imm : OUT STD_LOGIC;
            sel_mov_a : OUT STD_LOGIC;
            sel_ld : OUT STD_LOGIC;
            in_seletor : OUT unsigned(1 DOWNTO 0);
            jump_en : OUT STD_LOGIC;
            estado_out : OUT unsigned(1 DOWNTO 0)
        );
    END COMPONENT;

    -- =======================================================
    -- 2. DECLARAÇÃO DOS FIOS (SIGNALS) INTERNOS
    -- =======================================================
    -- Datapath
    SIGNAL fio_pc_in         : unsigned(6 DOWNTO 0);
    SIGNAL fio_pc_out        : unsigned(6 DOWNTO 0);
    SIGNAL fio_rom_out       : unsigned(15 DOWNTO 0);
    SIGNAL fio_ir_out        : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_acc       : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_ula       : unsigned(15 DOWNTO 0);
    SIGNAL fio_out_banco     : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_b_ula      : unsigned(15 DOWNTO 0);
    SIGNAL fio_in_data_banco : unsigned(15 DOWNTO 0);
    
    -- Sinais extraídos do IR
    SIGNAL cte_ext   : unsigned(15 DOWNTO 0);
    SIGNAL write_sel : unsigned(3 DOWNTO 0);
    SIGNAL read_sel  : unsigned(3 DOWNTO 0);

    -- Sinais de Controle gerados pela UC
    SIGNAL fio_wr_en_pc    : STD_LOGIC;
    SIGNAL fio_wr_en_ir    : STD_LOGIC;
    SIGNAL fio_wr_en_banco : STD_LOGIC;
    SIGNAL fio_wr_en_acc   : STD_LOGIC;
    SIGNAL fio_sel_imm     : STD_LOGIC;
    SIGNAL fio_sel_ld      : STD_LOGIC;
    SIGNAL fio_in_seletor  : unsigned(1 DOWNTO 0);
    SIGNAL fio_jump_en     : STD_LOGIC;
    SIGNAL fio_sel_mov_a   : STD_LOGIC;
    SIGNAL fio_in_data_acc : unsigned(15 DOWNTO 0);

    -- Flags
    SIGNAL fio_flag_z, fio_flag_c, fio_flag_v : STD_LOGIC;

BEGIN
    -- =======================================================
    -- 3. DECODIFICAÇÃO DE FIOS E MULTIPLEXADORES
    -- =======================================================
    
    -- Fatiando a instrução do IR
    write_sel <= fio_ir_out(11 DOWNTO 8); -- Destino
    read_sel  <= fio_ir_out(7 DOWNTO 4);  -- Fonte
    cte_ext   <= "00000000" & fio_ir_out(7 DOWNTO 0); -- Constante com zero-extend
    
    -- MUX do PC (Absoluto)
    fio_pc_in <= unsigned(fio_ir_out(6 DOWNTO 0)) WHEN fio_jump_en = '1' ELSE
                 fio_pc_out + 1;

    -- MUX da entrada B da ULA (ADDI x ADD)
    fio_in_b_ula <= cte_ext WHEN fio_sel_imm = '1' ELSE 
                    fio_out_banco;

    -- MUX de entrada do Banco (LD x Resultado da ULA)
    fio_in_data_banco <= cte_ext WHEN fio_sel_ld = '1' ELSE 
                         fio_out_acc;

    -- MUX de entrada do Acumulador (MOV_A x ULA)
    fio_in_data_acc <= fio_out_banco WHEN fio_sel_mov_a = '1' ELSE 
                       fio_out_ula;

    -- Ligação para os pinos de teste do GTKWave
    pc_out    <= fio_pc_out;
    ir_out    <= fio_ir_out;
    ula_out   <= fio_out_ula;
    acc_out   <= fio_out_acc;
    banco_out <= fio_out_banco;
    

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
        wr_en_pc => fio_wr_en_pc,
        wr_en_ir => fio_wr_en_ir,
        wr_en_banco => fio_wr_en_banco,
        wr_en_acc => fio_wr_en_acc,
        sel_imm => fio_sel_imm,
        sel_ld => fio_sel_ld,
        sel_mov_a => fio_sel_mov_a,
        in_seletor => fio_in_seletor,
        jump_en => fio_jump_en,
        estado_out => estado_out
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
        data_out => fio_out_banco
    );

    inst_acc : reg16bits PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => fio_wr_en_acc,
        data_in => fio_in_data_acc,
        data_out => fio_out_acc
    );

END ARCHITECTURE;