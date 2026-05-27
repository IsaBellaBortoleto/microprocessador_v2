--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: PC,  'Incremento do PC': ['PC sensível a clock de descida']
-- Autores: Isabela Bella Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pc IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        wr_en : IN STD_LOGIC;
        data_in : IN unsigned(6 DOWNTO 0);
        data_out : OUT unsigned(6 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_pc OF pc IS
    SIGNAL registro : unsigned(6 DOWNTO 0);
BEGIN
    PROCESS (clk, rst) -- Removido wr_en da lista
    BEGIN
        IF rst = '1' THEN
            registro <= "0000000";
        ELSIF falling_edge(clk) THEN -- Borda de descida obrigatoriamente aqui fora
            IF wr_en = '1' THEN      -- O enable fica DENTRO do if do clock
                registro <= data_in;
            END IF;
        END IF;
    END PROCESS;
    
    data_out <= registro; -- conexao direta, fora do processo
END ARCHITECTURE;