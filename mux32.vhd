LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity MUX32 is -- Two by one mux with 32 bit inputs/outputs
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0); -- sel == 0
    in1    : in STD_LOGIC_VECTOR(31 downto 0); -- sel == 1
    sel    : in STD_LOGIC; -- selects in0 or in1
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end MUX32;

ARCHITECTURE behave OF MUX32 IS
begin 
    output <= in0 when sel='0' else
              in1 when sel='1';
end behave;
