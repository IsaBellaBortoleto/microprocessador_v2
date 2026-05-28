--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: Máquina de estados de 2 estados (flip-flop T)
--            Estado 0 = Fetch (leitura da ROM)
--            Estado 1 = Decode/Execute (atualização do PC)
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY maquina_estados IS
    PORT (
        clk_i    : IN STD_LOGIC;
        rst_i    : IN STD_LOGIC;
        estado_o : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE a_maquina_estados OF maquina_estados IS
    SIGNAL estado_s : STD_LOGIC;
BEGIN
    PROCESS (clk_i, rst_i)
    BEGIN
        IF rst_i = '1' THEN
            estado_s <= '0';
        ELSIF rising_edge(clk_i) THEN
            estado_s <= NOT estado_s;
        END IF;
    END PROCESS;

    estado_o <= estado_s;
END ARCHITECTURE;