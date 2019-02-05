LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity MUX32_3 is
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0); -- sel == 00 (reg)
    in1    : in STD_LOGIC_VECTOR(31 downto 0); -- sel == 01 (MEM)
    in2    : in STD_LOGIC_VECTOR(31 downto 0); -- se1 == 10 (EX)
    sel    : in STD_LOGIC_VECTOR(1 downto 0);  -- selects in0, in1 or in2
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end MUX32_3;

ARCHITECTURE behave OF MUX32_3 IS
begin 
    output <= in0 when sel="00" else
              in1 when sel="01" else
              in2 when sel="10";
end behave;