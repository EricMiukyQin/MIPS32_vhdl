LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.13 in the textbook.
-- You only need to consider the cases where ALUOp = "00", "01", and "10". ALUOp = "11" is not
--    a valid input and need not be considered; its output can be anything, including "0110",
--    "0010", "XXXX", etc.
-- To ensure proper functionality, you must implement the "don't-care" values in the funct field,
-- for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Funct     : in  STD_LOGIC_VECTOR(5 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
);
end ALUControl;

architecture behave of ALUControl is
begin
   process(ALUOp, Funct)
   begin
      case ALUOp is
         when "00" => Operation <= "0010";
         when "01" => Operation <= "0110";
         when "10" =>
            case Funct(3 downto 0) is
               when "0000" => Operation <= "0010";
               when "0010" => Operation <= "0110";
               when "0100" => Operation <= "0000";
               when "0101" => Operation <= "0001";
               when "1010" => Operation <= "0111";
               when others => Operation <= "XXXX";
            end case;
         when "11" =>
            case Funct(3 downto 0) is
               when "0000" => Operation <= "0010";
               when others => Operation <= "XXXX";
            end case;             
         when others => NULL;
      end case;
   end process;
end behave;