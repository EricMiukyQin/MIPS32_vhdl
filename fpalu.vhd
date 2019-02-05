LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use work.FP_Adder_Func.all;

entity FP_ALU is
port(
     a         : in     STD_LOGIC_VECTOR(31 downto 0);
     b         : in     STD_LOGIC_VECTOR(31 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(31 downto 0);
     overflow  : buffer STD_LOGIC
);
end FP_ALU;

architecture behave of FP_ALU is
begin
   process(operation, a, b)
      variable output : STD_LOGIC_VECTOR(32 downto 0);
   begin
      case operation is
         when "0010" =>                          -- add.s
            output   := fadd(a,b);
            result   <= output(31 downto 0);
            overflow <= output(32);
         when others => NULL;
      end case;
   end process;
end behave;