LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY un_control IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        -- Entrada: A instrução atual lida do IR
        ir_in : IN unsigned(15 DOWNTO 0);
        
        -- Entradas de Status (Flags vindas da ULA)
        flag_z : IN STD_LOGIC;
        flag_c : IN STD_LOGIC;
        flag_v : IN STD_LOGIC;

        -- Saídas de Controle para o processador
        wr_en_pc    : OUT STD_LOGIC;
        wr_en_ir    : OUT STD_LOGIC;
        wr_en_banco : OUT STD_LOGIC;
        wr_en_acc   : OUT STD_LOGIC;
        sel_imm     : OUT STD_LOGIC;
        sel_ld      : OUT STD_LOGIC;
        sel_mov_a   : OUT STD_LOGIC; 
        in_seletor  : OUT unsigned(1 DOWNTO 0);
        jump_en     : OUT STD_LOGIC;
        
        -- Saída de estado para o GTKWave
        estado_out  : OUT unsigned(1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_un_control OF un_control IS
    SIGNAL estado_s : unsigned(1 DOWNTO 0);
    SIGNAL opcode   : unsigned(3 DOWNTO 0);
BEGIN
    -- =======================================================
    -- 1. MÁQUINA DE ESTADOS (3 estados)
    -- =======================================================
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            estado_s <= "00";
        ELSIF rising_edge(clk) THEN
            IF estado_s = "10" THEN        -- Se agora está em 2 (Execute)
                estado_s <= "00";          -- O próximo volta ao zero (Fetch)
            ELSE
                estado_s <= estado_s + 1;  -- Senão avança (0->1, 1->2)
            END IF;
        END IF;
    END PROCESS;

    estado_out <= estado_s;

    -- =======================================================
    -- 2. DECODIFICAÇÃO (Lógica Combinacional)
    -- =======================================================
    opcode <= ir_in(15 DOWNTO 12);

    -- O IR é escrito no estado 1, logo após a ROM síncrona entregar o dado
    wr_en_ir <= '1' WHEN estado_s = "01" ELSE '0';
    
    -- O PC só é atualizado no estado 2 (Execute)
    wr_en_pc <= '1' WHEN estado_s = "10" ELSE '0';

    -- Sinais baseados no Opcode (ativados no estado 2: Execute):
    
    -- Escreve no Banco se for LD (0001) ou MOV_R (0011)
    wr_en_banco <= '1' WHEN (estado_s = "10") AND (opcode = "0001" OR opcode = "0011") ELSE '0';

    -- Escreve no Acumulador se for MOV_A (0010), ADD (0100), ADDI (0101) ou SUB (0110)
    wr_en_acc <= '1' WHEN (estado_s = "10") AND 
                          (opcode = "0010" OR opcode = "0100" OR opcode = "0101" OR opcode = "0110") ELSE '0';

    -- Sinais de Multiplexadores (Rotas de dados independem do estado, são contínuos)
    sel_ld <= '1' WHEN opcode = "0001" ELSE '0';  
    sel_imm <= '1' WHEN opcode = "0101" ELSE '0'; 
    sel_mov_a <= '1' WHEN opcode = "0010" ELSE '0';

    in_seletor <= "00" WHEN (opcode = "0100" OR opcode = "0101") ELSE -- ADD, ADDI
                  "01" WHEN (opcode = "0110" OR opcode = "0111") ELSE -- SUB, CMPR
                  "00"; -- Default

    -- =======================================================
    -- LÓGICA DE SALTOS (JMP, BHI, BVS)
    -- =======================================================
    -- jump_en atua como o seletor do MUX que alimenta o PC. 
    -- A escrita real no PC é garantida pelo wr_en_pc no estado de Execute.
    jump_en <= '1' WHEN (opcode = "1000") OR                                    -- JUMP Incondicional
                        (opcode = "1001" AND flag_c = '1' AND flag_z = '0') OR  -- BHI (A > B)
                        (opcode = "1010" AND flag_v = '1')                      -- BVS (Overflow)
                   ELSE '0';

END ARCHITECTURE;