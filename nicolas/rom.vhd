library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
   port( clk      : in std_logic;
         endereco : in unsigned(6 downto 0);   -- endereço do registrador
         dado     : out unsigned(15 downto 0) -- quantidade de bits do dado a ser salvo (12 bits = 2^12-1 = 2048 bits)
   );
end entity;
architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(15 downto 0);
   constant conteudo_rom : mem := (
   -- caso endereco => conteudo
      0  => "0000000000000010",
      1  => "0000100000000000",
      2  => "0000000000000000",
      3  => "0000000000000000",
      4  => "0000100000000000",
      5  => "0000000000000010",
      6  => "0000111100000011",
      7  => "0000000000000010",
      8  => "0000000000000010",
      9  => "0000000000000000",
      10 => "0000000000000000",
      -- abaixo: casos omissos => (zero em todos os bits)
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(falling_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;

