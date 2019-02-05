LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
--    as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'MIPS Reference Data' sheet at the
--    front of the textbook.
port(
     a         : in     STD_LOGIC_VECTOR(31 downto 0);
     b         : in     STD_LOGIC_VECTOR(31 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(31 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
);
end ALU;

architecture behave of ALU is
begin
   process(operation, a, b)
   variable j: STD_LOGIC_VECTOR(32 downto 0);    --carryout
   begin
      case operation is
         when "0000" => result   <= a AND b;     -- AND
                        overflow <= '0';       
         when "0001" => result   <= a OR b;      -- OR
                        overflow <= '0';
         when "0010" =>                          -- ADD(signed)
            j(0) := '0';
            for i in 0 to 31 loop
               result(i) <= (a(i) xor b(i)) xor j(i);
               j(i+1) := (b(i) and j(i)) or (a(i) and (not b(i)) and j(i)) or (a(i) and b(i));  --Next carry(From Karnaugh Map)
            end loop;
            if(j(32)/=j(31)) then overflow <= '1'; else overflow <= '0'; end if;
         when "0110" =>                          -- SUBTRACT(signed)
            j(0) := '0';
            for i in 0 to 31 loop
               result(i) <= (a(i) xor b(i)) xor j(i);
               j(i+1) := ((not a(i)) and j(i)) or ((not a(i)) and b(i)) or (b(i) and j(i));  
            end loop;
            if(j(32)/=j(31)) then overflow <= '1'; else overflow <= '0'; end if;
         when others => NULL;
      end case;
   end process;
   zero <= '1' when result="00000000000000000000000000000000" else '0';
end behave;