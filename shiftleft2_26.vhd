LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ShiftLeft2_26 is
port(
     x : in  STD_LOGIC_VECTOR(25 downto 0);
     y : out STD_LOGIC_VECTOR(27 downto 0) -- x << 2
);
end ShiftLeft2_26;

ARCHITECTURE behave OF ShiftLeft2_26 IS
begin
    y <= x & "00";
end behave;