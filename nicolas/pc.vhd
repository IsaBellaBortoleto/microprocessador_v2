library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
   port(
      clk          : in  std_logic;
      wr_en        : in  std_logic;
      data_in      : in unsigned(3 downto 0);
      data_out     : out unsigned(3 downto 0)
   );
end entity;

architecture a_pc of pc is

   signal estado : unsigned(3 downto 0) := "0000";

begin

   process(clk)
   begin
      if rising_edge(clk) then
         if wr_en = '1' then
            if data_in /= "1111" then
                estado <= data_in + 1;
            else
                estado <= "0000";
            end if;
         end if;
      end if;
   end process;
   data_out <= estado;
end architecture;