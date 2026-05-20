library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maq_estados is
   port(
      clk          : in  std_logic;
      chang_state  : in  std_logic;
      out_state    : out unsigned(1 downto 0)
   );
end entity;

architecture rtl of maq_estados is

   signal estado : unsigned(1 downto 0) := "00";

begin

   process(clk)
   begin
      if rising_edge(clk) then

         if chang_state = '1' then
            estado <= estado + 1;
         end if;

      end if;
   end process;

   out_state <= estado;

end architecture;