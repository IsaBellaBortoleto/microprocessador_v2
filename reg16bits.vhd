--------------------------------------------------------------------------------
-- Projeto : Microprocessador Didático
-- Módulo   : Registrador de 16 Bits
--
-- Descrição:
-- Este módulo implementa um registrador síncrono de 16 bits com:
--
--   - Entrada de clock
--   - Reset assíncrono
--   - Habilitação de escrita (Write Enable)
--
-- O registrador é utilizado para armazenar temporariamente dados no
-- microprocessador, podendo atuar como acumulador (ACC), registrador
-- interno ou elemento de armazenamento em outros blocos do sistema.
--
-- Funcionamento:
--
-- 1. Reset:
--    Quando rst = '1', o conteúdo do registrador é imediatamente
--    zerado, independentemente do clock.
--
-- 2. Escrita:
--    Quando wr_en = '1', o valor presente em "data_in" é armazenado
--    na borda de subida do clock.
--
-- 3. Retenção:
--    Quando wr_en = '0', o registrador mantém o valor previamente
--    armazenado.
--
-- Entradas:
--   clk       : Clock do sistema
--   rst       : Reset assíncrono ativo em nível alto
--   wr_en     : Habilita escrita no registrador
--   data_in   : Dado de entrada de 16 bits
--
-- Saídas:
--   data_out  : Conteúdo atual armazenado no registrador
--
-- Estrutura Interna:
--   registro  : Sinal interno responsável por armazenar os dados
--
-- Observações:
-- - O reset é assíncrono, pois não depende da borda do clock.
-- - A escrita é síncrona, ocorrendo apenas em rising_edge(clk).
-- - A saída é conectada diretamente ao sinal interno "registro".
-- - Este módulo é reutilizado no projeto como acumulador do processador.
--
-- Fluxo de Operação:
--
--        data_in
--           |
--           v
--     +-------------+
--     | Registrador |
--     |   16 bits   |
--     +-------------+
--           |
--           v
--        data_out
--
-- Autores:
--   Isabela Bella Bortoleto
--   Nícolas Auersvalt Marques
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY reg16bits IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        wr_en : IN STD_LOGIC;
        data_in : IN unsigned(15 DOWNTO 0);
        data_out : OUT unsigned(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE a_reg16bits OF reg16bits IS
    SIGNAL registro : unsigned(15 DOWNTO 0);
BEGIN
    PROCESS (clk, rst) -- Apenas clk e rst permitidos aqui
    BEGIN
        IF rst = '1' THEN
            registro <= "0000000000000000";
        ELSIF rising_edge(clk) THEN
            IF wr_en = '1' THEN
                registro <= data_in;
            END IF;
        END IF;
    END PROCESS;
    data_out <= registro; -- conexao direta, fora do processo
END ARCHITECTURE;