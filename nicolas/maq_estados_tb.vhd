library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_maq_estados is
end entity;

architecture tb of tb_maq_estados is

    -- sinais do testbench
    signal clk          : std_logic := '0';
    signal chang_state  : std_logic := '0';
    signal out_state    : unsigned(1 downto 0);

begin

    -- instanciação da UUT (Unit Under Test)
    uut : entity work.maq_estados
        port map(
            clk          => clk,
            chang_state  => chang_state,
            out_state    => out_state
        );

    --------------------------------------------------------------------
    -- geração de clock
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;

            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- estímulos
    --------------------------------------------------------------------
    stim_process : process
    begin

        -- estado inicial
        wait for 25 ns;

        -- muda estado
        chang_state <= '1';
        wait for 20 ns;

        -- muda novamente
        wait for 20 ns;

        -- para de mudar
        chang_state <= '0';
        wait for 40 ns;

        -- muda de novo
        chang_state <= '1';
        wait for 40 ns;

        wait;
    end process;

end architecture;