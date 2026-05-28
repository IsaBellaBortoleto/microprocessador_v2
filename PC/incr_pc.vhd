--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: circuito externo somador com 1 para o PC (incremento do PC)
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY incr_pc IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        pc_out : OUT unsigned(6 DOWNTO 0)
    );
END;

ARCHITECTURE a_incr_pc OF incr_pc IS

    COMPONENT pc
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            data_in : IN unsigned(6 DOWNTO 0);
            data_out : OUT unsigned(6 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL fio_pc_out : unsigned(6 DOWNTO 0);
    SIGNAL fio_pc_in : unsigned(6 DOWNTO 0);

BEGIN

    utt_pc : pc PORT MAP(
        clk => clk,
        rst => rst,
        wr_en => '1', --"Por enquanto pode deixar wr_en=1 sempre, então todo clock vai incrementar"
        data_in => fio_pc_in,
        data_out => fio_pc_out
    );

    fio_pc_in <= fio_pc_out + 1; -- incremento do PC
    pc_out <= fio_pc_out; -- saída do PC para observação

END ARCHITECTURE;