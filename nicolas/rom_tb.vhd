library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_tb is
end entity;

architecture tb of rom_tb is

    -- sinais para conectar na ROM
    signal clk       : std_logic := '0';
    signal endereco  : unsigned(6 downto 0) := (others => '0');
    signal dado      : unsigned(15 downto 0);

begin

    -- instancia da ROM
    uut : entity work.rom
    port map(
        clk       => clk,
        endereco  => endereco,
        dado      => dado
    );

    -- gerador de clock
    clock_process : process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;

            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    -- estímulos
    stim_process : process
    begin

        -- endereço 0
        endereco <= to_unsigned(0, 7);
        wait for 20 ns;

        -- endereço 1
        endereco <= to_unsigned(1, 7);
        wait for 20 ns;

        -- endereço 2
        endereco <= to_unsigned(2, 7);
        wait for 20 ns;

        -- endereço 6
        endereco <= to_unsigned(6, 7);
        wait for 20 ns;

        -- endereço 10
        endereco <= to_unsigned(10, 7);
        wait for 20 ns;

        wait;
    end process;

end architecture;