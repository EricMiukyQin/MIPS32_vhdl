LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity ADD is
-- Adds two signed 32-bit inputs
-- output = in1 + in2
port(
     in0    : in  STD_LOGIC_VECTOR(31 downto 0);  -- inputs are complement code
     in1    : in  STD_LOGIC_VECTOR(31 downto 0);
     output : out STD_LOGIC_VECTOR(31 downto 0)
);
end ADD;

architecture behave of ADD is
begin
   process(in0,in1)
   variable j :STD_LOGIC_VECTOR(32 downto 0);     --Previous carry
   begin
      j(0) := '0';
      for i in 0 to 31 loop
         output(i) <= (in0(i) xor in1(i)) xor j(i);
         j(i+1) := (in1(i) and j(i)) or (in0(i) and (not in1(i))
               and j(i)) or (in0(i) and in1(i));  --Next carry(From Karnaugh Map)
      end loop;
   end process;
end behave;
