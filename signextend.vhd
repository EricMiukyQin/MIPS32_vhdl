LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(15 downto 0);
     y : out STD_LOGIC_VECTOR(31 downto 0) -- sign-extend(x)
);
end SignExtend;

ARCHITECTURE behave OF SignExtend IS
begin
   y(31 downto 16) <= (others=>x(15));
   y(15 downto 0) <= x;
end behave;