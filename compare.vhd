LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity COMPARE is
port(
     In1     : in  STD_LOGIC_VECTOR(31 downto 0);
     In2     : in  STD_LOGIC_VECTOR(31 downto 0);    
     Output  : out STD_LOGIC
);
end COMPARE;

architecture behave of COMPARE is
begin
   process(In1,In2)
   begin
      if(to_integer(unsigned(In1))=to_integer(unsigned(In2)))  then
         Output <= '1';
      else
         Output <= '0';
      end if;
   end process;
end behave;