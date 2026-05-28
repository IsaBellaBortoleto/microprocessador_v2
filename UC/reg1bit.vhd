--------------------------------------------------------------------------------
-- Projeto: Microprocessador
-- Descrição: Registrador de 1 bit (flip-flop com clk, rst, wr_en)
--            Usado para armazenar as flags C, Z e V fora da ULA
-- Autores: Isabela Bortoleto e Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reg1bit IS
    PORT (
        clk      : IN STD_LOGIC;
        rst      : IN STD_LOGIC;
        wr_en    : IN STD_LOGIC;
        data_in  : IN STD_LOGIC;
        data_out : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE a_reg1bit OF reg1bit IS
    SIGNAL registro : STD_LOGIC;
BEGIN
    -- Nota: Apenas clk e rst vão na lista de sensibilidade
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            registro <= '0';
        ELSIF rising_edge(clk) THEN
            IF wr_en = '1' THEN
                registro <= data_in;
            END IF;
        END IF;
    END PROCESS;
    
    data_out <= registro;
END ARCHITECTURE;