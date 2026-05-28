--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: conexão do PC à ROM, para que o PC possa ler os dados da ROM
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_rom_top IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        pc_out : OUT unsigned(6 DOWNTO 0);
        rom_out : OUT unsigned(15 DOWNTO 0)
    );
END;

ARCHITECTURE a_pc_rom_top OF pc_rom_top IS

    COMPONENT incr_pc
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            pc_out : OUT unsigned(6 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT rom
        PORT (
            clk : IN STD_LOGIC;
            endereco : IN unsigned(6 DOWNTO 0);
            dado : OUT unsigned(15 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL fio_pc_out : unsigned(6 DOWNTO 0);

BEGIN

    utt_pc : incr_pc PORT MAP(
        clk => clk,
        rst => rst,
        pc_out => fio_pc_out
    );

    utt_rom : rom PORT MAP(
        clk => clk,
        endereco => fio_pc_out,
        dado => rom_out
    );

    pc_out <= fio_pc_out;

END ARCHITECTURE;